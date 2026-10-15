import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from textwrap import dedent

MODULE = Path(__file__).with_name("upload_crashlytics_symbols.py")
SPEC = importlib.util.spec_from_file_location("crashlytics_symbols", MODULE)
symbols = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(symbols)


class CrashlyticsSymbolsTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="symbol-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.paths = [self.root / "App framework.dSYM", self.root / "Catch.app.dSYM"]
        for path in self.paths:
            path.mkdir()

    def test_both_aot_and_runner_symbols_are_validated_then_uploaded(self):
        calls = []

        def run(arguments, timeout, stage):
            calls.append((arguments, timeout, stage))
            return 0

        self.assertEqual(symbols.upload_symbols("/sdk/upload-symbols", "test-app",
                                                self.paths, run), 0)
        self.assertEqual([call[2] for call in calls], ["validation", "upload", "upload"])
        self.assertIn("--validate", calls[0][0])
        self.assertEqual([call[0][-1] for call in calls[1:]], list(map(str, self.paths)))
        self.assertTrue(all("--build-phase" in call[0] for call in calls))
        self.assertEqual([call[1] for call in calls], [30, 180, 180])

    def test_validation_failure_blocks_every_upload(self):
        calls = []

        def run(arguments, timeout, stage):
            calls.append(stage)
            return 41

        self.assertEqual(symbols.upload_symbols("/sdk/upload-symbols", "test-app",
                                                self.paths, run), 41)
        self.assertEqual(calls, ["validation"])

    def test_upload_failure_is_not_hidden_and_stops_following_uploads(self):
        calls = []

        def run(arguments, timeout, stage):
            calls.append(stage)
            return 0 if stage == "validation" else 42

        self.assertEqual(symbols.upload_symbols("/sdk/upload-symbols", "test-app",
                                                self.paths, run), 42)
        self.assertEqual(calls, ["validation", "upload"])

    def test_timeout_stops_real_hung_process_and_returns_failure(self):
        pid_file = self.root / "worker-pid.json"
        code = ("import os,time,pathlib; pathlib.Path(%r).write_text(str(os.getpid())); "
                "time.sleep(60)") % str(pid_file)
        started = time.monotonic()
        result = symbols.run_stage([sys.executable, "-c", code], .2, "upload")
        self.assertEqual(result, 124)
        self.assertLess(time.monotonic() - started, 3)
        with self.assertRaises(ProcessLookupError):
            os.kill(int(pid_file.read_text()), 0)

    def test_sdk_exit_status_is_preserved(self):
        self.assertEqual(symbols.run_stage([sys.executable, "-c", "raise SystemExit(17)"],
                                          2, "upload"), 17)

    def test_caller_termination_stops_its_isolated_sdk_worker(self):
        pid_file = self.root / "sdk.pid"
        fake = "import os,pathlib,time;pathlib.Path(%r).write_text(str(os.getpid()));time.sleep(60)" % str(pid_file)
        code = ("import importlib.util,sys; "
                "s=importlib.util.spec_from_file_location('sdk',%r);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);"
                "sys.exit(m.run_stage([sys.executable,'-c',%r],30,'upload'))") % (str(MODULE), fake)
        caller = subprocess.Popen([sys.executable, "-c", code], start_new_session=True)
        sdk_pid = None
        try:
            deadline = time.monotonic() + 3
            while not pid_file.exists() and time.monotonic() < deadline:
                time.sleep(.02)
            self.assertTrue(pid_file.exists())
            sdk_pid = int(pid_file.read_text())
            caller.terminate()
            self.assertEqual(caller.wait(timeout=3), 143)
            with self.assertRaises(ProcessLookupError):
                os.kill(sdk_pid, 0)
        finally:
            if caller.poll() is None:
                os.killpg(caller.pid, signal.SIGKILL)
                caller.wait()
            if sdk_pid is not None:
                try:
                    os.killpg(sdk_pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass

    def test_missing_sdk_cannot_report_success(self):
        self.assertEqual(symbols.run_stage([str(self.root / "missing")], 1, "upload"), 1)

    def wait_for_file(self, path):
        deadline = time.monotonic() + 3
        while not path.exists() and time.monotonic() < deadline:
            time.sleep(.01)
        self.assertTrue(path.exists(), "Fake-process handshake did not complete")

    def assert_no_live_process(self, pid):
        # The SDK root must be reaped by its caller. An orphaned descendant is
        # reaped by the OS; a zombie is already terminated and cannot do work.
        result = subprocess.run(["ps", "-o", "stat=", "-p", str(pid)],
                                capture_output=True, text=True, timeout=2)
        state = result.stdout.strip()
        self.assertTrue(not state or state.startswith("Z"),
                        "Fake SDK process survived teardown")

    def stop_fake_group(self, pid):
        try:
            os.killpg(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass

    def test_repeated_cancellation_cannot_interrupt_term_grace_kill_and_reap(self):
        ready = self.root / "sdk-ready.json"
        term_seen = self.root / "term-seen"
        descendant_ready = self.root / "descendant-ready"
        sdk_pid_file = self.root / "sdk-root.pid"
        descendant = dedent("""
            import os,pathlib,signal,time
            signal.signal(signal.SIGTERM, signal.SIG_IGN)
            signal.signal(signal.SIGINT, signal.SIG_IGN)
            pathlib.Path(%r).write_text(str(os.getpid()))
            time.sleep(60)
        """) % str(descendant_ready)
        fake = dedent("""
            import json,os,pathlib,signal,subprocess,sys,time
            pathlib.Path(%r).write_text(str(os.getpid()))
            signal.signal(signal.SIGTERM, lambda *_: pathlib.Path(%r).write_text('seen'))
            signal.signal(signal.SIGINT, signal.SIG_IGN)
            child = subprocess.Popen([sys.executable, '-c', %r])
            deadline = time.monotonic() + 3
            while not pathlib.Path(%r).exists() and time.monotonic() < deadline:
                time.sleep(.01)
            pathlib.Path(%r).write_text(json.dumps([os.getpid(), child.pid]))
            time.sleep(60)
        """) % (str(sdk_pid_file), str(term_seen), descendant,
                   str(descendant_ready), str(ready))
        caller_code = (
            "import importlib.util,sys;"
            "s=importlib.util.spec_from_file_location('sdk',%r);"
            "m=importlib.util.module_from_spec(s);s.loader.exec_module(m);"
            "sys.exit(m.run_stage([sys.executable,'-c',%r],30,'upload'))"
        ) % (str(MODULE), fake)
        caller = subprocess.Popen([sys.executable, '-c', caller_code],
                                  start_new_session=True, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        try:
            self.wait_for_file(ready)
            sdk_pid, descendant_pid = json.loads(ready.read_text())
            caller.terminate()
            self.wait_for_file(term_seen)  # Deterministically inside teardown.
            caller.send_signal(signal.SIGINT)
            caller.send_signal(signal.SIGTERM)
            result = caller.wait(timeout=8)
            self.assertNotEqual(result, 0)
            with self.assertRaises(ProcessLookupError):
                os.kill(sdk_pid, 0)  # The SDK root was reaped, not just signaled.
            self.assert_no_live_process(descendant_pid)
            self.assertEqual(result, 143)
        finally:
            if caller.poll() is None:
                self.stop_fake_group(caller.pid)
                caller.wait(timeout=3)
            if sdk_pid_file.exists():
                self.stop_fake_group(int(sdk_pid_file.read_text()))
            caller.communicate(timeout=3)

    def test_cancellation_after_spawn_before_handle_return_leaves_no_sdk(self):
        ready = self.root / "spawned-sdk.pid"
        created = self.root / "popen-created.pid"
        fake = ("import os,pathlib,time;pathlib.Path(%r).write_text(str(os.getpid()));"
                "time.sleep(60)") % str(ready)
        caller_code = dedent("""
            import importlib.util,os,pathlib,signal,subprocess,sys,time
            spec=importlib.util.spec_from_file_location('sdk',%r)
            module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
            original_popen=subprocess.Popen
            def spawn_then_cancel(*args, **kwargs):
                worker=original_popen(*args, **kwargs)
                pathlib.Path(%r).write_text(str(worker.pid))
                deadline=time.monotonic()+3
                while not pathlib.Path(%r).exists() and time.monotonic()<deadline:
                    time.sleep(.01)
                os.kill(os.getpid(), signal.SIGTERM)
                return worker
            module.subprocess.Popen=spawn_then_cancel
            sys.exit(module.run_stage([sys.executable,'-c',%r],30,'upload'))
        """) % (str(MODULE), str(created), str(ready), fake)
        caller = subprocess.Popen([sys.executable, '-c', caller_code],
                                  start_new_session=True, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        try:
            self.wait_for_file(created)
            result = caller.wait(timeout=4)
            self.assertNotEqual(result, 0)
            with self.assertRaises(ProcessLookupError):
                os.kill(int(created.read_text()), 0)
            self.assertEqual(result, 143)
        finally:
            if caller.poll() is None:
                self.stop_fake_group(caller.pid)
                caller.wait(timeout=3)
            if created.exists():
                self.stop_fake_group(int(created.read_text()))
            caller.communicate(timeout=3)

    def test_missing_dsym_is_reported_without_upload_or_fake_output(self):
        calls = []
        self.assertEqual(symbols.upload_symbols("/sdk/upload-symbols", "test-app",
                                                [self.root / "missing"],
                                                lambda *args: calls.append(args)), 0)
        self.assertEqual(calls, [])

    def test_consumer_phase_retains_debug_policy_and_both_required_dsyms(self):
        project = Path(__file__).parents[2] / "apps/consumer/ios/Runner.xcodeproj/project.pbxproj"
        source = project.read_text()
        self.assertIn("Debug*", source)
        self.assertIn("App.framework.dSYM", source)
        self.assertIn("${DWARF_DSYM_FILE_NAME}", source)
        self.assertIn("upload_crashlytics_symbols.py", source)
        self.assertNotIn("outputPaths = (\\n\\t\\t\\t\\tcrashlytics", source)


if __name__ == "__main__":
    unittest.main()

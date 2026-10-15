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

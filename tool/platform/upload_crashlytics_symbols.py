#!/usr/bin/env python3
"""Keep required Crashlytics validation/uploads synchronous and bounded."""

import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

VALIDATION_TIMEOUT_SECONDS = 30
UPLOAD_TIMEOUT_SECONDS = 180


def stop_worker(worker):
    try:
        os.killpg(worker.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        worker.wait(timeout=5)
    except subprocess.TimeoutExpired:
        pass
    # The root can exit before one of its child processes. Its isolated process
    # group remains owned by this SDK invocation until every member has exited.
    try:
        os.killpg(worker.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    worker.wait()


def run_stage(arguments, timeout_seconds, stage):
    """Return SDK failure unchanged; a timeout is a failure, never an upload pass."""
    worker = None
    cancellation = None

    def interrupted(number, _frame):
        # Never unwind Popen before it returns the owned handle, or interrupt
        # TERM/grace/KILL/reaping. Repeated signals retain the first reason.
        nonlocal cancellation
        if cancellation is None:
            cancellation = number

    previous = {}
    try:
        # Install both handlers before a worker can exist. A signal arriving
        # inside Popen is recorded and handled as soon as the handle is owned.
        for number in [signal.SIGTERM, signal.SIGINT]:
            previous[number] = signal.signal(number, interrupted)
        if cancellation is not None:
            return 128 + cancellation
        try:
            worker = subprocess.Popen(arguments, start_new_session=True)
        except OSError:
            print("Crashlytics %s could not start." % stage, file=sys.stderr)
            return 128 + cancellation if cancellation is not None else 1
        deadline = time.monotonic() + timeout_seconds
        while True:
            if cancellation is not None:
                stop_worker(worker)
                print("Crashlytics %s interrupted; symbol upload is incomplete." % stage,
                      file=sys.stderr)
                return 128 + cancellation
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                stop_worker(worker)
                print("Crashlytics %s timed out; symbol upload is incomplete." % stage,
                      file=sys.stderr)
                return 128 + cancellation if cancellation is not None else 124
            try:
                result = worker.wait(timeout=min(.1, remaining))
            except subprocess.TimeoutExpired:
                continue
            if cancellation is not None:
                stop_worker(worker)
                return 128 + cancellation
            return result
    finally:
        try:
            if worker is not None and worker.poll() is None:
                stop_worker(worker)
        finally:
            for number, handler in previous.items():
                signal.signal(number, handler)


def upload_symbols(uploader, app_id, dsym_paths, run=run_stage):
    available = [Path(path) for path in dsym_paths if Path(path).is_dir()]
    if not available:
        print("No dSYM bundle found; no Crashlytics upload was performed.")
        return 0
    common = [str(uploader), "--build-phase"]
    validation = common + ["--validate", "-ai", app_id, "--", str(available[0])]
    result = run(validation, VALIDATION_TIMEOUT_SECONDS, "validation")
    if result:
        return result
    for path in available:
        result = run(common + ["-ai", app_id, "--", str(path)],
                     UPLOAD_TIMEOUT_SECONDS, "upload")
        if result:
            return result
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--uploader", type=Path, required=True)
    parser.add_argument("--app-id", required=True)
    parser.add_argument("--dsym", action="append", required=True)
    arguments = parser.parse_args()
    return upload_symbols(arguments.uploader, arguments.app_id, arguments.dsym)


if __name__ == "__main__":
    sys.exit(main())

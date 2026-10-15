#!/usr/bin/env python3
"""Keep required Crashlytics validation/uploads synchronous and bounded."""

import argparse
import os
from pathlib import Path
import signal
import subprocess
import sys

VALIDATION_TIMEOUT_SECONDS = 30
UPLOAD_TIMEOUT_SECONDS = 180


class StageInterrupted(Exception):
    def __init__(self, number):
        self.number = number


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
    try:
        worker = subprocess.Popen(arguments, start_new_session=True)
    except OSError:
        print("Crashlytics %s could not start." % stage, file=sys.stderr)
        return 1
    def interrupted(number, _frame):
        raise StageInterrupted(number)

    previous = {number: signal.signal(number, interrupted)
                for number in [signal.SIGTERM, signal.SIGINT]}
    try:
        try:
            return worker.wait(timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            stop_worker(worker)
            print("Crashlytics %s timed out; symbol upload is incomplete." % stage,
                  file=sys.stderr)
            return 124
        except StageInterrupted as error:
            stop_worker(worker)
            print("Crashlytics %s interrupted; symbol upload is incomplete." % stage,
                  file=sys.stderr)
            return 128 + error.number
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

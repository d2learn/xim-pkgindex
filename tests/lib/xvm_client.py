"""xvm 操作封装"""
import subprocess
import os
from tests.lib.platform_utils import subos_bin_dir


def _run(cmd: str, timeout: int = 10) -> tuple[int, str]:
    try:
        r = subprocess.run(
            ["bash", "-l", "-c", cmd],
            capture_output=True, text=True, timeout=timeout,
            env={**os.environ, "HOME": os.path.expanduser("~")}
        )
        return r.returncode, (r.stdout + r.stderr).strip()
    except subprocess.TimeoutExpired:
        return 124, "timeout"


class XvmClient:

    @staticmethod
    def info(target: str) -> dict | None:
        code, out = _run(f"xvm info {target}")
        if code != 0 or "missing" in out.lower():
            return None
        result = {}
        for line in out.splitlines():
            line = line.strip()
            if line.startswith("Program:"):
                result["program"] = line.split(":", 1)[1].strip()
            elif line.startswith("Version:"):
                result["version"] = line.split(":", 1)[1].strip()
            elif line.startswith("SPath:"):
                result["spath"] = line.split(":", 1)[1].strip()
            elif line.startswith("TPath:"):
                result["tpath"] = line.split(":", 1)[1].strip()
            elif line.startswith("Alias:"):
                result["alias"] = line.split(":", 1)[1].strip()
        return result if result else None

    @staticmethod
    def is_registered(target: str) -> bool:
        return XvmClient.info(target) is not None

    @staticmethod
    def shim_exists(target: str) -> bool:
        return os.path.isfile(os.path.join(subos_bin_dir(), target))

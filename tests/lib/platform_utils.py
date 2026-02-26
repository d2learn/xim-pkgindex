"""平台检测与路径工具"""
import os
import platform
import functools
import pytest


def current_platform() -> str:
    s = platform.system()
    return {"Linux": "linux", "Darwin": "macosx", "Windows": "windows"}.get(s, s.lower())


def current_arch() -> str:
    m = platform.machine()
    return {"AMD64": "x86_64", "aarch64": "arm64"}.get(m, m)


def xlings_home() -> str:
    return os.environ.get("XLINGS_HOME", os.path.expanduser("~/.xlings"))


def subos_bin_dir() -> str:
    return os.path.join(xlings_home(), "subos", "current", "bin")


def xpkgs_dir() -> str:
    return os.path.join(xlings_home(), "data", "xpkgs")


def pkgindex_dir() -> str:
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    return os.path.join(root, "pkgs")


def project_root() -> str:
    return os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def skip_if_not(plat: str):
    """跳过不匹配的平台"""
    return pytest.mark.skipif(
        current_platform() != plat,
        reason=f"仅在 {plat} 上运行"
    )

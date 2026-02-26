"""pytest 全局配置与 fixtures"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def pytest_configure(config):
    for mark in ["static", "index", "isolation", "lifecycle", "verify"]:
        config.addinivalue_line("markers", f"{mark}: L{['static','index','isolation','lifecycle','verify'].index(mark)} 测试层级")

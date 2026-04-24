package = {
    spec = "1",

    name = "vcstool",
    description = "Version control system tool for multiple repos (ROS vcstool)",
    homepage = "https://github.com/dirk-thomas/vcstool",
    maintainers = {"Dirk Thomas"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/dirk-thomas/vcstool",
    docs = "https://github.com/dirk-thomas/vcstool/blob/master/README.rst",

    type = "package",
    archs = {"x86_64", "arm64"},
    status = "stable",
    categories = {"ros", "vcs", "robotics"},
    keywords = {"ros", "vcstool", "vcs", "git", "robotics", "ros2"},

    programs = {"vcs"},
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {"python"},
            ["latest"] = { ref = "0.3.0" },
            ["0.3.0"] = {
                url = "https://files.pythonhosted.org/packages/6c/d5/4aca2c05481a0fb74bd2660b14b0dd0ea975e4f38bc150511a64c55af986/vcstool-0.3.0-py3-none-any.whl",
                sha256 = "ad73309e83b67344efb1f6cf9f556b2d75e297b4b137f643378ba75f930a6ecb",
            },
        },
        macosx = {
            deps = {"python"},
            ["latest"] = { ref = "0.3.0" },
            ["0.3.0"] = {
                url = "https://files.pythonhosted.org/packages/6c/d5/4aca2c05481a0fb74bd2660b14b0dd0ea975e4f38bc150511a64c55af986/vcstool-0.3.0-py3-none-any.whl",
                sha256 = "ad73309e83b67344efb1f6cf9f556b2d75e297b4b137f643378ba75f930a6ecb",
            },
        },
        windows = {
            deps = {"python"},
            ["latest"] = { ref = "0.3.0" },
            ["0.3.0"] = {
                url = "https://files.pythonhosted.org/packages/6c/d5/4aca2c05481a0fb74bd2660b14b0dd0ea975e4f38bc150511a64c55af986/vcstool-0.3.0-py3-none-any.whl",
                sha256 = "ad73309e83b67344efb1f6cf9f556b2d75e297b4b137f643378ba75f930a6ecb",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

-- Python venv lays out its entry-point scripts under "bin/" on POSIX and
-- "Scripts/" on Windows; select the right subdir instead of hardcoding.
local function __venv_bindir()
    local sub = is_host("windows") and "Scripts" or "bin"
    return path.join(pkginfo.install_dir(), sub)
end

function install()
    os.tryrm(pkginfo.install_dir())

    -- create venv and install vcstool into it (standard pip/pipx approach)
    system.exec(string.format([[python3 -m venv "%s"]], pkginfo.install_dir()))
    local venv_pip = path.join(__venv_bindir(), "pip")
    -- vcstool uses pkg_resources which was removed in setuptools >= 71
    system.exec(string.format([["%s" install "setuptools<71"]], venv_pip))
    system.exec(string.format([["%s" install "%s"]], venv_pip, pkginfo.install_file()))

    return true
end

function config()
    xvm.add("vcs", { bindir = __venv_bindir() })
    return true
end

function uninstall()
    xvm.remove("vcs")
    return true
end

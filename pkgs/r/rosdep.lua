package = {
    spec = "1",

    name = "rosdep",
    description = "ROS dependency management tool",
    homepage = "https://docs.ros.org/en/independent/api/rosdep/html/",
    maintainers = {"Open Source Robotics Foundation"},
    licenses = {"BSD"},
    repo = "https://github.com/ros-infrastructure/rosdep",
    docs = "https://docs.ros.org/en/independent/api/rosdep/html/",

    type = "package",
    archs = {"x86_64", "arm64"},
    status = "stable",
    categories = {"ros", "dependency", "robotics"},
    keywords = {"ros", "rosdep", "dependency", "robotics", "ros2"},

    programs = {"rosdep", "rosdep-source"},
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {"python"},
            ["latest"] = { ref = "0.26.0" },
            ["0.26.0"] = {
                url = "https://files.pythonhosted.org/packages/bd/c1/15c5c296f41e6a290e6c3515316b2676be580c66b10e26372200a0ecbdd7/rosdep-0.26.0-py3-none-any.whl",
                sha256 = "3b666053929e802afb70870c694d4095fff355a2c20e07abee4e1390b9f53925",
            },
        },
        macosx = {
            deps = {"python"},
            ["latest"] = { ref = "0.26.0" },
            ["0.26.0"] = {
                url = "https://files.pythonhosted.org/packages/bd/c1/15c5c296f41e6a290e6c3515316b2676be580c66b10e26372200a0ecbdd7/rosdep-0.26.0-py3-none-any.whl",
                sha256 = "3b666053929e802afb70870c694d4095fff355a2c20e07abee4e1390b9f53925",
            },
        },
        windows = {
            deps = {"python"},
            ["latest"] = { ref = "0.26.0" },
            ["0.26.0"] = {
                url = "https://files.pythonhosted.org/packages/bd/c1/15c5c296f41e6a290e6c3515316b2676be580c66b10e26372200a0ecbdd7/rosdep-0.26.0-py3-none-any.whl",
                sha256 = "3b666053929e802afb70870c694d4095fff355a2c20e07abee4e1390b9f53925",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")
import("xim.libxpkg.system")

-- Python venv lays out its entry-point scripts under "bin/" on POSIX and
-- "Scripts/" on Windows; select the right subdir instead of hardcoding.
local function __venv_bindir()
    local sub = is_host("windows") and "Scripts" or "bin"
    return path.join(pkginfo.install_dir(), sub)
end

function install()
    os.tryrm(pkginfo.install_dir())

    -- create venv and install rosdep into it (standard pip/pipx approach)
    system.exec(string.format([[python3 -m venv "%s"]], pkginfo.install_dir()))
    system.exec(string.format(
        [["%s" install "%s"]],
        path.join(__venv_bindir(), "pip"),
        pkginfo.install_file()
    ))

    return true
end

function config()
    local bindir = __venv_bindir()
    xvm.add("rosdep", { bindir = bindir })
    xvm.add("rosdep-source", { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove("rosdep")
    xvm.remove("rosdep-source")
    return true
end

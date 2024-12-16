package = {
    -- base info

    homepage = "https://github.com/d2learn/xim-pkgindex",

    name = "cpp",
    description = "C++ language toolchain",
    maintainers = "xim team",
    contributors = "https://github.com/d2learn/xim-pkgindex/graphs/contributors",

    -- xim pkg info
    type = "auto-config",
    status = "stable", -- dev, stable, deprecated
    categories = {"plang", "compiler", "c"},

    xpm = {
        windows = {
            deps = {"msvc"},
            ["latest"] = { ref = "msvc" },
            ["msvc"] = {},
        },
        ubuntu = {
            deps = {"gcc"},
            ["latest"] = { ref = "gnu" },
            ["gnu"] = {},
        },
        debain = { ref = "ubuntu" },
    },
}

import("core.tool.toolchain")

import("xim.base.runtime")
import("xim.xuninstall")


local pkginfo = runtime.get_pkginfo()

function installed()
    if pkginfo.version == "msvc" then
        return toolchain.load("mingw"):check()
    elseif pkginfo.version == "gnu" then
        local output = os.iorun("gcc --version")
        return string.find(output, "gcc", 1, true) ~= nil
    else
        return true
    end
end

function install()
    -- install by deps
    return true
end

function uninstall()
    if pkginfo.version == "msvc" then
        xuninstall("msvc")
    elseif pkginfo.version == "gnu" then
        xuninstall("gcc")
    end
    return true
end
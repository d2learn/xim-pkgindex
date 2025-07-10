package = {
    -- base info

    homepage = "https://github.com/d2learn/xim-pkgindex",

    name = "cpp",
    description = "C++ language toolchain",
    maintainers = "xim team",
    contributors = "https://github.com/d2learn/xim-pkgindex/graphs/contributors",

    -- xim pkg info
    type = "config",
    status = "stable", -- dev, stable, deprecated
    categories = {"plang", "compiler", "c"},

    xpm = {
        windows = {
            deps = {"msvc@2022"},
            ["latest"] = { ref = "msvc" },
            ["msvc"] = {},
        },
        linux = {
            deps = {"gcc"},
            ["latest"] = { ref = "gnu" },
            ["gnu"] = {},
        },
        macosx = {
            deps = { "brew" },
            ["latest"] = { },
        },
    },
}

import("core.tool.toolchain")

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.xuninstall")

function installed()
    if is_host("macosx") then
        local output = os.iorun("gcc --version")
        if not output then
            output = os.iorun("clang --version")
        end
        return output ~= nil
    elseif pkginfo.version() == "msvc" then
        return toolchain.load("msvc"):check() == "2022"
    elseif pkginfo.version() == "gnu" then
        local output = os.iorun("gcc --version")
        return string.find(output:trim(), "gcc", 1, true) ~= nil
    else
        return true
    end
end

function install()
    if is_host("macosx") then
        system.exec("brew install gcc", { retry = 3 })
    end
    -- install by deps
    return true
end

function uninstall()
    if is_host("macosx") then
        system.exec("brew uninstall gcc")
    elseif pkginfo.version() == "msvc" then
        xuninstall("msvc")
    elseif pkginfo.version() == "gnu" then
        xuninstall("gcc")
    end
    return true
end
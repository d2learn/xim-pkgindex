package = {
    spec = "1",
    -- base info

    homepage = "https://github.com/d2learn/xim-pkgindex",

    name = "cpp",
    description = "C++ language toolchain",
    maintainers = {"xim team"},
    contributors = "https://github.com/d2learn/xim-pkgindex/graphs/contributors",

    -- xim pkg info
    type = "config",
    status = "stable", -- dev, stable, deprecated
    categories = { "plang", "compiler", "c" },

    xpm = {
        windows = {
            deps = { "mingw-w64@13" },
            ["latest"] = { ref = "mingw" },
            ["mingw"] = {},
            ["msvc"] = {},
        },
        linux = {
            deps = { "gcc" },
            ["latest"] = { ref = "gnu" },
            ["gnu"] = {},
        },
        macosx = {
            deps = { "brew" },
            ["latest"] = {},
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.pkgmanager")

local function iorun(cmd)
    local f = io.popen(cmd)
    if not f then return "" end
    local output = f:read("*a")
    f:close()
    return output or ""
end

function installed()
    if os.host() == "macosx" then
        local output = iorun("gcc --version")
        if not output then
            output = iorun("clang --version")
        end
        return output ~= nil
    elseif pkginfo.version() == "msvc" then
        local msvc_path = [[C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC]]
        return os.isdir(msvc_path)
    elseif pkginfo.version() == "mingw" or pkginfo.version() == "gnu" then
        local output = iorun("gcc --version")
        return string.find(output:match("^%s*(.-)%s*$"), "gcc", 1, true) ~= nil
    else
        return true
    end
end

function install()
    if os.host() == "macosx" then
        pkgmanager.install("gcc")
    elseif pkginfo.version() == "msvc" then
        pkgmanager.install("msvc@2022")
    else
        -- install by deps
    end
    return true
end

function uninstall()
    if os.host() == "macosx" then
        pkgmanager.uninstall("gcc")
    elseif pkginfo.version() == "msvc" then
        pkgmanager.uninstall("msvc@2022")
    elseif pkginfo.version() == "mingw" then
        pkgmanager.uninstall("mingw-w64@13")
    elseif pkginfo.version() == "gnu" then
        pkgmanager.uninstall("gcc")
    end
    return true
end

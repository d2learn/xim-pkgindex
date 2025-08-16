package = {
    -- base info
    name = "xvm",
    description = "a simple and generic version management tool",

    authors = "sunrisepeak",
    maintainers = "d2learn",
    contributors = "https://github.com/d2learn/xlings/graphs/contributors",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xlings",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "version-management"},
    keywords = {"rust", "cross-platform", "version-management"},

    xpm = {
        windows = {
            ["latest"] = { ref = "0.0.4" },
            ["0.0.2"] = "XLINGS_RES",
            ["0.0.3"] = "XLINGS_RES",
            ["0.0.4"] = "XLINGS_RES",
            ["0.0.5"] = "XLINGS_RES",
        },
        linux = {
            ["latest"] = { ref = "0.0.4" },
            ["0.0.2"] = "XLINGS_RES",
            ["0.0.3"] = "XLINGS_RES",
            ["0.0.4"] = "XLINGS_RES",
            ["0.0.5"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.0.4" },
            ["0.0.2"] = "XLINGS_RES",
            ["0.0.3"] = "XLINGS_RES",
            ["0.0.4"] = "XLINGS_RES",
            ["0.0.5"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.system")

local bindir = system.bindir()

local xvm_file = {
    windows = "xvm.exe",
    linux = "xvm",
    macosx = "xvm"
}

local xvm_shim_file = {
    windows = "xvm-shim.exe",
    linux = "xvm-shim",
    macosx = "xvm-shim"
}

function installed()
    return os.isfile(path.join(bindir, xvm_file[os.host()]))
end

function install()
    os.mv(xvm_file[os.host()], bindir)
    os.mv(xvm_shim_file[os.host()], bindir)
    return true
end

function uninstall()
    -- remove cache files
    os.tryrm(xvm_file[os.host()])
    os.tryrm(xvm_shim_file[os.host()])
    -- remove xvm and xvm-shim from bindir
    os.tryrm(path.join(bindir, xvm_file[os.host()]))
    os.tryrm(path.join(bindir, xvm_shim_file[os.host()]))
    return true
end

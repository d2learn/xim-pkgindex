package = {
    -- base info
    name = "xvm",
    description = "a simple and generic version management tool",

    authors = "sunrisepeak",
    maintainers = "d2learn",
    contributors = "https://github.com/d2learn/xlings/graphs/contributors",
    license = "Apache-2.0",
    repo = "https://github.com/d2learn/xlings",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "version-management"},
    keywords = {"rust", "cross-platform", "version-management"},

    xpm = {
        windows = {
            ["latest"] = { ref = "dev" },
            ["dev"] = {
                url = "%.zip$", -- url pattern
                github_release_tag = "xvm-dev",
            }
        },
        linux = {
            ["latest"] = { ref = "dev" },
            ["dev"] = {
                url = "%.tar.gz$", -- url pattern
                github_release_tag = "xvm-dev",
            }
        },
        debian = { ref = "linux" },
        ubuntu = { ref = "linux" },
        archlinux = { ref = "linux" },
        manjaro = { ref = "linux" },
    },
}

import("platform")
import("xim.base.runtime")

local bindir = platform.get_config_info().bindir
local pkginfo = runtime.get_pkginfo()

local xvm_file = {
    windows = "xvm.exe",
    linux = "xvm",
}

local xvm_shim_file = {
    windows = "xvm-shim.exe",
    linux = "xvm-shim",
}

function installed()
    return os.iorun("xvm --version") ~= nil
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

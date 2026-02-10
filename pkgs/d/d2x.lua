package = {
    -- base info
    name = "d2x",
    description = "xlings's d2x tool",

    authors = "Sunrisepeak",
    licenses = "Apache 2.0",
    repo = "https://github.com/d2learn/d2x",

    -- xim pkg info
    type = "package",

    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"d2x", "tool", "mcpp" },
    keywords = {"d2x", "tool", "mcpp" },

    programs = { "d2x" },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        windows = {
            ["latest"] = { ref = "0.1.2" },
            ["0.1.2"] = "XLINGS_RES",
            ["0.1.1"] = "XLINGS_RES",
        },
        linux = {
            deps = { "glibc", "openssl@3.1.5" },
            ["latest"] = { ref = "0.1.2" },
            ["0.1.2"] = "XLINGS_RES",
            ["0.1.1"] = "XLINGS_RES",
            ["0.1.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "0.1.2" },
            ["0.1.2"] = "XLINGS_RES",
        }
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

function install()
    local d2xdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(d2xdir, pkginfo.install_dir())
    return true
end

function config()
    local sysroot_dir = system.subos_sysrootdir()

    d2x_config = {}

    if is_host("linux") then
        d2x_config.envs = {
            LD_LIBRARY_PATH = path.join(sysroot_dir, "lib"),
        }
    end

    xvm.add("d2x", d2x_config)
    return true
end

function uninstall()
    xvm.remove("d2x")
    return true
end
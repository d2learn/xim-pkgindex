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
        linux = {
            deps = { "glibc", "openssl" },
            ["latest"] = { ref = "0.1.0" },
            ["0.1.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    local d2xdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.mv(d2xdir, pkginfo.install_dir())
    xvm.add("d2x")
    return true
end

function uninstall()
    xvm.remove("d2x")
    return true
end
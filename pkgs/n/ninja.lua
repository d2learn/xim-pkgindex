package = {
    spec = "1",
    -- base info
    name = "ninja",
    description = "a small build system with a focus on speed",

    maintainers = {"https://github.com/ninja-build/ninja/graphs/contributors"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/ninja-build/ninja",
    docs = "https://ninja-build.org/manual.html",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"build-system", "ninja"},
    keywords = {"ninja", "build-system", "cross-platform"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "1.12.1" },
            ["1.12.1"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "1.12.1" },
            ["1.12.1"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "1.12.1" },
            ["1.12.1"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    os.mv("ninja", pkginfo.install_dir())
    return true
end

function config()
    xvm.add("ninja")
    return true
end

function uninstall()
    xvm.remove("ninja")
    return true
end
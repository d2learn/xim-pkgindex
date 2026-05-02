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
            -- Runtime deps. ninja prebuilt is dynamically linked
            -- (INTERP=/lib64/ld-linux-x86-64.so.2) and pulls libc/libm
            -- from glibc plus libstdc++.so.6 + libgcc_s.so.1 from gcc's
            -- runtime libs.
            deps = {
                runtime = { "xim:glibc@2.39", "xim:gcc@15.1.0" },
            },
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
    -- XLINGS_RES ships the platform-native binary: `ninja` on Linux/macOS,
    -- `ninja.exe` on Windows. Handle both forms so the move doesn't fail
    -- on a fresh Windows install where the source file has the extension.
    local exe = is_host("windows") and "ninja.exe" or "ninja"
    os.mv(exe, path.join(pkginfo.install_dir(), exe))
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
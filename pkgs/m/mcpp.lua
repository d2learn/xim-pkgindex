package = {
    spec = "1",

    name = "mcpp",
    description = "A modern C++ build tool with module support, dependency/toolchain management, package indexing, and packaging",

    authors = {"sunrisepeak"},
    maintainers = {"https://github.com/mcpp-community/mcpp/graphs/contributors"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/mcpp-community/mcpp",
    homepage = "https://github.com/mcpp-community/mcpp",
    docs = "https://github.com/mcpp-community/mcpp#readme",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "dev", -- 0.0.x: upstream is pre-1.0, expect breaking changes
    categories = {"build-tool", "cpp"},
    keywords = {"cpp", "c++", "build", "module", "package-manager"},

    programs = { "mcpp" },

    xvm_enable = true,

    -- Mirrored at xlings-res/mcpp (byte-identical to upstream
    -- mcpp-community/mcpp release artifacts, just renamed to
    -- xlings-res convention `mcpp-<ver>-<platform>-<arch>.<ext>`).
    --
    -- XLINGS_RES sentinel resolves to:
    --   GLOBAL → github.com/xlings-res/mcpp/releases/download/<ver>/...
    --   CN     → gitcode.com/xlings-res/mcpp/releases/download/<ver>/...
    --
    -- The Linux tarball is a fully-static ELF (no .interp, no
    -- DT_NEEDED) plus a thin shell launcher at the bundle root —
    -- zero runtime deps. xvm registers `bindir = <install>/bin`
    -- so the real ELF is invoked directly (the top-level shell
    -- launcher is only used when running from the bundle root).
    xpm = {
        linux = {
            url_template = "https://github.com/mcpp-community/mcpp/releases/download/v{version}/mcpp-{version}-linux-x86_64.tar.gz",
            ["latest"] = { ref = "0.0.1" },
            ["0.0.1"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

function install()
    -- Tarball top-level layout (no enclosing version-named dir):
    --   ./mcpp          (POSIX shell launcher → exec bin/mcpp)
    --   ./bin/mcpp      (static ELF)
    --   ./LICENSE
    --   ./README.md
    -- Extract directly into install_dir so xvm's bindir=<install>/bin
    -- finds the real binary.
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())
    system.exec(string.format(
        [[tar -xzf "%s" -C "%s"]],
        pkginfo.install_file(), pkginfo.install_dir()
    ))
    return true
end

function config()
    xvm.add("mcpp", { bindir = path.join(pkginfo.install_dir(), "bin") })
    return true
end

function uninstall()
    xvm.remove("mcpp")
    return true
end

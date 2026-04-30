package = {
    spec = "1",
    homepage = "https://www.gnu.org/software/make",
    -- base info
    name = "make",
    description = "GNU Make — tool which controls the generation of executables from source files",

    authors = {"GNU"},
    licenses = {"GPL-3.0+"},
    repo = "https://git.savannah.gnu.org/cgit/make.git",
    docs = "https://www.gnu.org/software/make/manual",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"make", "gnu", "build-system"},
    keywords = {"make", "gnu", "makefile", "build-system"},

    -- xvm: xlings version management
    xvm_enable = true,

    programs = { "make", "gmake" },

    xpm = {
        linux = {
            ["latest"] = { ref = "4.3" },
            ["4.3"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    -- XLINGS_RES ships a musl-static tarball (no glibc dependency, so no
    -- elfpatch step is needed). It extracts to `make-<ver>-linux-x86_64/`.
    local srcdir = pkginfo.install_file():replace(".tar.gz", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    local root = "make@" .. pkginfo.version()
    xvm.add("make", { bindir = bindir })
    -- gmake is a symlink to `make` in the same bindir; tie its lifecycle to make@<ver>.
    xvm.add("gmake", { bindir = bindir, binding = root })
    return true
end

function uninstall()
    xvm.remove("make")
    xvm.remove("gmake")
    return true
end

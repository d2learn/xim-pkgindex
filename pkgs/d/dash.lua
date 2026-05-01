package = {
    spec = "1",
    homepage = "http://gondor.apana.org.au/~herbert/dash/",
    -- base info
    name = "dash",
    description = "Debian Almquist Shell — small POSIX-compliant shell",

    authors = {"Herbert Xu", "Debian"},
    licenses = {"BSD-3-Clause", "GPL-2.0+"},
    repo = "https://git.kernel.org/pub/scm/utils/dash/dash.git",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"shell", "cli", "posix"},
    keywords = {"dash", "shell", "posix", "ash", "debian"},

    -- xvm: xlings version management
    xvm_enable = true,

    programs = { "dash" },

    -- Upstream is source-only on git.kernel.org. The XLINGS_RES tarball is
    -- a fully-static musl-libc build (no glibc runtime dependency), so the
    -- binary is portable across Linux distributions.
    --   Source:  https://git.kernel.org/.../dash.git/snapshot/dash-<ver>.tar.gz
    --   Mirror:  github.com/xlings-res/dash, gitcode.com/xlings-res/dash
    xpm = {
        linux = {
            ["latest"] = { ref = "0.5.13.3" },
            ["0.5.13.3"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    -- XLINGS_RES tarball expands to `dash-<ver>-linux-x86_64/` — same
    -- layout as the make xpkg, so reuse the same staging idiom.
    local srcdir = pkginfo.install_file():replace(".tar.gz", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    xvm.add("dash", { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove("dash")
    return true
end

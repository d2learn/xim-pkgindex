package = {
    spec = "1",

    name = "proot",
    description = "Userspace chroot, mount --bind, and binfmt_misc — no root required",

    homepage = "https://proot-me.github.io",
    contributors = "https://github.com/proot-me/proot/graphs/contributors",
    licenses = {"GPL-2.0-or-later"},
    repo = "https://github.com/proot-me/proot",
    docs = "https://proot-me.github.io",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"sandbox", "container", "tool"},
    keywords = {"proot", "chroot", "sandbox", "userspace", "rootless"},

    programs = {"proot"},
    xvm_enable = true,

    -- Mirrored at xlings-res/proot, built from upstream proot-me/proot
    -- v5.4.0 source in Alpine 3.20 (musl 1.2.5, gcc 13.2). Single
    -- statically-linked ELF (`bin/proot`) — zero runtime deps. Upstream
    -- ships no v5.4.0 prebuilt; the only release-attached artifact for
    -- proot is the v5.3.0 glibc-static binary, which is why we mirror.
    --
    -- XLINGS_RES sentinel resolves to:
    --   GLOBAL → github.com/xlings-res/proot/releases/download/<ver>/...
    --   CN     → gitcode.com/xlings-res/proot/releases/download/<ver>/...
    xpm = {
        linux = {
            url_template = "https://github.com/proot-me/proot/archive/v{version}/proot-{version}.tar.gz",
            ["latest"] = { ref = "5.4.0" },
            ["5.4.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    os.tryrm(pkginfo.install_dir())
    local prootdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.mv(prootdir, pkginfo.install_dir())
    return true
end

function config()
    xvm.add("proot", { bindir = path.join(pkginfo.install_dir(), "bin") })
    return true
end

function uninstall()
    xvm.remove("proot")
    return true
end

package = {
    spec = "1",

    name = "bwrap",
    description = "Bubblewrap — unprivileged sandboxing tool (setuid-less namespace sandbox)",

    homepage = "https://github.com/containers/bubblewrap",
    contributors = "https://github.com/containers/bubblewrap/graphs/contributors",
    licenses = {"LGPL-2.0-or-later"},
    repo = "https://github.com/containers/bubblewrap",
    docs = "https://github.com/containers/bubblewrap#readme",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"sandbox", "container", "tool"},
    keywords = {"bwrap", "bubblewrap", "sandbox", "namespace", "rootless"},

    -- `bubblewrap` is the canonical upstream name; `bwrap` is the
    -- compiled binary. We expose both — alias `bubblewrap → bwrap`.
    programs = {"bwrap", "bubblewrap"},
    aliases = {"bubblewrap"},
    xvm_enable = true,

    -- Mirrored at xlings-res/bwrap, built from upstream
    -- containers/bubblewrap v0.11.2 source in Alpine 3.20
    -- (musl 1.2.5, gcc 13.2, libcap 2.78). Single statically-linked
    -- ELF (`bin/bwrap`, ~137 KB stripped). Upstream releases source
    -- only — no prebuilt artifact ships for bwrap, hence the mirror.
    --
    -- Runtime: bwrap is installed setuid root (chmod 4755) so it can
    -- create user namespaces on kernels that disable
    -- unprivileged_userns_clone. Same pattern as code.lua's
    -- chrome-sandbox.
    --
    -- XLINGS_RES sentinel resolves to:
    --   GLOBAL → github.com/xlings-res/bwrap/releases/download/<ver>/...
    --   CN     → gitcode.com/xlings-res/bwrap/releases/download/<ver>/...
    xpm = {
        linux = {
            url_template = "https://github.com/containers/bubblewrap/releases/download/v{version}/bubblewrap-{version}.tar.xz",
            ["latest"] = { ref = "0.11.2" },
            ["0.11.2"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    os.tryrm(pkginfo.install_dir())
    local bwrapdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.mv(bwrapdir, pkginfo.install_dir())

    -- setuid bwrap so it can create user namespaces on kernels that
    -- disable unprivileged_userns_clone (same pattern as code.lua's
    -- chrome-sandbox).
    local bwrap = path.join(pkginfo.install_dir(), "bin", "bwrap")
    if os.isfile(bwrap) then
        log.info("Setting bwrap setuid root (sudo required)...")
        os.exec("sudo chown root:root " .. bwrap)
        os.exec("sudo chmod 4755 " .. bwrap)
    end

    return true
end

function config()
    xvm.add("bwrap", { bindir = path.join(pkginfo.install_dir(), "bin") })
    xvm.add("bubblewrap", { bindir = path.join(pkginfo.install_dir(), "bin"), alias = "bwrap" })
    return true
end

function uninstall()
    xvm.remove("bwrap")
    xvm.remove("bubblewrap")
    return true
end

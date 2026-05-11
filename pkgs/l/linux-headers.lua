package = {
    spec = "1",
    -- base info
    name = "linux-headers",
    description = "Linux Kernel Header",

    licenses = {"GPL"},
    repo = "https://github.com/torvalds/linux",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            -- TODO: Temporary workaround for pkgmanager.install() install-dir resolution issue.
            deps = {
                "scode:linux-headers@5.11.1",
            },
            ["latest"] = { ref = "5.11.1" },
            ["5.11.1"] = { },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.pkgmanager")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

function install()
    -- This package is a thin delegator: the real header payload is provided
    -- by `scode:linux-headers@<version>` (declared in deps), which xlings
    -- installs first. Without writing anything into our own install_dir,
    -- xlings's "installed?" probe (which checks install_dir for content)
    -- always reports `installed: no`, causing every dependent package
    -- (xim:gcc, xim:glibc, fromsource:gcc, ...) to re-trigger this install
    -- + config on every fresh dep resolution, which in turn re-copies the
    -- whole kernel-header tree into the subos sysroot via config().
    --
    -- Drop a tiny stamp file so install_dir is non-empty and the package
    -- registers as installed.
    local install_dir = pkginfo.install_dir()
    if not os.isdir(install_dir) then os.mkdir(install_dir) end
    io.writefile(path.join(install_dir, ".xim-installed"), pkginfo.version())
    return true
end

function config()
    local sysroot_usrdir = path.join(system.subos_sysrootdir(), "usr")
    if not os.isdir(sysroot_usrdir) then os.mkdir(sysroot_usrdir) end

    -- Skip the recursive header copy if a previous install of the same
    -- version already placed it in the subos sysroot. The stamp lives
    -- next to the copied tree so that switching subos / wiping sysroot
    -- correctly invalidates it.
    local stamp = path.join(sysroot_usrdir, ".linux-headers-" .. pkginfo.version() .. ".stamp")
    if os.isfile(stamp) then
        log.debug("Linux headers already in subos rootfs (stamp present), skipping copy.")
    else
        local scodedir = pkginfo.install_dir("scode:linux-headers", pkginfo.version())
        log.info("Copying linux header files to subos rootfs ...")
        __cp_tree_proot_safe(
            path.join(scodedir, "include"),
            path.join(sysroot_usrdir, "include")
        )
        io.writefile(stamp, pkginfo.version())
    end

    xvm.add("linux-headers")

    return true
end

-- Per-entry walk that replaces xmake's recursive `os.cp` (and `cp -r`).
-- Each iteration issues a single absolute-path syscall — proot's path
-- translator handles those correctly. The previous recursive copy tripped
-- a proot bug where dir-fd-relative openat() issued mid-recursion was
-- mistranslated when the destination subtree already existed in the
-- subos sysroot.
--
-- Symlinks are preserved (readlink + os.ln), matching `symlink = true`
-- in the prior os.cp call.
function __cp_tree_proot_safe(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    os.mkdir(dst_dir)
    for _, src in ipairs(os.filedirs(path.join(src_dir, "**"))) do
        local rel = path.relative(src, src_dir)
        local dst = path.join(dst_dir, rel)
        os.mkdir(path.directory(dst))
        if os.islink(src) then
            os.tryrm(dst)
            os.ln(os.readlink(src), dst)
        elseif not os.isdir(src) then
            os.cp(src, dst)
        end
    end
end

function uninstall()
    xvm.remove("linux-headers")
    return true
end
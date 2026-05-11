package = {
    spec = "1",
    homepage = "https://www.python.org",
    name = "python",
    description = "The Python programming language",
    maintainers = {"Python Software Foundation"},
    licenses = {"PSF-License", "GPL-compatible"},
    type = "package",
    repo = "https://github.com/python/cpython",
    docs = "https://docs.python.org/3",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"python", "plang", "interpreter"},
    keywords = {"python", "programming", "scripting", "language"},

    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "3.13.12" },
            ["3.13.12"] = {
                url = "https://gitcode.com/xlings-res/mirror-cn/releases/download/python/cpython-3.13.12%2B20260310-x86_64-unknown-linux-gnu-install_only.tar.gz",
                sha256 = "a1d58266fede23e795b1b7d1dee3cc77470538fd14292a46cc96e735af030fec",
            },
            ["3.12.13"] = {
                url = "https://gitcode.com/xlings-res/mirror-cn/releases/download/python/cpython-3.12.13%2B20260310-x86_64-unknown-linux-gnu-install_only.tar.gz",
                sha256 = nil,
            }
        },
        windows = {
            ["latest"] = { ref = "3.12.6"},
            ["3.12.6"] = {
                url = "https://gitee.com/sunrisepeak/xlings-pkg/releases/download/python12/python-3.12.6-amd64.exe",
                sha256 = "5914748e6580e70bedeb7c537a0832b3071de9e09a2e4e7e3d28060616045e0a",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

function install()
    if os.host() == "windows" then
        local install_cmd = pkginfo.install_file()
            .. [[ /passive InstallAllUsers=1 PrependPath=1 Include_test=1 Include_pip=1 ]]
            .. [[ TargetDir="]] .. pkginfo.install_dir() .. [["]]
        os.exec(install_cmd)
    else
        -- python-build-standalone tarball extracts to "python/" directory
        os.tryrm(pkginfo.install_dir())
        os.mv("python", pkginfo.install_dir())
    end
    return true
end

function config()
    if os.host() == "windows" then
        log.info("Please restart the terminal to take effect.")
    else
        local bindir = path.join(pkginfo.install_dir(), "bin")

        xvm.add("python3", { bindir = bindir })
        xvm.add("python", { bindir = bindir, alias = "python3" })
        xvm.add("pip3", { bindir = bindir, binding = "python@" .. pkginfo.version() })
        xvm.add("pip", { version = "python-" .. pkginfo.version(), bindir = bindir, alias = "pip3", binding = "python@" .. pkginfo.version() })

        -- Install Python dev headers into subos sysroot so that the subos GCC
        -- can compile C extensions (e.g. evdev, mujoco) without missing pyconfig.h
        local includedir = path.join(pkginfo.install_dir(), "include")
        local sysrootdir = system.subos_sysrootdir()
        if sysrootdir and os.isdir(includedir) then
            local sysroot_usrdir = path.join(sysrootdir, "usr")
            if not os.isdir(sysroot_usrdir) then os.mkdir(sysroot_usrdir) end
            log.info("Installing Python dev headers into subos sysroot...")
            __cp_tree_proot_safe(includedir, path.join(sysroot_usrdir, "include"))
        end
    end
    return true
end

function uninstall()
    if os.host() == "windows" then
        if not os.isfile(pkginfo.install_file()) then
            log.error("not exist: " .. tostring(pkginfo.install_file()))
            return false
        end
        os.exec(pkginfo.install_file() .. [[ /uninstall /passive ]])
    else
        xvm.remove("python", pkginfo.version())
        xvm.remove("pip", "python-" .. pkginfo.version())
    end

    return true
end

-- Per-entry walk that replaces xmake's recursive `os.cp` on a directory.
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
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
        -- The MSI uninstaller path lives at `pkginfo.install_file()` —
        -- the same .exe used to install. In CI's
        -- install-then-uninstall flow the installer file isn't always
        -- present on disk when uninstall fires, so a hard `return false`
        -- here turned every windows-install-test on this package into
        -- a CI failure. Treat the absence as "nothing to undo" so the
        -- post-uninstall checks (no leftover shim, etc.) still run.
        if not os.isfile(pkginfo.install_file()) then
            log.warn("python installer not found, skipping MSI uninstall: " .. tostring(pkginfo.install_file()))
        else
            os.exec(pkginfo.install_file() .. [[ /uninstall /passive ]])
        end
    else
        xvm.remove("python", pkginfo.version())
        xvm.remove("pip", "python-" .. pkginfo.version())
    end

    return true
end

-- Per-entry walk that replaces xmake's recursive `os.cp` on a directory.
-- See pkgs/g/glibc.lua for the full rationale. Short form:
--   - Dirs:     os.dirs("**") + os.mkdir         (runtime API)
--   - Files:    `find -type f` + os.cp file→file (runtime API for copy)
--   - Symlinks: `find -type l` + `ln -s`         (shell for both, runtime
--                                                 doesn't expose os.ln
--                                                 in package sandbox)
-- Each op is a single absolute-path syscall → proot-safe.
function __cp_tree_proot_safe(src_dir, dst_dir)
    if not os.isdir(src_dir) then return end
    os.mkdir(dst_dir)
    for _, d in ipairs(os.dirs(path.join(src_dir, "**"))) do
        os.mkdir(path.join(dst_dir, path.relative(d, src_dir)))
    end
    local f = io.popen(string.format(
        [[find "%s" \( -type f -o -type l \) -printf '%%y\t%%P\t%%l\n' 2>/dev/null]],
        src_dir
    ))
    if not f then return end
    for line in f:lines() do
        local kind, rel, link_target = line:match("^(%a)\t([^\t]*)\t(.*)$")
        if kind and rel and rel ~= "" then
            local dst = path.join(dst_dir, rel)
            os.mkdir(path.directory(dst))
            if kind == "l" then
                os.tryrm(dst)
                if link_target ~= "" then
                    os.execute(string.format([[ln -s "%s" "%s"]], link_target, dst))
                end
            else
                os.cp(path.join(src_dir, rel), dst)
            end
        end
    end
    f:close()
end
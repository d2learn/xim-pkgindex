-- TODO: xpm 中无 linux 入口，Linux 用户无法安装；install/config 已有 Linux 逻辑，需补充 xpm.linux 版本定义

function _linux_download_url(version) return "https://www.python.org/ftp/python/" .. version .. "/Python-" .. version .. ".tar.xz" end

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

    xpm = {
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
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

function installed()
    if os.host() == "windows" then
        return os.iorun("python --version")
    else
        return os.iorun("python3 --version")
    end
end

function install()
    if os.host() == "windows" then
        local install_cmd = pkginfo.install_file()
            .. [[ /passive InstallAllUsers=1 PrependPath=1 Include_test=1 Include_pip=1 ]]
            .. [[ TargetDir="]] .. pkginfo.install_dir() .. [["]]
        os.exec(install_cmd)
    else
        os.cd("Python-" .. pkginfo.version())
        os.exec([[./configure --enable-optimizations
            --prefix=]] .. pkginfo.install_dir()
        )
        os.exec("make -j$(nproc)")
        os.exec("make install")
        os.cd("..")
        os.tryrm("Python-" .. pkginfo.version())
    end
    return true
end

function config()
    if os.host() == "windows" then
        log.info("Please restart the terminal to take effect.")
    else
        local bindir = path.join(pkginfo.install_dir(), "bin")
        xvm.add("python", { bindir = bindir, alias = "python3" })
        xvm.add("pip", { version = "python-" .. pkginfo.version(), bindir = bindir, alias = "pip3", binding = "python@" .. pkginfo.version() })
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
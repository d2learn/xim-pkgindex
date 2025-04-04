function _linux_download_url(version) return "https://www.python.org/ftp/python/" .. version .. "/Python-" .. version .. ".tar.xz" end

package = {
    homepage = "https://www.python.org",
    name = "python",
    description = "The Python programming language",
    maintainers = "Python Software Foundation",
    licenses = "PSF License | GPL compatible",
    repo = "https://github.com/python/cpython",
    docs = "https://docs.python.org/3",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"python", "plang"},

    xpm = {
        windows = {
            ["latest"] = { ref = "3.12.6"},
            ["3.12.6"] = {
                url = "https://gitee.com/sunrisepeak/xlings-pkg/releases/download/python12/python-3.12.6-amd64.exe",
                sha256 = "5914748e6580e70bedeb7c537a0832b3071de9e09a2e4e7e3d28060616045e0a",
            },
        },
        linux = {
            deps = { "gcc", "make" },
            ["latest"] = { ref = "3.13.1"},
            ["3.13.1"] = { url = _linux_download_url("3.13.1"), sha256 = nil },
            ["3.12.6"] = { url = _linux_download_url("3.12.6"), sha256 = nil },
            ["3.11.11"] = { url = _linux_download_url("3.11.11"), sha256 = nil },
            ["3.10.16"] = { url = _linux_download_url("3.10.16"), sha256 = nil },
            ["3.9.21"] = { url = _linux_download_url("3.9.21"), sha256 = nil },
            ["3.8.20"] = { url = _linux_download_url("3.8.20"), sha256 = nil },
        },
    },
}

import("common")
import("xim.base.utils")

function installed()
    if is_host("windows") then
        return os.iorun("python --version")
    else
        return os.iorun("xvm list python")
    end
end

function install()
    if is_host("windows") then
        local install_cmd = pkginfo.install_file()
        if utils.prompt("use default installation?(y/n)", "y") then
            install_cmd = pkginfo.install_file() ..
                [[ /passive InstallAllUsers=1 PrependPath=1 Include_test=1 Include_pip=1 ]] ..
                [[ TargetDir="]] .. pkginfo.install_dir()
        end
        common.xlings_run_bat_script(install_cmd, true)
    else
        os.cd("Python-" .. pkginfo.version())
        --  build args - opt or todo?
            --enable-shared
            --with-computed-gotos 
            --with-lto
            --enable-ipv6
            --enable-loadable-sqlite-extensions
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
    if is_host("windows") then
        print("Please restart the terminal to take effect.")
    else
        print("config xvm...")
        local xvm_python_template = "xvm add python %s --path %s/bin --alias python3"
        local xvm_pip_template = "xvm add pip %s --path %s/bin --alias pip3"
        os.exec(string.format(xvm_python_template, pkginfo.version(), pkginfo.install_dir()))
        os.exec(string.format(xvm_pip_template, "python-" .. pkginfo.version(), pkginfo.install_dir()))
    end
    return true
end

function uninstall()
    if is_host("windows") then
        if not os.isfile(pkginfo.install_file()) then
            cprint("$s{red}not exist: " .. pkginfo.install_file())
            return false
        end
        common.xlings_run_bat_script(
            pkginfo.install_file() .. [[ /uninstall /passive ]],
            true
        )
    else
        os.exec("xvm remove python " .. pkginfo.version())
        os.exec("xvm remove pip " .. "python-" .. pkginfo.version())
    end

    return true
end
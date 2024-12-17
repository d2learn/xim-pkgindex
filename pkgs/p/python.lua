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
    },
}

import("common")
import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    if is_host("windows") then
        return os.iorun("python --version")
    else
        return os.iorun("python3 --version")
    end
end

function install()
    common.xlings_run_bat_script(
        pkginfo.install_file .. [[ /passive InstallAllUsers=1 PrependPath=1 Include_test=1 ]],
        true
    )
    return true
end

function uninstall()
    common.xlings_run_bat_script(
        pkginfo.install_file .. [[ /uninstall /passive ]],
        true
    )
    return true
end
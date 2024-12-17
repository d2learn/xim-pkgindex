package = {
    name = "Dev-C++",
    description = "A full-featured Integrated Development Environment (IDE) for the C/C++",
    homepage = "https://sourceforge.net/projects/orwelldevcpp/",
    maintainers = "Orwell (Johan Mes)",
    license = "GPL",
    repo = "https://sourceforge.net/projects/orwelldevcpp/",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"ide", "c", "c++"},
    keywords = {"dev-cpp"},

    xpm = {
        windows = {
            ["latest"] = { ref = "5.11" },
            ["5.11"] = {
                url = "https://gitee.com/sunrisepeak/xlings-pkg/releases/download/devcpp/devcpp.exe",
                sha256 = "faad96bbcc51f115c9edd691785d1309e7663b67dcfcf7c11515c3d28c9c0f1f",
            },
        },
    },
}

import("xim.base.runtime")

local pkginfo = runtime.get_pkginfo()

function installed()
    return os.isfile("C:\\Program Files (x86)\\Dev-Cpp\\devcpp.exe")
end

function install()
    print("[xlings]: suggestion use default install path for dev-c++")
    print("Dev-C++安装建议:")
    print("\t 0.打开安装提示")
    print("\t 1.先选English")
    print("\t 2.使用默认选项安装")
    print("\t 3.打开Dev-C++(这里可以重新选择IDE语言)")
    os.exec(pkginfo.install_file)
    return true
end

function uninstall()
    if os.isfile("C:\\Program Files (x86)\\Dev-Cpp\\uninstall.exe") then
        os.exec("C:\\Program Files (x86)\\Dev-Cpp\\uninstall.exe")
    end
    return true
end
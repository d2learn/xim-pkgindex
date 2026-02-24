-- https://learn.microsoft.com/en-gb/dotnet/core/install/linux-scripted-manual
-- https://learn.microsoft.com/en-gb/dotnet/core/tools/dotnet-install-script
-- https://learn.microsoft.com/en-us/dotnet/core/install/remove-runtime-sdk-versions?pivots=os-linux#scripted-or-manual

local linux_install_script = "https://dot.net/v1/dotnet-install.sh"
local windows_install_script = "https://dot.net/v1/dotnet-install.ps1"

package = {
    spec = "1",

    name = "dotnet",
    description = ".NET is the free, open-source, cross-platform framework",
    homepage = "https://dotnet.microsoft.com/",
    maintainers = {"Microsoft"},
    licenses = {"MIT"},
    repo = "https://github.com/dotnet/sdk",
    docs = "https://learn.microsoft.com/dotnet",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"dotnet"},
    keywords = {"cross-platform", ".net", "dotnet"},

    xpm = {
        windows = {
            ["latest"] = { ref = "9.0" },
            ["9.0"] = { url = windows_install_script, sha256 = nil },
            ["8.0"] = { url = windows_install_script, sha256 = nil },
        },
        linux = {
            ["latest"] = { ref = "9.0" },
            ["9.0"] = { url = linux_install_script, sha256 = nil },
            ["8.0"] = { url = linux_install_script, sha256 = nil },
        },
    },
}

import("xim.libxpkg.pkginfo")

function install()
    local install_cmd = ""
    if is_host("windows") then
        install_cmd = [[powershell -ExecutionPolicy Bypass -File ]] .. pkginfo.install_file() ..
            " -Channel " .. pkginfo.version() ..
            " -InstallDir " .. pkginfo.install_dir()
    else
        os.exec("chmod +x " .. pkginfo.install_file())
        install_cmd = pkginfo.install_file() ..
            " --channel " .. pkginfo.version() ..
            " --install-dir " .. pkginfo.install_dir()
    end
    print("exec: " .. install_cmd)
    os.exec(install_cmd)
    return true
end

function config()
    local xvm_dotnet_cmd = "xvm add dotnet %s --path %s"
    os.exec(string.format(xvm_dotnet_cmd, pkginfo.version(), pkginfo.install_dir()))
    return true
end

function uninstall()
    os.exec("xvm remove dotnet " .. pkginfo.version())
    return true
end
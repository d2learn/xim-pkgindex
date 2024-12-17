-- https://learn.microsoft.com/en-gb/dotnet/core/install/linux-scripted-manual
-- https://learn.microsoft.com/en-us/dotnet/core/install/remove-runtime-sdk-versions?pivots=os-linux#scripted-or-manual

local installer_url = "https://dot.net/v1/dotnet-install.sh"

package = {
    name = "dotnet",
    description = ".NET is the free, open-source, cross-platform framework",
    homepage = "https://dotnet.microsoft.com/",
    maintainers = "Microsoft",
    license = "MIT",
    repo = "https://github.com/dotnet/sdk",
    docs = "https://learn.microsoft.com/dotnet",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"dotnet"},
    keywords = {"cross-platform", ".net", "dotnet"},

    xpm = {
        windows = {
            deps = { "dotnet-9@winget" },
            ["latest"] = { ref = "9.0" },
            ["9.0"] = { },
        },
        debain = {
            ["latest"] = { ref = "9.0" },
            ["9.0"] = { url = installer_url, sha256 = nil },
            ["8.0"] = { url = installer_url, sha256 = nil },
        },
        ubuntu = { ref = "debain" },
        archlinux = { ref = "debain" },
    },
}

import("xim.base.utils")
import("xim.base.runtime")
import("xim.xuninstall")

local pkginfo = runtime.get_pkginfo()
local dotnetdir = path.join(os.getenv("HOME"), ".dotnet")

function installed()
    return os.iorun("dotnet --version")
end

function install()
    if is_host("windows") then
        return true -- install by deps
    end

    os.exec("chmod +x " .. pkginfo.install_file)
    local cmd = pkginfo.install_file .. " --channel " .. pkginfo.version
    print("exec: " .. cmd)
    os.exec(cmd)

    return true
end

function config()
    if not is_host("windows") then
        utils.add_env_path(dotnetdir)
    end
    return true
end

function uninstall()
    if is_host("windows") then
        xuninstall("dotnet-9@winget")
    else
        os.exec("rm -r " .. dotnetdir)
    end
    return true
end
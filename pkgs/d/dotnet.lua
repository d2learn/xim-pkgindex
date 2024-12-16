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

local pkginfo = runtime.get_pkginfo()
local dotnetdir = path.join(os.getenv("HOME"), ".dotnet")

function installed()
    os.addenv("PATH", dotnetdir)
    return os.iorun("dotnet --version")
end

function install()
    os.exec("chmod +x " .. pkginfo.install_file)
    local cmd = pkginfo.install_file .. " --channel " .. pkginfo.version
    print("exec: " .. cmd)
    os.exec(cmd)
    return true
end

function config()
    utils.add_env_path(dotnetdir)
    return true
end

function uninstall()
    os.exec("rm -r " .. dotnetdir)
    return true
end
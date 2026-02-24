package = {
    spec = "1",
    -- base info
    name = "sing-box",
    description = "The universal proxy platform",
    homepage = "https://sing-box.sagernet.org/",
    
    maintainers = {"SagerNet"},
    licenses = {"GPL-3.0-or-later"},
    repo = "https://github.com/SagerNet/sing-box",
    docs = "https://sing-box.sagernet.org/",

    -- xim pkg info
    type = "package",
    archs = {"x86_64", "aarch64", "arm", "armv7h"},
    status = "stable",
    categories = {"proxy", "network"},
    keywords = {"proxy", "vpn", "shadowsocks", "vmess", "trojan", "vless"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        debain = {
            ["latest"] = { ref = "1.12.12" },
            ["1.12.12"] = {
                url = "https://github.com/SagerNet/sing-box/releases/download/v1.12.12/sing-box-1.12.12-linux-amd64.tar.gz",
                sha256 = nil
            },
        },
        ubuntu = { ref = "debain" },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    -- install prebuild binary
    print("Installing sing-box from prebuild...")
    
    -- Create installation directory
    os.tryrm(pkginfo.install_dir())

    local singbox_dir = pkginfo.install_file():replace(".tar.gz", "")
    os.mv(singbox_dir, pkginfo.install_dir())

    return true
end

function config()
    -- config xvm
    xvm.add("sing-box", pkginfo.version())
    
    return true
end

function uninstall()
    xvm.remove("sing-box")
    return true
end

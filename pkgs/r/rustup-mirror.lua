mirror_version = {
    ["latest"] = { ref = "ustc" },
    ["ustc"] = {
        RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup",
        RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static",
    },
    ["tsinghua"] = {
        RUSTUP_UPDATE_ROOT = "https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup",
        RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup",
    },
}

package = {
    -- base info
    name = "rustup-mirror",
    description = "Config Mirror for Rustup",

    authors = "xpkg:sunrisepeak",
    licenses = "Apache-2.0",

    -- xim pkg info
    type = "config",
    namespace = "config",

    xpm = {
        windows = mirror_version,
        linux = mirror_version,
        macosx = mirror_version,
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.pkginfo")

function install()
    local version = pkginfo.version()
    for k, v in pairs(mirror_version[version]) do
        os.setenv(k, v)
        log.info("Set tmp env: %s=%s", k, v)
    end
    return true
end

function uninstall()
    return true
end
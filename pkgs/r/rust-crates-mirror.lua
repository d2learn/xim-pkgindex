-- xpkg maintainer: d2learn / sunrisepeak

-- ustc: https://mirrors.ustc.edu.cn/help/crates.io-index.html
-- tsinghua: https://mirrors.tuna.tsinghua.edu.cn/help/crates.io-index/

mirror_version = {
    ["latest"] = { ref = "ustc" },
    ["ustc"] = {
        crate_io_index = "https://mirrors.ustc.edu.cn/crates.io-index/",
    },
    ["tsinghua"] = {
        crate_io_index = "https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/",
    },
}

package = {
    -- base info
    name = "rust-crates-mirror",
    description = "Config Index Mirror for Rust Crates (Cargo)",

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

import("xim.libxpkg.system")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")
import("xim.libxpkg.pkgmanager")

local mirror_config_template = [[
[source.crates-io]
replace-with = '%s'

[source.%s]
registry = "sparse+%s"

[registries.%s]
index = "sparse+%s"
]]

local cargo_home = os.getenv("CARGO_HOME")

if not cargo_home or cargo_home == "" then
    if is_host("windows") then
        cargo_home = path.join(os.getenv("USERPROFILE"), ".cargo")
    else
        cargo_home = path.join(os.getenv("HOME"), ".cargo")
    end
end

local cargo_config_file = path.join(cargo_home, "config.toml")

if not os.isfile(cargo_config_file) then
    io.writefile(cargo_config_file, "")
end

cargo_config_content = io.readfile(cargo_config_file)

function installed()

    if not string.find(cargo_config_content, pkginfo.version(), 1, true) then
        return false
    end

    return true
end

function install()

    for version, _ in pairs(mirror_version) do
        local installed = string.find(cargo_config_content, version, 1, true)
        if installed then
            log.warn("removing old rust-crates-mirror config: " .. version)
            pkgmanager.remove("rust-crates-mirror")
            cargo_config_content = io.readfile(cargo_config_file)
            break
        end
    end

    log.info("cargo config file: " .. cargo_config_file)
    log.info("adding rust-crates-mirror config: " .. pkginfo.version())

    -- backup hosts file
    local backup_file = path.join(pkginfo.install_dir(), "config.toml")

    io.writefile(backup_file, cargo_config_content)

    cargo_config_content = cargo_config_content .. string.format(
        mirror_config_template,
        pkginfo.version(),
        pkginfo.version(), mirror_version[pkginfo.version()].crate_io_index,
        pkginfo.version(), mirror_version[pkginfo.version()].crate_io_index
    )

    io.writefile(cargo_config_file, cargo_config_content)

    return true
end

function uninstall()
    -- remove the mirror config
    cargo_config_content = cargo_config_content:replace(
        string.format(mirror_config_template,
            pkginfo.version(),
            pkginfo.version(), mirror_version[pkginfo.version()].crate_io_index,
            pkginfo.version(), mirror_version[pkginfo.version()].crate_io_index
        ),
        "",
        { plain = true }
    )

    io.writefile(cargo_config_file, cargo_config_content)

    return true
end
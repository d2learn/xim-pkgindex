function rustup_url(version)
    local template = "https://static.rust-lang.org/rustup/archive/%s/%s/rustup-init"
    if is_host("windows") then
        return string.format(template, version, "x86_64-pc-windows-msvc") .. ".exe"
    elseif is_host("linux") then
        return string.format(template, version, "x86_64-unknown-linux-gnu")
    elseif is_host("macosx") then
        return string.format(template, version, "x86_64-apple-darwin")
    end
end

package = {

    homepage = "https://rustup.rs",

    -- base info
    name = "rustup",
    description = "An installer init tool for Rustup, the Rust toolchain installer",

    repo = "https://github.com/rust-lang/rustup",
    docs = "https://rust-lang.github.io/rustup/installation/other.html",

    -- xim pkg info
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"rust", "toolchain"},
    keywords = {"rust", "cross-platform", "version-management"},
    programs = {"rustup-init"},

    xpm = {
        windows = {
            ["latest"] = { ref = "1.28.2" },
            ["1.28.2"] = {
                url = rustup_url("1.28.2"),
                sha256 = nil,
            }
        },
        linux = {
            ["latest"] = { ref = "1.28.2" },
            ["1.28.2"] = {
                url = rustup_url("1.28.2"),
                sha256 = nil,
            }
        },
        macosx = {
            ["latest"] = { ref = "1.28.2" },
            ["1.28.2"] = {
                url = rustup_url("1.28.2"),
                sha256 = nil,
            }
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

local rustup_init_file = {
    windows = "rustup-init.exe",
    linux = "rustup-init",
    macosx = "rustup-init"
}

function installed()
    return xvm.has("rustup-init")
end

function install()
    if is_host("linux") or is_host("macosx") then
        system.exec("chmod +x " .. rustup_init_file[os.host()])
    end
    os.mv(rustup_init_file[os.host()], pkginfo.install_dir())
    return true
end

function config()
    xvm.add("rustup-init")
    return true
end

function uninstall()
    xvm.remove("rustup-init")
    return true
end

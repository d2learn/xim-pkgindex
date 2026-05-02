package = {
    spec = "1",

    name = "xmake",
    description = "A cross-platform build utility based on Lua",

    authors = {"ruki"},
    maintainers = {"ruki"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/xmake-io/xmake",
    homepage = "https://xmake.io",
    docs = "https://xmake.io/#/getting_started",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"build-system", "tools"},
    keywords = {"xmake", "build", "lua", "cross-platform"},

    programs = {"xmake"},
    xvm_enable = true,

    xpm = {
        linux = {
            -- Runtime deps. xmake bundle is dynamically linked
            -- (INTERP=/lib64/ld-linux-x86-64.so.2) and needs libc/libm
            -- from glibc plus libncurses.so.6 + libtinfo.so.6 from
            -- ncurses for its TUI.
            -- TODO: there is no xim:ncurses prebuilt yet (only
            -- fromsource:ncurses). Until one is published, falling back
            -- to the system ncurses works on most distros that have it
            -- preinstalled. Track the gap separately; declaring
            -- glibc@2.39 alone is the minimum-viable correct fix.
            deps = {
                runtime = { "glibc@2.39" },
            },
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.linux.x86_64",
            ["latest"] = { ref = "3.0.8" },
            ["3.0.8"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.8/xmake-bundle-v3.0.8.linux.x86_64",
                sha256 = "5bf5d58230ed78d87b9919a0a654d0ebcdad221426bd610ad4f740029bb61c84",
            },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.linux.x86_64",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
        macosx = {
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.macos.arm64",
            ["latest"] = { ref = "3.0.8" },
            ["3.0.8"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.8/xmake-bundle-v3.0.8.macos.arm64",
                sha256 = "6266c3563ce3c890a502179a9a5976001df8da8533722c528ba2ab3fce63fc0e",
            },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.macos.arm64",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
        windows = {
            url_template = "https://github.com/xmake-io/xmake/releases/download/v{version}/xmake-bundle-v{version}.win64.exe",
            ["latest"] = { ref = "3.0.8" },
            ["3.0.8"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.8/xmake-bundle-v3.0.8.win64.exe",
                sha256 = "e9a316bfb18fee60036174912502030ea7eb3d62c49634d5828ef5c2b2327aec",
            },
            ["3.0.7"] = {
                url = "https://github.com/xmake-io/xmake/releases/download/v3.0.7/xmake-bundle-v3.0.7.win64.exe",
                sha256 = nil,
            },
            -- ["3.0.7"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    local exe_name = "xmake"
    if os.host() == "windows" then
        exe_name = "xmake.exe"
    else
        os.exec("chmod +x " .. pkginfo.install_file())
    end

    os.mv(pkginfo.install_file(), path.join(pkginfo.install_dir(), exe_name))
    return true
end

function config()
    xvm.add("xmake")
    return true
end

function uninstall()
    xvm.remove("xmake")
    return true
end

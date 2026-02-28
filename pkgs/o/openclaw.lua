package = {
    spec = "1",
    name = "openclaw",
    description = "OpenClaw binary package (minimal install, xvm-managed, isolation friendly)",

    type = "package",
    archs = {"x86_64", "arm64"},
    status = "stable",
    categories = {"tools", "cli"},
    keywords = {"openclaw", "xiaolongxia", "cli", "tool"},

    programs = {"openclaw"},
    xvm_enable = true,

    xpm = {
        windows = {
            ["latest"] = { ref = "1.0.0" },
            ["1.0.0"] = "XLINGS_RES",
        },
        linux = {
            ["latest"] = { ref = "1.0.0" },
            ["1.0.0"] = "XLINGS_RES",
        },
        macosx = {
            ["latest"] = { ref = "1.0.0" },
            ["1.0.0"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

local openclaw_bin = {
    windows = "openclaw.exe",
    linux = "openclaw",
    macosx = "openclaw",
}

function install()
    local install_dir = pkginfo.install_dir()
    local install_file = pkginfo.install_file()

    os.tryrm(install_dir)

    local extract_dir = install_file
        :replace(".zip", "")
        :replace(".tar.gz", "")
        :replace(".tar.xz", "")

    if os.isdir(extract_dir) then
        os.mv(extract_dir, install_dir)
        return true
    end

    os.mkdir(install_dir)

    local host_bin = openclaw_bin[os.host()]
    if os.isfile(host_bin) then
        os.mv(host_bin, install_dir)
        return true
    end

    if os.isfile(install_file) then
        os.mv(install_file, path.join(install_dir, host_bin))
        return true
    end

    return false
end

function config()
    local bindir = pkginfo.install_dir()
    local local_bin_dir = path.join(pkginfo.install_dir(), "bin")

    if os.isfile(path.join(local_bin_dir, openclaw_bin[os.host()])) then
        bindir = local_bin_dir
    end

    xvm.add("openclaw", { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove("openclaw")
    return true
end

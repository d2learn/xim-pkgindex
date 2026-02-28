package = {
    spec = "1",
    homepage = "https://opencloud.eu/",
    name = "opencloud",
    description = "OpenCloud client binary package for isolated use via xvm",

    authors = {"openCloud GmbH"},
    maintainers = {"openCloud GmbH"},
    licenses = {"Apache-2.0"},
    repo = "https://github.com/opencloud-eu/opencloud",
    docs = "https://docs.opencloud.eu/",

    type = "package",
    archs = {"x86_64", "arm64"},
    status = "stable",
    categories = {"cloud", "storage", "sync"},
    keywords = {"opencloud", "cloud", "storage", "sync", "client"},

    programs = {"opencloud"},
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

local opencloud_bin = {
    windows = "opencloud.exe",
    linux = "opencloud",
    macosx = "opencloud",
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

    local host_bin = opencloud_bin[os.host()]
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

    if os.isfile(path.join(local_bin_dir, opencloud_bin[os.host()])) then
        bindir = local_bin_dir
    end

    xvm.add("opencloud", { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove("opencloud")
    return true
end

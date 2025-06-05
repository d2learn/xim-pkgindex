package = {
    -- base info
    name = "xlings-project-templates",
    description = "Xlings - Project Templates",

    authors = "d2learn",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xlings-project-templates",

    -- xim pkg info
    type = "templates",
    status = "stable", -- dev, stable, deprecated
    categories = {"xlings", "template", "project"},
    keywords = {"project-template"},

    -- xvm: xlings version management
    xvm_enable = true,
}

xpm_os_common = {
    ["latest"] = {
        url = package.repo .. ".git",
        sha256 = nil,
    },
}

package.xpm = {
    windows = xpm_os_common,
    linux = xpm_os_common,
    macosx = xpm_os_common,
}

import("xim.libxpkg.pkginfo")

function installed()
    return os.isfile(path.join(pkginfo.install_dir(), "README.md"))
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mv(package.name, pkginfo.install_dir())
    return true
end

function uninstall()
    return true
end
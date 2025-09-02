package = {
    -- base info
    name = "xpkg-helper",
    description = "XPKG: XPackage Helper Tools",

    authors = "sunrisepeak",
    maintainers = "d2learn",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xim-pkgindex",

    -- xim pkg info
    type = "script",
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "xpkg", "helper" },
    keywords = {"xpackage", "helper", "xscript"},

    xpm = {
        windows = { ["0.0.1"] = { } },
        linux = { ["0.0.1"] = { } },
        macosx = { ["0.0.1"] = { } },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")

function xpkg_main(pkgname, version)
    if not pkgname then
        cprint("Usage: ${cyan}xpkg-helper <pkgname> [version]")
        return
    end

    version = version or ""
    if not xvm.has(pkgname, version) then
        log.warn("xpkg not installed: " .. pkgname .. "@" .. version)
        return
    end

    local info = xvm.info(pkgname, version)

    local export_path = path.join(
        system.rundir(),
        info.pkginfo.name .. "@" .. info.pkginfo.version
    )

    if os.isdir(export_path) then
        log.warn("xpkg already exported: " .. export_path)
        return
    end

    os.cp(info.pkginfo.install_dir, export_path)

    log.info(
        "${bright}%s${clear} | ${yellow}%s${clear} - ${green}ok",
        pkgname, export_path
    )
end
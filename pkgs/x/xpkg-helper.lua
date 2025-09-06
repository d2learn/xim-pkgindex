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
import("xim.libxpkg.utils")

local __xscript_input = {
    ["--export-path"] = false,
    ["--force"] = false,
}

function xpkgname_process(pkgname)

    local namespace = nil
    local version = ""

    if not pkgname then
        cprint("\t${bright}XPackage Helper Tools - 0.0.1${clear}")
        cprint("")
        cprint("Usage: ${dim cyan}xpkg-helper [namespace:]<pkgname>[@version]")
        cprint("")
        cprint("Example:")
        cprint("  ${dim cyan}xpkg-helper code")
        cprint("  ${dim cyan}xpkg-helper code@1.100.1")
        cprint("  ${dim cyan}xpkg-helper fromesource:musl-gcc@15.1.0")
        cprint("")
        return
    else
        log.info("checking [ %s ] ...", tostring(pkgname))

        if pkgname:find(":") then
            local parts = pkgname:split(":")
            namespace = parts[1]
            pkgname = parts[2]
        end
    
        if pkgname:find("@") then
            local parts = pkgname:split("@")
            pkgname = parts[1]
            version = parts[2]
        end
    end

    return namespace, pkgname, version
end

function xpkg_main(xpkgname, ...)

    local _, cmds = utils.input_args_process(
        __xscript_input,
        { ... }
    )

    if cmds["--force"] then cmds["--force"] = true end

    local namespace, pkgname, version = xpkgname_process(xpkgname)

    if not pkgname then return end

    if not xvm.has(pkgname, version) then
        log.warn("xpkg not installed: " .. pkgname .. "@" .. version)
        return
    end

    local info = xvm.info(pkgname, version)
    local xpkg_fullname = pkgname
    
    if namespace then xpkg_fullname = namespace .. "-x-" .. pkgname end
    local xpkg_installdir = path.join(system.xpkgdir(), xpkg_fullname, info["Version"])

    if not cmds["--export-path"] then
        cmds["--export-path"] = xpkg_fullname .. "@" .. info["Version"]
    end

    _, cmds["--export-path"] = utils.filepath_to_absolute(cmds["--export-path"])

    if os.isdir(cmds["--export-path"]) then
        log.warn("${yellow}xpkg already exported: " .. cmds["--export-path"])
        return
    end

    os.cp(xpkg_installdir, cmds["--export-path"], {
        symlink = true,
        force = cmds["--force"],
    })

    log.info(
        "${bright}%s${clear} | ${yellow}%s${clear} - ${green}ok",
        pkgname, cmds["--export-path"]
    )
end
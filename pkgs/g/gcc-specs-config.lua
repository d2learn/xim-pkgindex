package = {
    -- base info
    name = "gcc-specs-config",
    description = "XScript: GCC Specs Config Tool",

    authors = "sunrisepeak",
    maintainers = "d2learn",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xim-pkgindex",

    -- xim pkg info
    type = "script",
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "gcc", },

    xpm = {
        linux = { ["0.0.1"] = { } },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.utils")

local __xscript_input = {
    ["--dynamic-linker"] = false,
    ["--linker-type"] = false,
    ["--rpath"] = false,
}

function xpkg_main(gcc_bin, ...)

    local _, cmds = utils.input_args_process(
        __xscript_input,
        { ... }
    )

    if not os.isfile(gcc_bin) then
        log.error("GCC binary not found: " .. tostring(gcc_bin))
        return false
    end

    local sysrootdir = system.subos_sysrootdir()
    local default_libdir = path.join(sysrootdir, "lib")
    local default_linker = path.join(default_libdir, "ld-linux-x86-64.so.2")

    cmds["--dynamic-linker"] = cmds["--dynamic-linker"] or default_linker
    cmds["--rpath"] = cmds["--rpath"] or default_libdir

    -- printinfo
    cprint("")
    cprint("\tgcc-specs-config - 0.0.1")
    cprint("")
    cprint("---")
    cprint("gcc: ${green}%s${clear}", gcc_bin)
    cprint("dynamic-linker: ${green}%s${clear}", cmds["--dynamic-linker"])
    cprint("runpath(rpath): ${green}%s${clear}", cmds["--rpath"])
    cprint("---")
    cprint("")

    local default_specs_content = os.iorun(gcc_bin .. " -dumpspecs")
    local default_specs_file = os.iorun(gcc_bin .. " -print-libgcc-file-name")

    default_specs_file = path.join(
        path.directory(default_specs_file:trim()),
        "specs"
    )

    log.info("Default specs path: " .. default_specs_file)

    -- replace dynamic linker in specs
    local old_dynamic_linker = {
        musl = "/lib/ld-musl-x86_64.so.1",
        gnu = "/lib64/ld-linux-x86-64.so.2",
    }

    local linker_type = cmds["--linker-type"] or "gnu"

    old_dynamic_linker = old_dynamic_linker[linker_type]
    log.info("Detected old dynamic linker (%s) : %s", linker_type, old_dynamic_linker)

    default_specs_content = string.replace(
        default_specs_content,
        -- support multi-arch?
        old_dynamic_linker, cmds["--dynamic-linker"],
        { plain = true }
    )

    log.warn(string.format(
        "Replacing dynamic linker in specs: %s -> %s",
        old_dynamic_linker, cmds["--dynamic-linker"]
    ))

    -- runtime path
    local rpath = "*link:\n%{!static:%{!shared:%{!static-pie: --enable-new-dtags -rpath "
        .. cmds["--rpath"] .. " }}} "

    default_specs_content = string.replace(
        default_specs_content,
        "*link:\n", rpath,
        { plain = true }
    )

    log.info("Adding rpath to specs: " .. cmds["--rpath"])

    io.writefile(default_specs_file, default_specs_content)

    log.info("Dynamic linker set to: " .. cmds["--dynamic-linker"])
    log.info("Specs file updated: " .. default_specs_file)

end
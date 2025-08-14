package = {
    -- base info
    name = "musl-cross-make",
    description = "Simple makefile-based build for musl cross compiler",

    authors = "Rich Felker, et al.",
    contributors = "https://github.com/richfelker/musl-cross-make/graphs/contributors",
    licenses = "MIT",
    repo = "https://github.com/richfelker/musl-cross-make",

    -- xim pkg info
    type = "script",
    status = "stable",
    categories = {"linux", "build-helper", "toolchain"},
    keywords = {"linux", "musl", "libc", "toolchain", "compiler", "makefile", "gcc"},
    programs = { "musl-cross-make" },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            deps = { "make" },
            ["latest"] = { ref = "0.0.1" },
            ["0.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/richfelker/musl-cross-make.git",
                    CN = "https://gitcode.com/xlings-res/musl-cross-make.git",
                },
                sha256 = nil,
            },
        },
    },
}

import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.pkginfo")

local source_script_file = path.join(os.scriptdir(), "musl-cross-make.lua")

function install()
    -- install musl-cross-make script
    local target_script_file = path.join(pkginfo.install_dir(), "musl-cross-make.lua")
    os.tryrm(target_script_file)
    os.cp(source_script_file, target_script_file)
    xvm.add("musl-cross-make", {
        alias = "xlings script " .. target_script_file,
        bindir = "TODO-FIX-SPATH-ISSUES",
    })
    -- install musl-cross-make source
    os.mv("musl-cross-make", pkginfo.install_dir())
    return true
end

function verify_and_choice_from_list(target, target_list, opt)
    if opt.header_tips then
        cprint(opt.header_tips)
    end

    target = target or opt.default

    local in_list = false
    for _, t in ipairs(target_list) do
        if string.find(t, target, 1, true) then target = t end
        if t == target then
            in_list = true
            cprint("  ${green}" .. t .. " ${blink}<")
        else
            cprint("  " .. t)
        end
        os.sleep(200) -- sleep to avoid too fast output
    end

    if not in_list and target then
        cprint("  ${green}" .. target .. " ${blink}<")
    end

    if opt.footer_tips and target then
        cprint(opt.footer_tips .. " - ${green}" .. target)
    end

    return target

end

function info_tips(version, target, output)
    cprint("\n${dim}---\n")

    cprint("${bright}version: ${green}" .. version)
    cprint("${bright}target: ${green}" .. target)
    cprint("${bright}output: ${green}" .. output)

    cprint("\n${dim}---\n")
end

function __try_run(cmd)
    return try {
        function()
            system.exec(cmd)
            return true
        end,
        catch = function(err)
            return false
        end
    }
end

-- version tips
-- https://gcc.gnu.org/releases.html
-- musl-cross-make supports auto-mirror ftp
local gcc_version_list = {
    "9.4.0", -- ubuntu20.04~
    "10.3.0", -- debian11~
    "11.5.0", -- ubuntu22.04~
    "12.4.0", -- debian12~
    "13.3.0", -- ubuntu24.04
    "15.1.0",
    -- more...
}

local target_list = {
    "i486-linux-musl",
    "x86_64-linux-musl",
    "arm-linux-musleabi",
    "arm-linux-musleabihf",
    "sh2eb-linux-muslfdpic",
    -- ...
}

local config_mak_template = [[
TARGET = %s
GCC_VER = %s
OUTPUT = %s
]]

-- function main() inherits failed for package?
-- avoid to call main when import this package?
function xpkg_main(version, target, output)
    version = verify_and_choice_from_list(
        version,
        gcc_version_list,
        {
            header_tips = "GCC version for musl-cross-make:",
            footer_tips = "Selected GCC version",
            default = "11.5.0",
        }
    )

    target = verify_and_choice_from_list(
        target,
        target_list,
        {
            header_tips = "Target architecture for musl-cross-make:",
            footer_tips = "Selected target architecture",
            default = "x86_64-linux-musl",
        }
    )
    output = output or "xlings-musl-gcc"
    output = path.join(system.rundir(), output)

    info_tips(version, target, output)

    cprint("start build ${blink}...")
    os.sleep(3000) -- wait user check and confirmation

    local project_dir = path.join(os.scriptdir(), "musl-cross-make")
    local ret_ok = true

    if not os.isdir(project_dir) then
        cprint("${red}Error: musl-cross-make project directory not found!")
        cprint("Tips: try remove and reinstall musl-cross-make package.")
        cprint("")
        cprint("  ${cyan}xlings remove musl-cross-make")
        cprint("  ${cyan}xlings install musl-cross-make")
        cprint("")
        ret_ok = false
    end

    local config_mak_file = path.join(project_dir, "config.mak")
    local config_mak = string.format(config_mak_template, target, version, output)

    io.writefile(config_mak_file, config_mak)

    os.cd(project_dir)

    if ret_ok then
        cprint("$-> {yellow}clearing previous build files...")
        ret_ok = __try_run("make clean")
    else
        cprint("${red}Project dir not found, aborting build.")
    end

    if ret_ok then
        cprint("-> ${yellow}building with musl-cross-make...")
        ret_ok = __try_run("make -j8")
    else
        cprint("${red}Failed to clear previous build files, aborting build.")
    end

    if ret_ok then
        cprint("-> ${yellow}installing to " .. output .. " ...")
        ret_ok = __try_run("make install")
    else
        cprint("${red}Build failed, aborting installation.")
    end

    -- tips
    info_tips(version, target, output)

    cprint("\n\t${bright dim}[ musl-cross-make(xlings) 0.0.1 ]\n")

    if ret_ok then
        cprint("${green}Build and install completed successfully!")
    else
        cprint("${red}Build or install failed!")
        cprint("Please check the output for errors.")
        cprint("")
        cprint("QA-List: https://xlings.d2learn.org/documents/qa.html")
        cprint("")
    end
end
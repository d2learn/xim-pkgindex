package = {
    spec = "1",
    -- base info
    name = "linux-headers",
    description = "Linux Kernel Header",

    licenses = {"GPL"},
    repo = "https://github.com/torvalds/linux",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            -- TODO: Temporary workaround for pkgmanager.install() install-dir resolution issue.
            deps = {
                "scode:linux-headers@5.11.1",
            },
            ["latest"] = { ref = "5.11.1" },
            ["5.11.1"] = { },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.pkgmanager")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

function install()
    return true
end

function config()
    local scodedir = pkginfo.install_dir("scode:linux-headers", pkginfo.version())

    log.info("Copying linux header files to subos rootfs ...")
    local sysroot_usrdir = path.join(system.subos_sysrootdir(), "usr")
    if not os.isdir(sysroot_usrdir) then os.mkdir(sysroot_usrdir) end
    os.cp(path.join(scodedir, "include"), sysroot_usrdir, {
        force = true, symlink = true
    })

    xvm.add("linux-headers")

    return true
end

function uninstall()
    xvm.remove("linux-headers")
    return true
end
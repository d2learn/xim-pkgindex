package = {
    spec = "1",
    homepage = "https://zlib.net",

    name = "zlib",
    description = "A massively spiffy yet delicately unobtrusive compression library",
    maintainers = {"Jean-loup Gailly", "Mark Adler"},
    licenses = {"Zlib"},
    repo = "https://github.com/madler/zlib",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"compression", "library"},
    keywords = {"zlib", "compression", "lib"},

    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "1.3.1" },
            ["1.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/zlib/releases/download/1.3.1/zlib-1.3.1-linux-x86_64.tar.gz",
                    CN = "https://gitcode.com/xlings-res/zlib/releases/download/1.3.1/zlib-1.3.1-linux-x86_64.tar.gz",
                },
                sha256 = "bd66d75485ca9d9a949ba5b99733c8ded759a464d1c6172ae26b8a2e176a0e75",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

local libs = {
    "libz.so", "libz.so.1",
}

function install()
    local srcdir = "zlib-" .. pkginfo.version() .. "-linux-x86_64"
    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end

function config()
    local libdir = path.join(pkginfo.install_dir(), "lib")
    local binding = package.name .. "@" .. pkginfo.version()

    xvm.add(package.name)

    for _, lib in ipairs(libs) do
        local libpath = path.join(libdir, lib)
        if os.isfile(libpath) then
            xvm.add(lib, {
                type = "lib",
                bindir = libdir,
                filename = lib,
                alias = lib,
                binding = binding,
            })
        end
    end

    -- Copy headers to sysroot for other packages to find
    local sys_inc = path.join(system.subos_sysrootdir(), "usr/include")
    local inc_dir = path.join(pkginfo.install_dir(), "include")
    if os.isdir(inc_dir) and os.isdir(sys_inc) then
        local zlib_h = path.join(inc_dir, "zlib.h")
        local zconf_h = path.join(inc_dir, "zconf.h")
        if os.isfile(zlib_h) then os.cp(zlib_h, sys_inc) end
        if os.isfile(zconf_h) then os.cp(zconf_h, sys_inc) end
    end

    return true
end

function uninstall()
    xvm.remove(package.name)

    for _, lib in ipairs(libs) do
        xvm.remove(lib)
    end

    local sys_inc = path.join(system.subos_sysrootdir(), "usr/include")
    os.tryrm(path.join(sys_inc, "zlib.h"))
    os.tryrm(path.join(sys_inc, "zconf.h"))

    return true
end

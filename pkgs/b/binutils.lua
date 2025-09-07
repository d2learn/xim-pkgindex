package = {
    homepage = "https://www.gnu.org/software/binutils",
    -- base info
    name = "binutils",
    description = "The GNU Binutils are a collection of binary tools",

    authors = "GNU",
    licenses = "GPL",
    docs = "https://sourceware.org/binutils/wiki/HomePage",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"binutils", "gnu"},
    keywords = {"binutils", "gnu"},

    -- xvm: xlings version management
    xvm_enable = true,

    programs = {
        "ld", "as", "gold",
        "addr2line", "ar", "c++filt", "dlltool", "elfedit",
        "gprof", "nlmconv", "nm", "objcopy",
        "objdump", "ranlib", "readelf", "size", "strings", "strip",
        "windres", "windmc",
        -- "gprofng", TODO: fix cannot find -lrt: No such file or directory
    },

    xpm = {
        linux = {
            deps = { "glibc@2.39" },
            ["latest"] = { ref = "2.42" },
            ["2.42"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

function install()

    local glibcdir = pkginfo.install_file():replace(".tar.gz", "")

    os.tryrm(pkginfo.install_dir())
    os.cp(glibcdir, pkginfo.install_dir(), {
        force = true, symlink = true
    })

    return true
end

function config()
    xvm.add("binutils")

    local binutils_root_binding = "binutils@" .. pkginfo.version()

    local binutils_bindir = path.join(pkginfo.install_dir(), "bin")

    for _, program in ipairs(package.programs) do
        xvm.add(program, {
            bindir = binutils_bindir,
            binding = binutils_root_binding,
        })
    end

    return true
end

function uninstall()
    xvm.remove("binutils")
    for _, program in ipairs(package.programs) do
        xvm.remove(program)
    end
    return true
end
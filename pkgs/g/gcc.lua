function __gcc_url(version) return format("https://ftp.gnu.org/gnu/gcc/gcc-%s/gcc-%s.tar.xz", version, version) end

package = {
    -- base info
    name = "gcc",
    description = "GCC, the GNU Compiler Collection",

    authors = "GNU",
    licenses = "GPL",
    repo = "https://github.com/gcc-mirror/gcc",
    docs = "https://gcc.gnu.org/wiki",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"compiler", "gnu", "language"},
    keywords = {"compiler", "gnu", "gcc", "language", "c", "c++"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
            ["14.2.0"] = { url = __gcc_url("14.2.0") },
            ["13.3.0"] = { url = __gcc_url("13.3.0") },
            ["12.4.0"] = { url = __gcc_url("12.4.0") },
            ["11.5.0"] = { url = __gcc_url("11.5.0") },
        },
    },
}

import("xim.libxpkg.system")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")
import("xim.libxpkg.xvm")

function install()
    local gccdir = pkginfo.install_file()
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(gccdir, pkginfo.install_dir())
    return true
end

function config()
    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")
    local ld_lib_path = string.format("%s:%s", path.join(pkginfo.install_dir(), "lib64"), os.getenv("LD_LIBRARY_PATH") or "")
    
    local config = {
        bindir = gcc_bindir,
        envs = {
            ["LD_LIBRARY_PATH"] = ld_lib_path,
        }
    }

    xvm.add("gcc", config)
    xvm.add("g++", config)
    xvm.add("c++", config)

    return true
end

function uninstall()
    xvm.remove("gcc")
    xvm.remove("g++")
    xvm.remove("c++")
    return true
end
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
            deps = { "make", "gcc", "xz", "gzip", "bzip2" },
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = { url = __gcc_url("15.1.0") },
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
    local builddir = path.join(pkginfo.install_dir(), "xim_build")
    local objdir = path.join(pkginfo.install_dir(), "xim_build", "objdir")
    local prerequisites_dir = path.join(path.directory(pkginfo.install_dir()), "comm-prerequisites")

    log.info("0.clean build cache...")
    if not os.isdir(prerequisites_dir) then os.mkdir(prerequisites_dir) end
    for _, dir in ipairs(os.dirs(path.join(prerequisites_dir, "**"))) do
        -- if dir is empty, remove it
        if os.emptydir(dir) then
            os.tryrm(dir)
        end
    end

    os.tryrm(builddir)
    os.mkdir(builddir)
    system.exec(string.format("tar xvf gcc-%s.tar.xz -C %s", pkginfo.version(), builddir))
    os.cd(path.join(builddir, "gcc-" .. pkginfo.version()))

    log.info("1.download prerequisites...")
    -- readfile - contrib/download_prerequisites
    local filecontent = io.readfile("contrib/download_prerequisites")
    filecontent = filecontent:replace("--no-verbose", " ", { plain = true })
    io.writefile("contrib/download_prerequisites", filecontent)
    system.exec("contrib/download_prerequisites --directory=" .. prerequisites_dir)

    log.info("2.build config...")
    os.mkdir(objdir)
    os.cd(objdir)
    system.exec(string.format([[%s/gcc-%s/configure
        --prefix=%s --enable-languages=c,c++ --disable-multilib
    ]], builddir, pkginfo.version(), pkginfo.install_dir()))

    log.info("3.build gcc...")
    system.exec("time make -j32", { retry = 2 })

    log.info("4.install gcc...")
    system.exec("make install")
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
package = {
    spec = "1",

    name = "patchelf",
    description = "ELF patch tool for interpreter and RPATH",

    homepage = "https://github.com/NixOS/patchelf",
    maintainers = {"NixOS"},
    licenses = {"GPL-3.0-or-later"},
    repo = "https://github.com/NixOS/patchelf",
    docs = "https://github.com/NixOS/patchelf",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"elf", "binary", "tool"},
    keywords = {"elfpatch", "patchelf", "rpath", "interpreter"},

    programs = {"patchelf"},
    aliases = {"elfpatch"},
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = { ref = "0.18.0" },
            ["0.18.0"] = {
                ["GLOBAL"] = {
                    url = "https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz",
                    sha256 = nil,
                },
                ["CN"] = {
                    url = "https://gitcode.com/xlings-res/mirror-cn/releases/download/patchelf/patchelf-0.18.0-x86_64.tar.gz",
                    sha256 = nil,
                },
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
    os.tryrm(pkginfo.install_dir())
    local patchelfdir = pkginfo.install_file()
        :replace(".zip", "")
        :replace(".tar.gz", "")
    os.mv(patchelfdir, pkginfo.install_dir())
    return true
end

function config()
    xvm.add("patchelf", { bindir = path.join(pkginfo.install_dir(), "bin") })
    xvm.add("elfpatch", { bindir = path.join(pkginfo.install_dir(), "bin"), alias = "patchelf" })
    return true
end

function uninstall()
    xvm.remove("patchelf")
    xvm.remove("elfpatch")
    return true
end

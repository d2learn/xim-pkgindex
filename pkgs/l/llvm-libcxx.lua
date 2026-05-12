package = {
    spec = "1",
    homepage = "https://libcxx.llvm.org",

    name = "llvm-libcxx",
    description = "LLVM libc++ C++ standard library",
    maintainers = {"LLVM Project"},
    licenses = {"Apache-2.0 WITH LLVM-exception"},
    repo = "https://github.com/llvm/llvm-project",
    docs = "https://libcxx.llvm.org/docs/",

    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"library", "llvm", "c++"},
    keywords = {"libc++", "libcxx", "c++", "standard-library", "llvm"},

    xpm = {
        linux = {
            ["latest"] = { ref = "20.1.7" },
            ["20.1.7"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/llvm/releases/download/20.1.7/llvm-libcxx-20.1.7-linux-x86_64.tar.xz",
                    CN = "https://gitcode.com/xlings-res/llvm/releases/download/20.1.7/llvm-libcxx-20.1.7-linux-x86_64.tar.xz",
                },
                sha256 = "870752c34737201978816ddafc247a13ee2a92ac44ab71db8e227e9054401e48",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

function install()
    local srcdir = pkginfo.install_file()
        :replace(".tar.xz", "")
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(srcdir, pkginfo.install_dir())
    return true
end

function uninstall()
    return true
end

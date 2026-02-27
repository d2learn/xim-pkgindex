package = {
    spec = "1",
    homepage = "https://llvm.org",

    name = "llvm",
    description = "LLVM compiler infrastructure and toolchain",
    maintainers = {"LLVM Project"},
    licenses = {"Apache-2.0 WITH LLVM-exception"},
    repo = "https://github.com/llvm/llvm-project",
    docs = "https://llvm.org/docs/",

    type = "package",
    archs = {"arm64"},
    status = "stable",
    categories = {"compiler", "toolchain", "llvm"},
    keywords = {"llvm", "clang", "lld", "compiler", "linker"},

    xvm_enable = true,

    xpm = {
        macosx = {
            ["latest"] = { ref = "20.1.7" },
            ["20.1.7"] = {
                url = "https://gitcode.com/xlings-res/llvm/releases/download/20.1.7/LLVM-20.1.7-macOS-ARM64.tar.xz",
                sha256 = nil,
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

local related_apps = {
    "clang-20",
    "clang",
    "clang++",
    "clang-cpp",
    "clangd",
    "clang-format",
    "clang-tidy",
    "lldb",
    "llvm-ar",
    "llvm-as",
    "llvm-dis",
    "llvm-libtool-darwin",
    "llvm-nm",
    "llvm-objcopy",
    "llvm-objdump",
    "llvm-ranlib",
    "llvm-readobj",
    "llvm-size",
    "llvm-strings",
    "llvm-strip",
    "llvm-symbolizer",
    "llvm-config",
    "lld",
    "ld.lld",
}

local alias_apps = {
    {name = "cc", alias = "clang"},
    {name = "c++", alias = "clang++"},
    {name = "ar", alias = "llvm-ar"},
    {name = "ranlib", alias = "llvm-ranlib"},
    {name = "strip", alias = "llvm-strip"},
    {name = "nm", alias = "llvm-nm"},
}

function install()
    local llvmdir = pkginfo.install_file()
        :replace(".tar.xz", "")
        :replace(".tar.gz", "")
        :replace(".zip", "")
    os.tryrm(pkginfo.install_dir())
    os.mv(llvmdir, pkginfo.install_dir())

    -- Ensure clang/clang++ linkers use LLVM lib dir as default runtime search path.
    local libdir = path.join(pkginfo.install_dir(), "lib")
    local cfg_text = "-Wl,-rpath," .. libdir .. "\n"
    io.writefile(path.join(pkginfo.install_dir(), "bin", "clang.cfg"), cfg_text)
    io.writefile(path.join(pkginfo.install_dir(), "bin", "clang++.cfg"), cfg_text)

    return true
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    local libdir = path.join(pkginfo.install_dir(), "lib")
    local binding = package.name .. "-" .. pkginfo.version()

    local envs = {
        LLVM_HOME = pkginfo.install_dir(),
        LDFLAGS = "-Wl,-rpath," .. libdir,
    }

    xvm.add(package.name, { binding = binding })

    for _, app in ipairs(related_apps) do
        if os.isfile(path.join(bindir, app)) then
            xvm.add(app, {
                bindir = bindir,
                binding = binding,
                envs = envs,
            })
        else
            log.warn("skip xvm add (not found): " .. app)
        end
    end

    for _, app in ipairs(alias_apps) do
        if os.isfile(path.join(bindir, app.alias)) then
            xvm.add(app.name, {
                bindir = bindir,
                alias = app.alias,
                binding = binding,
                envs = envs,
            })
        else
            log.warn("skip xvm add alias (not found): " .. app.name .. " -> " .. app.alias)
        end
    end

    return true
end

function uninstall()
    xvm.remove(package.name)

    for _, app in ipairs(related_apps) do
        xvm.remove(app, package.name .. "-" .. pkginfo.version())
    end

    for _, app in ipairs(alias_apps) do
        xvm.remove(app.name, package.name .. "-" .. pkginfo.version())
    end

    return true
end

package = {
    spec = "1",

    -- base info
    name = "gcc",
    description = "GCC, the GNU Compiler Collection",

    authors = {"GNU"},
    licenses = {"GPL"},
    repo = "https://github.com/gcc-mirror/gcc",
    docs = "https://gcc.gnu.org/wiki",

    -- xim pkg info
    type = "package",
    archs = { "x86_64" },
    status = "stable", -- dev, stable, deprecated
    categories = { "compiler", "gnu", "language" },
    keywords = { "compiler", "gnu", "gcc", "language", "c", "c++" },

    programs = {
        "gcc", "g++", "c++", "cpp",
        "gcc-ar", "gcc-nm", "gcc-ranlib",
        "gcov", "gcov-dump", "gcov-tool",
        "x86_64-linux-gnu-gcc", "x86_64-linux-gnu-g++", "x86_64-linux-gnu-c++",
    },

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            deps = {
                "glibc@2.39", "binutils@2.42",
                -- fix xmake project --project=.  -k compile_commands
                -- home/xlings/.xlings_data/subos/linux/usr/include/bits/errno.h:26:11: fatal error: linux/errno.h: No such file or directory
                "linux-headers@5.11.1"
            },
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
            ["13.3.0"] = "XLINGS_RES",
            ["11.5.0"] = "XLINGS_RES",
            ["9.4.0"] = "XLINGS_RES",
        },
        windows = {
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = {}, -- deps mingw64
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")
import("xim.libxpkg.xvm")
import("xim.libxpkg.pkgmanager")
import("xim.libxpkg.elfpatch")

local gcc_tool = {
    ["gcc-ar"] = true, ["gcc-nm"] = true, ["gcc-ranlib"] = true,
    ["gcov"] = true, ["gcov-dump"] = true, ["gcov-tool"] = true,
}

local gcc_lib = {
    -- not include glibc
    "libgcc_s.so", "libgcc_s.so.1",
    "libstdc++.so", "libstdc++.so.6",
    "libatomic.so", "libatomic.so.1",
    -- asan
    "libasan.so", "libasan.so.8",
}

local version_map_gcc2mingw = {
    ["15.1.0"] = "13.0.0",
}

local gcc_libexec_tools = {
    "cc1", "cc1plus", "collect2", "lto-wrapper", "lto1", "f951"
}

function install()
    if is_host("windows") then
        pkgmanager.install("mingw-w64@" .. version_map_gcc2mingw[pkginfo.version()])
    else
        local srcdir = pkginfo.install_file():replace(".tar.gz", "")
        os.tryrm(pkginfo.install_dir())
        os.cp(srcdir, pkginfo.install_dir(), {
            symlink = true,
            verbose = true,
        })

        -- Default manual mode: package author controls loader/rpath patching.
        elfpatch.auto(false)

        local rpath_list = __manual_rpath_list()
        __patch_gcc_binaries(rpath_list)
    end
    return true
end

function config()
    if is_host("windows") then
        -- config in mingw-w64.lua
        return true
    else
        return __config_linux();
    end
end

function uninstall()
    if is_host("windows") then
        pkgmanager.uninstall("mingw-w64@" .. version_map_gcc2mingw[pkginfo.version()])
        return true
    end

    local gcc_version = "gcc-" .. pkginfo.version()
    for _, prog in ipairs(package.programs) do
        if gcc_tool[prog] then
            xvm.remove(prog, gcc_version)
        else
            xvm.remove(prog)
        end
    end

    for _, lib in ipairs(gcc_lib) do
        xvm.remove(lib, gcc_version)
    end

    xvm.remove("xim-gnu-gcc")
    xvm.remove("cc")

    return true
end

-- private

function __config_linux()
    local gcc_bindir = path.join(pkginfo.install_dir(), "bin")
    local ld_lib_path = string.format(path.join(pkginfo.install_dir(), "lib64"))

    xvm.add("xim-gnu-gcc") -- root

    local config = {
        bindir = gcc_bindir,
        binding = "xim-gnu-gcc@" .. pkginfo.version(),
        envs = {
            --["LD_LIBRARY_PATH"] = ld_lib_path,
            --["LD_RUN_PATH"] = ld_lib_path,
        }
    }

    for _, prog in ipairs(package.programs) do
        if gcc_tool[prog] then
            config.version = "gcc-" .. pkginfo.version()
            xvm.add(prog, config)
        else
            config.version = pkginfo.version()
            xvm.add(prog, config)
        end
    end

    -- lib
    log.info("add gcc libs...")
    local lib_config = {
        type = "lib",
        version = "gcc-" .. pkginfo.version(),
        bindir = path.join(pkginfo.install_dir(), "lib64"),
        binding = "xim-gnu-gcc@" .. pkginfo.version(),
    }

    for _, lib in ipairs(gcc_lib) do
        lib_config.filename = lib -- target file name
        lib_config.alias = lib    -- source file name
        xvm.add(lib, lib_config)
    end

    -- "cc"
    xvm.add("cc", {
        alias = "gcc",
        version = pkginfo.version(),
        binding = "xim-gnu-gcc@" .. pkginfo.version(),
    })

    return true
end

function __append_if_libdir_exists(values, root_dir)
    if not root_dir then
        return
    end
    for _, sub in ipairs({"lib64", "lib"}) do
        local d = path.join(root_dir, sub)
        if os.isdir(d) then
            table.insert(values, d)
            return
        end
    end
end

function __manual_rpath_list()
    local values = {}
    __append_if_libdir_exists(values, pkginfo.install_dir())
    __append_if_libdir_exists(values, pkginfo.install_dir("glibc", "2.39"))
    __append_if_libdir_exists(values, pkginfo.install_dir("binutils", "2.42"))
    return values
end

function __patch_one_elf(filepath, rpath_list)
    if not os.isfile(filepath) then
        return
    end
    elfpatch.patch_elf_loader_rpath(filepath, {
        loader = "system",
        rpath = rpath_list,
        strict = false
    })
end

function __patch_gcc_binaries(rpath_list)
    local bindir = path.join(pkginfo.install_dir(), "bin")
    for _, prog in ipairs(package.programs) do
        __patch_one_elf(path.join(bindir, prog), rpath_list)
    end

    local libexec_dir = path.join(
        pkginfo.install_dir(),
        "libexec", "gcc", "x86_64-linux-gnu", pkginfo.version()
    )
    for _, tool in ipairs(gcc_libexec_tools) do
        __patch_one_elf(path.join(libexec_dir, tool), rpath_list)
    end
end

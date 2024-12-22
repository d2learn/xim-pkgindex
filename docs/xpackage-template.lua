package = {
    -- base info
    homepage = "https://example.com",

    name = "package-name",
    description = "Package description",

    authors = "Author Name",
    maintainers = "Maintainer Name or url",
    contributors = "Contributor Name or url",
    license = "MIT",
    repo = "https://example.com/repo",
    docs = "https://example.com/docs",

    -- xim pkg info
    type = "package", -- package, auto-config
    archs = {"x86_64"},
    status = "stable", -- dev, stable, deprecated
    categories = {"category1", "category2"},
    keywords = {"keyword1", "keyword2"},
    date = "2024-12-01",

    -- env info - todo
    xvm_type = "", -- unused
    xvm_support = false, -- unused
    xvm_default = false,

    xpm = {
        windows = {
            deps = {"dep1", "dep2"},
            ["1.0.1"] = {"url", "sha256"},
            ["1.0.0"] = {"url", "sha256"},
        },
        ubuntu = {
            deps = {"dep3", "dep4"},
            ["latest"] = { ref = "1.0.1"},
            ["1.0.1"] = {"url", "sha256"},
            ["1.0.0"] = {"url", "sha256"},
        },
    },
}

-- xim: hooks for package manager

import("xim.base.runtime")

-- pkginfo = runtime.get_pkginfo()
-- pkginfo = {install_file = "", version = "x.x.x"}

-- step 1: support check - package attribute

-- step 2: installed check
function installed()
    print("xpackage-spec: installed")
    return true
end

-- step 2.5: download resources/package
-- step 3: process dependencies - package attribute

-- step 4: build package
function build()
    print("xpackage-spec: build")
    return true
end

-- step 5: install package
function install()
    print("xpackage-spec: install")
    return true
end

-- step 6: configure package
function config()
    print("xpackage-spec: config")
    return true
end

-- step 7: uninstall package
function uninstall()
    print("xpackage-spec: uninstall")
    return true
end
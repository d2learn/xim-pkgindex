package = {
    -- base info
    name = "xlings-project-templates",
    description = "Xlings - Project Templates",

    authors = "d2learn",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xlings-project-templates",

    -- xim pkg info
    type = "template",
    status = "stable", -- dev, stable, deprecated
    categories = {"xlings", "template", "project"},
    keywords = {"project-template"},

    -- xvm: xlings version management
    xvm_enable = true,

    xpm = {
        linux = {
            ["latest"] = {
                url = {
                    ["GLOBAL"] = "https://github.com/d2learn/xlings-project-templates.git",
                    ["CN"] = "https://gitee.com/xlings-res/xlings-project-templates.git",
                },
                sha256 = nil,
            },
        },
        windows = { ref = "linux" },
        macosx = { ref = "linux" },
    }
}
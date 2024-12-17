package = {
    name = "msvc",
    description = "Microsoft Visual Studio C++ Compiler",
    maintainers = "Microsoft",

    type = "auto-config",
    status = "stable",
    maintainers = "Microsoft",
    categories = { "toolchain", "c++", "c", "compiler" },
    keywords = { "msvc", "c++", "c" },

    xpm = {
        windows = {
            deps = { "vs-buildtools@2022" },
            ["latest"] = { ref = "2022" },
            ["2022"] = { } -- v143
        },
    }
}

import("core.tool.toolchain")

-- https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022
local msvc_component = "Microsoft.VisualStudio.Component.VC.Tools.x86.x64"

function installed()
    return toolchain.load("msvc"):check() == "2022"
end

function install()
    os.exec(
        "vs_BuildTools.exe" ..
        -- " --installPath " .. vs_install_path ..
        " --add " .. msvc_component ..
        " --includeRecommended" ..
        -- " --quiet " ..
        " --passive " ..
        -- " --norestart " ..
        " --wait " -- ..
    )
    return true
end

function uninstall()
    os.exec(
        "vs_BuildTools.exe" ..
        " --remove " .. msvc_component ..
        " --passive " ..
        " --wait "
    )
    return true
end
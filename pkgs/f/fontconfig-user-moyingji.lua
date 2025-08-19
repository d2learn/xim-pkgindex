package = {
    -- base info
    name = "fontconfig-user-moyingji",
    description = "Basic user configuration for Linux Fontconfig written by MoYingJi",

    authors = "MoYingJi",
    licenses = "Apache-2.0",

    -- xim pkg info
    type = "config",
    namespace = "config",
    keywords = { "fontconfig", "font", "config" },

    xpm = {
        linux = { ["latest"] = { } },
    },
}





-- 配置

local default_fonts = {
    ["serif"] = {
        "Source Han Serif CN",
        "Noto Serif CJK SC",
    },
    ["sans-serif"] = {
        "Source Han Sans CN",
        "Noto Sans CJK SC",
    },
    ["monospace"] = {
        "JetBrainsMono Nerd Font",
        "JetBrains Mono",
        "Hack",
    },
}

local monospace_fallback = {
    {
        family = { "JetBrainsMono Nerd Font", "JetBrains Mono" },
        target = { "Jetbrains Maple Mono" },
    },
}

local font_replacements = {
    {
        family = { "Microsoft YaHei" },
        target = { "Source Han Sans CN", "Noto Sans CJK SC" },
    },
}

local glyphs_cjk = {
    tw = {
        ["Source Han Sans CN"] = "Source Han Sans TW",
        ["Source Han Serif CN"] = "Source Han Serif TW",
        ["Noto Sans CJK SC"] = "Noto Sans CJK TC",
        ["Noto Serif CJK SC"] = "Noto Serif CJK TC",
    },
    hk = {
        ["Source Han Sans CN"] = "Source Han Sans HK",
        ["Source Han Serif CN"] = "Source Han Serif HK",
        ["Noto Sans CJK SC"] = "Noto Sans CJK HK",
        ["Noto Serif CJK SC"] = "Noto Serif CJK HK",
    },
    jp = {
        ["Source Han Sans CN"] = "Source Han Sans JP",
        ["Source Han Serif CN"] = "Source Han Serif JP",
        ["Noto Sans CJK SC"] = "Noto Sans CJK JP",
        ["Noto Serif CJK SC"] = "Noto Serif CJK JP",
    },
    kr = {
        ["Source Han Sans CN"] = "Source Han Sans KR",
        ["Source Han Serif CN"] = "Source Han Serif KR",
        ["Noto Sans CJK SC"] = "Noto Sans CJK KR",
        ["Noto Serif CJK SC"] = "Noto Serif CJK KR",
    },
}





-- 代码部分

import("xim.libxpkg.log")

local config_dir = os.getenv("XDG_CONFIG_HOME") or path.join(os.getenv("HOME"), ".config")
local config_file = path.join(config_dir, "fontconfig/conf.d/71-fontsconfig-user-moyingji.conf")

function installed()
    if os.exists(config_file) then return true end

    return false
end

function install()
    local dir = path.directory(config_file)
    if not os.isdir(dir) then os.mkdir(dir) end
    io.writefile(config_file, content())

    log.warn("已安装字体配置文件：%s", config_file)
    log.warn("可在此处进行自定义字体，或禁用衬线字体等操作，有注释引导操作")
    log.warn("也可直接编辑包文件中的配置文件，然后重新安装此包")
    log.warn("重启任意软件即可使对应软件的字体生效，重新登录安装了此配置的用户即可使字体对该用户全局生效")
    log.warn("")
    log.warn("推荐安装这些字体以获得最佳体验：")
    log.warn(" - Source Han Sans CN (思源黑体)")
    log.warn(" - Source Han Serif CN (思源宋体 仅衬线字体配置需要)")
    log.warn(" - JetBrainsMono Nerd Font (或 JetBrains Mono)")
    log.warn(" - JetBraiss Maple Mono (仅等宽中文需要)")

    return true
end

function uninstall()
    os.tryrm(config_file)

    return true
end



function content()
    local content = [[
<fontconfig>
    <!-- 本配置为基础配置 能用就行 -->
    <!-- 若要手动编辑配置，请将编辑的语法高亮修改为 XML，但不要修改后缀为 XML，这样会导致配置不识别 -->

    <!-- 默认使用思源，回落到 Noto -->

    <!-- 默认使用无衬线字体 -->
    <match>
        <test name="family"><string>system-ui</string></test>
        <edit name="family" mode="prepend" binding="strong"><string>sans-serif</string></edit>
    </match>

    <!-- 将衬线字体强制替换为无衬线字体 -->
    <!-- 若不喜欢衬线字体 可以取消这里的注释 -->
    <!-- <match target="pattern">
        <test qual="any" name="family"><string>serif</string></test>
        <edit name="family" mode="assign" binding="strong"><string>sans-serif</string></edit>
    </match> -->

    <!-- 默认衬线字体 -->
    <!-- 若已经将衬线字体替换为无衬线字体 那么可以删除下面这段 -->
    <match>
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="prepend" binding="strong">
            <!-- 可在此处新增或修改成你想要的字体 -->
%s
        </edit>
    </match>

    <!-- 默认无衬线字体 -->
    <match>
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="prepend" binding="strong">
            <!-- 可在此处新增或修改成你想要的字体 -->
%s
        </edit>
    </match>

    <!-- 默认等宽字体 -->
    <match>
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="prepend" binding="strong">
            <!-- 可在此处新增或修改成你想要的字体 -->
%s
        </edit>
    </match>


    <!-- 以下内容为自动生成 且普通用户几乎不需要修改 -->
    <!-- 手动复制粘贴配置可能会比较累 不建议这样做 -->
    <!-- 包中提供了快捷配置 可以直接修改包中的配置并重新安装 -->


    <!-- (CJK) 等宽字体回落 -->
%s


    <!-- 字体替换 -->
%s


    <!-- 其他 (CJK) 字形 -->
%s

</fontconfig>
    ]]

    content = string.format(content,
        gen_targets(default_fonts["serif"]),
        gen_targets(default_fonts["sans-serif"]),
        gen_targets(default_fonts["monospace"]),
        gen_font_replacements("append", monospace_fallback),
        gen_font_replacements("assign", font_replacements),
        gen_other_glyphs_config()
    )

    return content
end


function gen_target(fontname)
    return string.format('            <string>%s</string>', fontname)
end

function gen_targets(target)
    local output = {}

    if type(target) == "table" then
        for _, f in ipairs(target) do
            table.insert(output, gen_target(f))
        end
    else
        table.insert(output, gen_target(target))
    end

    return table.concat(output, "\n")
end

function gen_font(fontname, mode, target)
    local output = {}

    table.insert(output, '    <match target="pattern">')
    table.insert(output, string.format('        <test qual="any" name="family"><string>%s</string></test>', fontname))
    table.insert(output, string.format('        <edit name="family" mode="%s" binding="strong">', mode))
    table.insert(output, gen_targets(target))
    table.insert(output, '        </edit>')
    table.insert(output, '    </match>')

    return table.concat(output, "\n")
end

function gen_font_replacements(mode, config)
    local output = {}

    for _, r in ipairs(config) do
        if type(r.family) == "table" then
            for _, t in ipairs(r.family) do
                table.insert(output, gen_font(t, mode, r.target))
            end
        else
            table.insert(output, gen_font(r.family, mode, r.target))
        end
    end

    return table.concat(output, "\n")
end

function gen_other_glyphs_config()
    local output = {}
    for r, m in pairs(glyphs_cjk) do
        table.insert(output, "")
        table.insert(output, "    <!-- " .. r .. " -->")
        for k, v in pairs(m) do
            table.insert(output, '    <match target="pattern">')
            table.insert(output, string.format('        <test name="lang" compare="contains"><string>%s</string></test>', r))
            table.insert(output, string.format('        <test qual="any" name="family"><string>%s</string></test>', k))
            table.insert(output, string.format('        <edit name="family" mode="assign" binding="strong"><string>%s</string></edit>', v))
            table.insert(output, '    </match>')
        end
    end

    return table.concat(output, "\n")
end

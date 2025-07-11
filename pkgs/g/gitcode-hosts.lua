package = {
    -- base info
    name = "gitcode-hosts",
    description = "Config gitcode.com ip mapping-groups to hots file",

    authors = "sunrisepeak",
    licenses = "Apache-2.0",

    -- xim pkg info
    type = "config",
    namespace = "config",

    xpm = {
        windows = { ["latest"] = { } },
        linux = { ["latest"] = { } },
        macosx = { ["latest"] = { } },
    },
}

import("xim.libxpkg.system")
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

local hosts_file = {
    windows = "C:/Windows/System32/drivers/etc/hosts",
    linux = "/etc/hosts",
    macosx = "/etc/hosts"
}


-- https://tools.ipip.net/newping.php
local gitcode_domain_to_ip = [[

116.205.2.91    gitcode.com
116.205.2.45    web-api.gitcode.com
58.20.209.162   cdn-static.gitcode.com
180.153.168.49  file-cdn.gitcode.com

]]

local powershell_script = [[
$source = "$env:SystemRoot\System32\drivers\etc\hosts"
$newHosts = "%s"  # 新 hosts 文件的位置

# 判断是否以管理员权限运行
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # 重新以管理员身份运行自己
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 检查新 hosts 文件是否存在
if (-Not (Test-Path $newHosts)) {
    Write-Error "❌ 新的 hosts 文件未找到: $newHosts"
    exit 1
}

# 覆盖原 hosts 文件
Copy-Item -Path $newHosts -Destination $source -Force
Write-Host "✅ Hosts file replaced with new content from $newHosts"
]]

local hosts_content = io.readfile(hosts_file[os.host()])

function installed()

    if not string.find(hosts_content, "gitcode.com", 1, true) then return false end
    if not string.find(hosts_content, "web-api.gitcode.com", 1, true) then return false end
    if not string.find(hosts_content, "cdn-static.gitcode.com", 1, true) then return false end
    if not string.find(hosts_content, "file-cdn.gitcode.com", 1, true) then return false end

    return true
end

function install()

    -- backup hosts file
    local backup_file = path.join(pkginfo.install_dir(), "hosts.bak")
    io.writefile(backup_file, hosts_content)

    hosts_content = hosts_content .. gitcode_domain_to_ip
    update_hosts(hosts_content)

    return true
end

function uninstall()
    hosts_content = string.replace(
        hosts_content, gitcode_domain_to_ip:trim(), "",
        { plain = true }
    )
    update_hosts(hosts_content)
    return true
end

function update_hosts(new_hosts_content)
    if is_host("windows") then
        local new_hosts = path.join(pkginfo.install_dir(), "hosts")
        io.writefile(new_hosts, new_hosts_content)
        local tmp_script = path.join(pkginfo.install_dir(), "update_hosts.ps1")
        io.writefile(tmp_script, string.format(powershell_script, new_hosts))
        system.exec("powershell -ExecutionPolicy Bypass -File " .. tmp_script)
        os.tryrm(new_hosts)
    else
        local permission = os.iorun([[stat -c "%a" ]] .. hosts_file[os.host()])
        system.exec("sudo chmod 666 " .. hosts_file[os.host()])
        io.writefile(hosts_file[os.host()], new_hosts_content)
        system.exec("sudo chmod " .. permission .. " " .. hosts_file[os.host()])
    end
end
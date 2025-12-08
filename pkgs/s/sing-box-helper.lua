package = {
    -- base info
    name = "sing-box-helper",
    description = "Sing-Box Helper Tools - Simple commands for server and client configuration",

    licenses = "GPL-3.0-or-later",
    repo = "https://github.com/d2learn/xim-pkgindex",

    -- xim pkg info
    type = "script",
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "proxy", "sing-box" },
    keywords = {"sing-box", "helper", "proxy", "server", "client"},

    xpm = {
        debain = {
            deps = {"sing-box"},
            ["1.0.0"] = { }
        },
        ubuntu = { ref = "debain" },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.utils")
import("core.base.base64")

local CONFIG_DIR = path.join(os.scriptdir(), "configs")
local CURRENT_FILE = path.join(CONFIG_DIR, ".current")
local SUBSCRIPTION_FILE = path.join(CONFIG_DIR, ".subscription")
local SYSTEMD_SERVICE = "sing-box.service"

function ensure_config_dir()
    if not os.isdir(CONFIG_DIR) then
        os.mkdir(CONFIG_DIR)
    end
end

function print_usage()
    cprint("\t${bright}Sing-Box Helper Tools - 1.0.0${clear}")
    cprint("")
    cprint("Usage: ${dim cyan}sing-box-helper <command> [options]")
    cprint("")
    cprint("Commands:")
    cprint("  ${dim cyan}server${clear}      - Generate server configuration")
    cprint("  ${dim cyan}client${clear}      - Generate client configuration")
    cprint("  ${dim cyan}config${clear}      - Manage configurations (list, current, etc.)")
    cprint("  ${dim cyan}start${clear}       - Start sing-box with a configuration")
    cprint("  ${dim cyan}stop${clear}        - Stop sing-box service")
    cprint("  ${dim cyan}status${clear}      - Show service status")
    cprint("  ${dim cyan}sub${clear}         - Generate & save subscription link (for server)")
    cprint("  ${dim cyan}getsub${clear}      - Show saved subscription link")
    cprint("  ${dim cyan}import${clear}      - Import configuration from subscription link")
    cprint("  ${dim cyan}help${clear}        - Show this help message")
    cprint("")
    cprint("Examples:")
    cprint("  ${dim cyan}# Server setup")
    cprint("  ${dim cyan}sing-box-helper server --name my-server --port 9875 --protocol shadowsocks --password mypass")
    cprint("  ${dim cyan}sing-box-helper start my-server")
    cprint("  ${dim cyan}sing-box-helper sub")
    cprint("  ${dim cyan}sing-box-helper getsub")
    cprint("")
    cprint("  ${dim cyan}# Client setup")
    cprint("  ${dim cyan}sing-box-helper import ss://YmFzZTI0LXRybWVkYXRlOm15cGFzc0AxLjIuMy40Ojk4NzUjc3MtY29uZmln")
    cprint("  ${dim cyan}sing-box-helper start imported-ss-20251209-120000")
    cprint("")
    cprint("  ${dim cyan}# Config management")
    cprint("  ${dim cyan}sing-box-helper config list")
    cprint("  ${dim cyan}sing-box-helper config current")
    cprint("")
    cprint("${dim}Local proxy (client):${clear}")
    cprint("  ${dim}SOCKS5: 127.0.0.1:1080${clear}")
    cprint("  ${dim}HTTP:   127.0.0.1:1087${clear}")
    cprint("")
end

function get_current_config()
    if os.isfile(CURRENT_FILE) then
        return io.readfile(CURRENT_FILE):trim()
    end
    return nil
end

function set_current_config(name)
    io.writefile(CURRENT_FILE, name)
end

function list_configs()
    ensure_config_dir()
    local configs = os.files(path.join(CONFIG_DIR, "*.json"))
    
    cprint("${bright}Available configurations:${clear}")
    if not configs or #configs == 0 then
        cprint("  ${dim}(none)${clear}")
        return
    end
    
    local current = get_current_config()
    for _, config_file in ipairs(configs) do
        local name = path.basename(config_file):replace(".json", "")
        if name ~= ".current" then
            local marker = (current == name) and "${green}✓${clear}" or " "
            cprint(string.format("  %s %s", marker, name))
        end
    end
end

function show_current_config()
    local current = get_current_config()
    if current then
        cprint(string.format("${bright}Current configuration:${clear} ${yellow}%s${clear}", current))
    else
        cprint("${yellow}No configuration is currently selected${clear}")
    end
end

function generate_server_config(args)
    ensure_config_dir()
    
    local name = args.name or "server-" .. os.date("%Y%m%d-%H%M%S")
    local port = tonumber(args.port) or 9875
    local protocol = args.protocol or "shadowsocks"
    local password = args.password or "example-password-123"
    local method = args.method or "aes-256-gcm"
    
    log.info("Generating server configuration: %s (%s on port %d)", name, protocol, port)
    
    local config_file = path.join(CONFIG_DIR, name .. ".json")
    
    -- Write config as JSON (simple format)
    local json_str
    if protocol == "shadowsocks" then
        json_str = string.format([[{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss-in",
      "listen": "0.0.0.0",
      "listen_port": %d,
      "method": "%s",
      "password": "%s",
      "network": "tcp,udp"
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}]], port, method, password)
    elseif protocol == "trojan" then
        json_str = string.format([[{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "trojan",
      "tag": "trojan-in",
      "listen": "0.0.0.0",
      "listen_port": %d,
      "password": "%s"
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}]], port, password)
    else
        cprint("${red}✗${clear} Unsupported protocol: %s", protocol)
        return false
    end
    
    io.writefile(config_file, json_str)
    log.info("Server config saved to: %s", config_file)
    cprint(string.format("${green}✓${clear} Server configuration saved: ${yellow}%s${clear}", name))
    
    return true
end

function generate_client_config(args)
    ensure_config_dir()
    
    local name = args.name or "client-" .. os.date("%Y%m%d-%H%M%S")
    local server = args.server or "127.0.0.1"
    local port = tonumber(args.port) or 9875
    local protocol = args.protocol or "shadowsocks"
    local password = args.password or "example-password-123"
    local method = args.method or "aes-256-gcm"
    
    log.info("Generating client configuration: %s (%s to %s:%d)", name, protocol, server, port)
    
    local json_str = string.format([[{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-remote",
        "address": "https://1.1.1.1/dns-query",
        "strategy": "ipv4_only"
      },
      {
        "tag": "dns-direct",
        "address": "local",
        "strategy": "ipv4_only"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-remote"
      }
    ],
    "final": "dns-remote"
  },
  "inbounds": [
    {
      "type": "socks",
      "tag": "socks-in",
      "listen": "127.0.0.1",
      "listen_port": 1080,
      "sniff": true
    },
    {
      "type": "http",
      "tag": "http-in",
      "listen": "127.0.0.1",
      "listen_port": 1087,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "%s",
      "tag": "ss-out",
      "server": "%s",
      "server_port": %d,
      "method": "%s",
      "password": "%s",
      "network": "tcp,udp"
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rule_set": [],
    "rules": [
      {
        "protocol": "dns",
        "outbound": "direct"
      },
      {
        "domain_suffix": [
          "local",
          "lan"
        ],
        "outbound": "direct"
      }
    ],
    "final": "ss-out",
    "auto_detect_interface": true
  }
}]], protocol, server, port, method, password)
    
    local config_file = path.join(CONFIG_DIR, name .. ".json")
    io.writefile(config_file, json_str)
    log.info("Client config saved to: %s", config_file)
    cprint(string.format("${green}✓${clear} Client configuration saved: ${yellow}%s${clear}", name))
    
    return true
end

function parse_args(...)
    local args = {}
    local cmds = {...}
    
    for i = 1, #cmds do
        local arg = cmds[i]
        if arg:startswith("--") then
            local key = arg:sub(3)
            if i < #cmds and not cmds[i+1]:startswith("--") then
                args[key] = cmds[i+1]
            else
                args[key] = true
            end
        end
    end
    
    return args
end

function create_systemd_service(config_name)
    local config_file = path.join(CONFIG_DIR, config_name .. ".json")
    
    if not os.isfile(config_file) then
        log.warn("Configuration not found: %s", config_file)
        return false
    end
    
    -- TODO: Adjust sing-box binary path if needed
    local sing_box_bin = "/home/xlings/.xlings_data/bin/sing-box"
    
    local service_content = string.format([[
[Unit]
Description=Sing-Box Proxy Service (%s)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=%s
ExecStart=%s run -c %s
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
]], config_name, CONFIG_DIR, sing_box_bin, config_file)
    
    log.info("Creating systemd service file...")
    system.run_in_script(string.format('echo "%s" | sudo tee /etc/systemd/system/%s > /dev/null', service_content, SYSTEMD_SERVICE))
    os.exec("sudo systemctl daemon-reload")
    
    return true
end

function start_config(config_name)
    ensure_config_dir()
    
    local config_file = path.join(CONFIG_DIR, config_name .. ".json")
    
    if not os.isfile(config_file) then
        cprint(string.format("${red}✗${clear} Configuration not found: ${yellow}%s${clear}", config_name))
        return false
    end
    
    set_current_config(config_name)
    log.info("Selected configuration: %s", config_name)
    
    -- Create and start systemd service
    if create_systemd_service(config_name) then
        return try {
            function()
                os.exec("sudo systemctl restart sing-box.service")
                os.exec("sudo systemctl enable sing-box.service")
                cprint(string.format("${green}✓${clear} Sing-box started with configuration: ${yellow}%s${clear}", config_name))
                return true
            end, catch {
                function(err)
                    cprint("${red}✗${clear} Failed to start sing-box service: %s", err)
                    return false
                end
            }
        }
    end
    
    return false
end

function stop_service()
    log.info("Stopping sing-box service...")
    os.exec("sudo systemctl stop sing-box.service")
    cprint("${green}✓${clear} Sing-box service stopped")
    return true
end

function show_status()
    try {
        function()
            os.exec("sudo systemctl status sing-box.service")
        end, catch {
            function(err)
                --cprint("${red}✗${clear} Failed to get service status: %s", err)
            end
        }
    }
end

function handle_config_command(subcmd, ...)
    if subcmd == "list" then
        list_configs()
    elseif subcmd == "current" then
        show_current_config()
    else
        cprint("${yellow}Unknown config subcommand: ${yellow}%s${clear}", subcmd or "none")
        cprint("Available: list, current")
    end
end

function parse_config_file(config_file)
    if not os.isfile(config_file) then
        return nil
    end
    
    local content = io.readfile(config_file)
    -- Simple JSON parsing for inbounds
    local protocol = content:match('"type"%s*:%s*"([^"]+)"')
    local port = content:match('"listen_port"%s*:%s*(%d+)')
    local password = content:match('"password"%s*:%s*"([^"]+)"')
    local method = content:match('"method"%s*:%s*"([^"]+)"')
    
    return {
        protocol = protocol,
        port = tonumber(port),
        password = password,
        method = method
    }
end

function url_encode(str)
    -- URL encode a string for use in subscription links
    return str:gsub(" ", "%%20"):gsub("([^%w%-_%.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

-- Base64 encoding/decoding using framework built-in module

function generate_subscription_link()
    local current = get_current_config()
    if not current then
        cprint("${yellow}No configuration is currently running${clear}")
        return
    end
    
    local config_file = path.join(CONFIG_DIR, current .. ".json")
    local config = parse_config_file(config_file)
    
    if not config then
        cprint("${red}✗${clear} Failed to parse configuration file")
        return
    end
    
    -- Check if it's a server config (listen on 0.0.0.0)
    local content = io.readfile(config_file)
    if not content:match('"listen"%s*:%s*"0.0.0.0"') then
        cprint("${yellow}Current configuration is not a server${clear}")
        return
    end
    
    -- Get server IP
    local server_ip = os.iorun("curl -s ifconfig.me"):trim()
    if not server_ip or server_ip == "" then
        server_ip = "YOUR_SERVER_IP"
    end
    
    local sub_link = ""
    local config_name = current
    
    if config.protocol == "shadowsocks" then
        -- Shadowsocks format: ss://BASE64(method:password)@server:port#name
        local method = config.method or "aes-256-gcm"
        local password = config.password
        
        -- Generate base64 encoded auth: base64(method:password)
        local auth_str = method .. ":" .. password
        local auth_encoded = base64.encode(auth_str)
        
        -- URL encode the config name
        local name_encoded = url_encode(config_name)
        
        sub_link = string.format("ss://%s@%s:%d#%s", auth_encoded, server_ip, config.port, name_encoded)
    elseif config.protocol == "trojan" then
        -- Trojan format: trojan://password@server:port#name
        local name_encoded = url_encode(config_name)
        sub_link = string.format("trojan://%s@%s:%d#%s", config.password, server_ip, config.port, name_encoded)
    else
        cprint("${yellow}Protocol '%s' subscription link generation not yet supported${clear}", config.protocol)
        return
    end
    
    -- Save subscription link to file
    io.writefile(SUBSCRIPTION_FILE, sub_link)
    
    cprint("")
    cprint("${bright}Subscription Link:${clear}")
    cprint("${green}%s${clear}", sub_link)
    cprint("")
    cprint("${dim}Server: %s:%d${clear}", server_ip, config.port)
    cprint("${dim}Protocol: %s${clear}", config.protocol)
    cprint("${dim}Method: %s${clear}", config.method or "aes-256-gcm")
    cprint("${dim}Config name: %s${clear}", config_name)
    cprint("")
    cprint("${yellow}Link saved to: %s${clear}", SUBSCRIPTION_FILE)
    cprint("")
end

function show_subscription_link()
    if os.isfile(SUBSCRIPTION_FILE) then
        local sub_link = io.readfile(SUBSCRIPTION_FILE):trim()
        cprint("${bright}Saved Subscription Link:${clear}")
        cprint("${green}%s${clear}", sub_link)
        cprint("")
    else
        cprint("${yellow}No subscription link has been generated yet${clear}")
    end
end

function import_from_link(link)
    if not link then
        -- Try to read from subscription file
        if os.isfile(SUBSCRIPTION_FILE) then
            link = io.readfile(SUBSCRIPTION_FILE):trim()
            cprint("${dim}Using saved subscription link...${clear}")
        else
            cprint("${yellow}Please provide a subscription link${clear}")
            cprint("Usage: sing-box-helper import <link>")
            cprint("       sing-box-helper import  (uses saved link)")
            return
        end
    end
    
    ensure_config_dir()
    
    local protocol, data = link:match("^(%w+)://(.+)$")
    
    if not protocol then
        cprint("${red}✗${clear} Invalid subscription link format")
        return
    end
    
    local server, port, password, method, config_name
    
    if protocol == "ss" then
        -- Parse ss://BASE64(method:password)@server:port#name
        local auth_encoded, host_port, name_part
        auth_encoded, host_port, name_part = data:match("^([^@]+)@([^#]+)#?(.*)$")
        
        if not auth_encoded or not host_port then
            cprint("${red}✗${clear} Invalid SS link format")
            return
        end
        
        server, port = host_port:match("^([^:]+):(%d+)$")
        if not server or not port then
            cprint("${red}✗${clear} Failed to parse server and port")
            return
        end
        
        -- Decode base64 to get method:password
        local decoded = base64.decode(auth_encoded)
        method, password = decoded:match("^([^:]+):(.+)$")
        
        if not method or not password then
            cprint("${red}✗${clear} Failed to decode authentication info from: %s", auth_encoded)
            cprint("${dim}Decoded: %s${clear}", decoded)
            return
        end
        
        -- URL decode the name part if present
        if name_part and name_part ~= "" then
            -- Simple URL decode for common cases
            config_name = name_part:gsub("%%20", " "):gsub("%%([0-9A-Fa-f][0-9A-Fa-f])", function(hex)
                return string.char(tonumber(hex, 16))
            end)
        else
            config_name = "imported-ss-" .. os.date("%Y%m%d-%H%M%S")
        end
    elseif protocol == "trojan" then
        -- Parse trojan://password@server:port#name
        local host_port, name_part
        password, host_port, name_part = data:match("^([^@]+)@([^#]+)#?(.*)$")
        
        if not password or not host_port then
            cprint("${red}✗${clear} Invalid Trojan link format")
            return
        end
        
        server, port = host_port:match("^([^:]+):(%d+)$")
        if not server or not port then
            cprint("${red}✗${clear} Failed to parse server and port")
            return
        end
        
        if name_part and name_part ~= "" then
            config_name = name_part
        else
            config_name = "imported-trojan-" .. os.date("%Y%m%d-%H%M%S")
        end
    else
        cprint("${red}✗${clear} Unsupported protocol: %s", protocol)
        return
    end
    
    if not server or not port then
        cprint("${red}✗${clear} Failed to parse subscription link")
        return
    end
    
    -- Generate client config
    local json_str
    if protocol == "ss" or protocol == "shadowsocks" then
        json_str = string.format([[{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-remote",
        "address": "https://1.1.1.1/dns-query",
        "strategy": "ipv4_only"
      },
      {
        "tag": "dns-direct",
        "address": "local",
        "strategy": "ipv4_only"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-remote"
      }
    ],
    "final": "dns-remote"
  },
  "inbounds": [
    {
      "type": "socks",
      "tag": "socks-in",
      "listen": "127.0.0.1",
      "listen_port": 1080,
      "sniff": true
    },
    {
      "type": "http",
      "tag": "http-in",
      "listen": "127.0.0.1",
      "listen_port": 1087,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss-out",
      "server": "%s",
      "server_port": %s,
      "method": "%s",
      "password": "%s",
      "network": "tcp,udp"
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rule_set": [],
    "rules": [
      {
        "protocol": "dns",
        "outbound": "direct"
      },
      {
        "domain_suffix": [
          "local",
          "lan"
        ],
        "outbound": "direct"
      }
    ],
    "final": "ss-out",
    "auto_detect_interface": true
  }
}]], server, port, method or "aes-256-gcm", password)
    elseif protocol == "trojan" then
        json_str = string.format([[{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-remote",
        "address": "https://1.1.1.1/dns-query",
        "strategy": "ipv4_only"
      },
      {
        "tag": "dns-direct",
        "address": "local",
        "strategy": "ipv4_only"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-remote"
      }
    ],
    "final": "dns-remote"
  },
  "inbounds": [
    {
      "type": "socks",
      "tag": "socks-in",
      "listen": "127.0.0.1",
      "listen_port": 1080,
      "sniff": true
    },
    {
      "type": "http",
      "tag": "http-in",
      "listen": "127.0.0.1",
      "listen_port": 1087,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "trojan",
      "tag": "trojan-out",
      "server": "%s",
      "server_port": %s,
      "password": "%s"
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rule_set": [],
    "rules": [
      {
        "protocol": "dns",
        "outbound": "direct"
      },
      {
        "domain_suffix": [
          "local",
          "lan"
        ],
        "outbound": "direct"
      }
    ],
    "final": "trojan-out",
    "auto_detect_interface": true
  }
}]], server, port, password)
    else
        cprint("${red}✗${clear} Unsupported protocol: %s", protocol)
        return
    end
    
    local config_file = path.join(CONFIG_DIR, config_name .. ".json")
    io.writefile(config_file, json_str)
    
    cprint("")
    cprint(string.format("${green}✓${clear} Configuration imported: ${yellow}%s${clear}", config_name))
    cprint("${dim}Server: %s:%s${clear}", server, port)
    cprint("${dim}Protocol: %s${clear}", protocol)
    if method then
        cprint("${dim}Method: %s${clear}", method)
    end
    cprint("")
    cprint("Start with: ${cyan}sing-box-helper start %s${clear}", config_name)
end

function xpkg_main(command, ...)
    
    if not command or command == "help" or command == "-h" or command == "--help" then
        print_usage()
        return
    end
    
    local args = parse_args(...)
    
    if command == "server" then
        generate_server_config(args)
    elseif command == "client" then
        generate_client_config(args)
    elseif command == "config" then
        handle_config_command(...)
    elseif command == "start" then
        local config_name = ({...})[1]
        if not config_name then
            cprint("${yellow}Please specify a configuration name${clear}")
            cprint("Usage: sing-box-helper start <config-name>")
            return
        end
        start_config(config_name)
    elseif command == "stop" then
        stop_service()
    elseif command == "status" then
        show_status()
    elseif command == "sub" or command == "subscription" then
        generate_subscription_link()
    elseif command == "getsub" or command == "show-sub" then
        show_subscription_link()
    elseif command == "import" then
        local link = ({...})[1]
        import_from_link(link)
    else
        log.warn("Unknown command: %s", command)
        print_usage()
    end
end

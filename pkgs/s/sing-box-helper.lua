package = {
    spec = "1",
    -- base info
    name = "sing-box-helper",
    description = "Sing-Box Helper Tools - Simple commands for server and client configuration",

    licenses = {"GPL-3.0-or-later"},
    repo = "https://github.com/d2learn/xim-pkgindex",

    -- xim pkg info
    type = "script",
    status = "stable", -- dev, stable, deprecated
    categories = {"tools", "proxy", "sing-box" },
    keywords = {"sing-box", "helper", "proxy", "server", "client"},

    xpm = {
        debian = {
            deps = {"sing-box"},
            ["1.0.0"] = { }
        },
        ubuntu = { ref = "debian" },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.utils")

import("xim.libxpkg.base64")
import("xim.libxpkg.json")

local SYSTEMD_SERVICE = "sing-box.service"

local function get_config_dir()
    return path.join(system.xpkgdir(), "configs")
end

local function get_current_file()
    return path.join(get_config_dir(), ".current")
end

local function get_subscription_file()
    return path.join(get_config_dir(), ".subscription")
end

function ensure_config_dir()
    if not os.isdir(get_config_dir()) then
        os.mkdir(get_config_dir())
    end
end

function print_usage()
    log.debug("\t${bright}Sing-Box Helper Tools - 1.0.0${clear}")
    log.debug("")
    log.debug("Usage: ${dim cyan}sing-box-helper <command> [options]")
    log.debug("")
    log.debug("Commands:")
    log.debug("  ${dim cyan}server${clear}      - Generate server configuration")
    log.debug("  ${dim cyan}client${clear}      - Generate client configuration")
    log.debug("  ${dim cyan}config${clear}      - Manage configurations (list, current, etc.)")
    log.debug("  ${dim cyan}start${clear}       - Start sing-box with a configuration")
    log.debug("  ${dim cyan}stop${clear}        - Stop sing-box service")
    log.debug("  ${dim cyan}status${clear}      - Show service status")
    log.debug("  ${dim cyan}sub${clear}         - Generate & save subscription link (for server)")
    log.debug("  ${dim cyan}getsub${clear}      - Show saved subscription link")
    log.debug("  ${dim cyan}import${clear}      - Import configuration from subscription link")
    log.debug("  ${dim cyan}help${clear}        - Show this help message")
    log.debug("")
    log.debug("Examples:")
    log.debug("  ${dim cyan}# Server setup")
    log.debug("  ${dim cyan}sing-box-helper server --name my-server --port 9875 --protocol shadowsocks --password mypass")
    log.debug("  ${dim cyan}sing-box-helper start my-server")
    log.debug("  ${dim cyan}sing-box-helper sub")
    log.debug("  ${dim cyan}sing-box-helper getsub")
    log.debug("")
    log.debug("  ${dim cyan}# Client setup")
    log.debug("  ${dim cyan}sing-box-helper import ss://YmFzZTI0LXRybWVkYXRlOm15cGFzc0AxLjIuMy40Ojk4NzUjc3MtY29uZmln")
    log.debug("  ${dim cyan}sing-box-helper start imported-ss-20251209-120000")
    log.debug("")
    log.debug("  ${dim cyan}# Config management")
    log.debug("  ${dim cyan}sing-box-helper config list")
    log.debug("  ${dim cyan}sing-box-helper config current")
    log.debug("")
    log.debug("${dim}Local proxy (client):${clear}")
    log.debug("  ${dim}SOCKS5: 127.0.0.1:1080${clear}")
    log.debug("  ${dim}HTTP:   127.0.0.1:1087${clear}")
    log.debug("")
end

function get_current_config()
    if os.isfile(get_current_file()) then
        return io.readfile(get_current_file()):trim()
    end
    return nil
end

function set_current_config(name)
    io.writefile(get_current_file(), name)
end

function list_configs()
    ensure_config_dir()
    local configs = {}
    local f = io.popen('ls "' .. get_config_dir() .. '"/*.json 2>/dev/null')
    if f then
        for line in f:lines() do
            local clean = line:gsub("[\r\n]+$", "")
            if clean ~= "" then table.insert(configs, clean) end
        end
        f:close()
    end

    log.debug("${bright}Available configurations:${clear}")
    if #configs == 0 then
        log.debug("  ${dim}(none)${clear}")
        return
    end

    local current = get_current_config()
    for _, config_file in ipairs(configs) do
        local name = path.filename(config_file):gsub("%.json$", "")
        if name ~= ".current" then
            local marker = (current == name) and "${green}✓${clear}" or " "
            log.debug(string.format("  %s %s", marker, name))
        end
    end
end

function show_current_config()
    local current = get_current_config()
    if current then
        log.debug(string.format("${bright}Current configuration:${clear} ${yellow}%s${clear}", current))
    else
        log.debug("${yellow}No configuration is currently selected${clear}")
    end
end

function generate_server_config(args)
    ensure_config_dir()
    
    local name = args.name or "server-" .. os.date("%Y%m%d-%H%M%S")
    local port = tonumber(args.port) or 9875
    local protocol = args.protocol or "shadowsocks"
    -- password is nil, randomly generate one if not provided
    local password = args.password or (os.iorun("sing-box generate rand --base64 18"):trim())
    local method = args.method or "aes-256-gcm"
    
    log.info("Generating server configuration: %s (%s on port %d)", name, protocol, port)
    
    local config_file = path.join(get_config_dir(), name .. ".json")
    
    -- Build config table and save via json module (simpler and safer)
    local config_tbl
    if protocol == "shadowsocks" then
        config_tbl = {
            log = { level = "info", timestamp = true },
            inbounds = { {
                type = "shadowsocks",
                tag = "ss-in",
                listen = "0.0.0.0",
                listen_port = port,
                method = method,
                password = password,
                network = { "tcp", "udp" },
            } },
            outbounds = { { type = "direct", tag = "direct" } },
        }
    elseif protocol == "trojan" then
        config_tbl = {
            log = { level = "info", timestamp = true },
            inbounds = { {
                type = "trojan",
                tag = "trojan-in",
                listen = "0.0.0.0",
                listen_port = port,
                password = password,
            } },
            outbounds = { { type = "direct", tag = "direct" } },
        }
    else
        log.debug("${red}✗${clear} Unsupported protocol: %s", protocol)
        return false
    end
    
    json.savefile(config_file, config_tbl, { indent = true })
    log.info("Server config saved to: %s", config_file)
    log.debug(string.format("${green}✓${clear} Server configuration saved: ${yellow}%s${clear}", name))
    
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
    
    local config_tbl = {
        log = { level = "info", timestamp = true },
        dns = {
            servers = {
                { type = "https", server = "1.1.1.1", tag = "dns-remote" },
                { type = "local", tag = "dns-direct" },
            },
            rules = {},
            final = "dns-remote",
        },
        inbounds = {
            { type = "socks", tag = "socks-in", listen = "127.0.0.1", listen_port = 1080, sniff = true },
            { type = "http", tag = "http-in", listen = "127.0.0.1", listen_port = 1087, sniff = true },
        },
        outbounds = {
            {
                type = protocol,
                tag = (protocol == "trojan" and "trojan-out" or "ss-out"),
                server = server,
                server_port = tonumber(port),
                method = method,
                password = password,
                network = { "tcp", "udp" },
                domain_resolver = {
                    server = "dns-direct",
                    strategy = "prefer_ipv4",
                },
            },
            { type = "direct", tag = "direct" },
            { type = "block", tag = "block" },
        },
        route = {
            rules = {
                { protocol = "dns", outbound = "direct" },
                { domain_suffix = { "local", "lan" }, outbound = "direct" },
            },
            final = (protocol == "trojan" and "trojan-out" or "ss-out"),
            auto_detect_interface = true,
            default_domain_resolver = {
                server = "dns-direct",
                strategy = "prefer_ipv4",
            },
        },
    }

    local config_file = path.join(get_config_dir(), name .. ".json")
    json.savefile(config_file, config_tbl, { indent = true })
    log.info("Client config saved to: %s", config_file)
    log.debug(string.format("${green}✓${clear} Client configuration saved: ${yellow}%s${clear}", name))
    
    return true
end

function parse_args(...)
    local args = {}
    local cmds = {...}
    
    for i = 1, #cmds do
        local arg = cmds[i]
        if arg:sub(1, 2) == "--" then
            local key = arg:sub(3)
            if i < #cmds and cmds[i+1]:sub(1, 2) ~= "--" then
                args[key] = cmds[i+1]
            else
                args[key] = true
            end
        end
    end
    
    return args
end

function create_systemd_service(config_name)
    local config_file = path.join(get_config_dir(), config_name .. ".json")
    
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
]], config_name, get_config_dir(), sing_box_bin, config_file)

    -- check config file (singbox check -c <config>)
    log.info("Checking configuration file...")
    local check_cmd = string.format('%s check -c %s', sing_box_bin, config_file)
    local output = os.iorun(check_cmd)

    if not output then
        log.debug("${red}✗${clear} Configuration check failed: %s", output)
        return false
    end

    log.info("Creating systemd service file...")
    system.run_in_script(string.format('echo "%s" | sudo tee /etc/systemd/system/%s > /dev/null', service_content, SYSTEMD_SERVICE))
    os.exec("sudo systemctl daemon-reload")
    
    return true
end

function start_config(config_name)
    ensure_config_dir()
    
    local config_file = path.join(get_config_dir(), config_name .. ".json")
    
    if not os.isfile(config_file) then
        log.debug(string.format("${red}✗${clear} Configuration not found: ${yellow}%s${clear}", config_name))
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
                -- TODO: check port - sudo ss -lunp | grep :port
                log.debug("checking port - [ sudo ss -lunp | grep :%s ]", parse_config_file(config_file).port)
                log.debug(string.format("${green}✓${clear} Sing-box started with configuration: ${yellow}%s${clear}", config_name))                
                return true
            end, catch {
                function(err)
                    log.debug("${red}✗${clear} Failed to start sing-box service: %s", err)
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
    log.debug("${green}✓${clear} Sing-box service stopped")
    return true
end

function show_status()
    try {
        function()
            os.exec("sudo systemctl status sing-box.service")
        end, catch {
            function(err)
                --log.debug("${red}✗${clear} Failed to get service status: %s", err)
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
        log.debug("${yellow}Unknown config subcommand: ${yellow}%s${clear}", subcmd or "none")
        log.debug("Available: list, current")
    end
end

function parse_config_file(config_file)
    if not os.isfile(config_file) then
        return nil
    end
    
    local cfg = json.loadfile(config_file)
    if not cfg or not cfg.inbounds or #cfg.inbounds == 0 then
        return nil
    end

    local inbound = cfg.inbounds[1]
    return {
        protocol = inbound.type,
        port = inbound.listen_port,
        password = inbound.password,
        method = inbound.method,
        listen = inbound.listen,
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
        log.debug("${yellow}No configuration is currently running${clear}")
        return
    end
    
    local config_file = path.join(get_config_dir(), current .. ".json")
    local config = parse_config_file(config_file)
    
    if not config then
        log.debug("${red}✗${clear} Failed to parse configuration file")
        return
    end

    -- Check if it's a server config (listen on 0.0.0.0)
    if config.listen ~= "0.0.0.0" then
        log.debug("${yellow}Current configuration is not a server${clear}")
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
        log.debug("${yellow}Protocol '%s' subscription link generation not yet supported${clear}", config.protocol)
        return
    end
    
    -- Save subscription link to file
    io.writefile(get_subscription_file(), sub_link)
    
    log.debug("")
    log.debug("${bright}Subscription Link:${clear}")
    log.debug("${green}%s${clear}", sub_link)
    log.debug("")
    log.debug("${dim}Server: %s:%d${clear}", server_ip, config.port)
    log.debug("${dim}Protocol: %s${clear}", config.protocol)
    log.debug("${dim}Method: %s${clear}", config.method or "aes-256-gcm")
    log.debug("${dim}Config name: %s${clear}", config_name)
    log.debug("")
    log.debug("${yellow}Link saved to: %s${clear}", get_subscription_file())
    log.debug("")
end

function show_subscription_link()
    if os.isfile(get_subscription_file()) then
        local sub_link = io.readfile(get_subscription_file()):trim()
        log.debug("${bright}Saved Subscription Link:${clear}")
        log.debug("${green}%s${clear}", sub_link)
        log.debug("")
    else
        log.debug("${yellow}No subscription link has been generated yet${clear}")
    end
end

function import_from_link(link)
    if not link then
        -- Try to read from subscription file
        if os.isfile(get_subscription_file()) then
            link = io.readfile(get_subscription_file()):trim()
            log.debug("${dim}Using saved subscription link...${clear}")
        else
            log.debug("${yellow}Please provide a subscription link${clear}")
            log.debug("Usage: sing-box-helper import <link>")
            log.debug("       sing-box-helper import  (uses saved link)")
            return
        end
    end
    
    ensure_config_dir()
    
    log.debug("link: " .. link)

    local protocol, data = link:match("^(%w+)://(.+)$")

    --print("protocol: " .. tostring(protocol))
    --print("data: " .. tostring(data))

    if not protocol then
        log.debug("${red}✗${clear} Invalid subscription link format")
        return
    end
    
    local server, port, password, method, config_name
    
    if protocol == "ss" then
        -- Parse ss://BASE64(method:password)@server:port#name
        local auth_encoded, host_port, name_part
        auth_encoded, host_port, name_part = data:match("^([^@]+)@([^#]+)#?(.*)$")
        
        if not auth_encoded or not host_port then
            log.debug("${red}✗${clear} Invalid SS link format")
            return
        end
        
        server, port = host_port:match("^([^:]+):(%d+)$")
        if not server or not port then
            log.debug("${red}✗${clear} Failed to parse server and port")
            return
        end
        
        -- Decode base64 to get method:password
        local decoded = base64.decode(auth_encoded)
        method, password = decoded:match("^([^:]+):(.+)$")

        if not method or not password then
            log.debug("${red}✗${clear} Failed to decode authentication info from: %s", auth_encoded)
            log.debug("${dim}Decoded: %s${clear}", decoded)
            return
        end
        
        if name_part and name_part ~= "" then
            config_name = name_part
        else
            config_name = "imported-ss-" .. os.date("%Y%m%d-%H%M%S")
        end
    elseif protocol == "trojan" then
        -- Parse trojan://password@server:port#name
        local host_port, name_part
        password, host_port, name_part = data:match("^([^@]+)@([^#]+)#?(.*)$")
        
        if not password or not host_port then
            log.debug("${red}✗${clear} Invalid Trojan link format")
            return
        end
        
        server, port = host_port:match("^([^:]+):(%d+)$")
        if not server or not port then
            log.debug("${red}✗${clear} Failed to parse server and port")
            return
        end
        
        if name_part and name_part ~= "" then
            config_name = name_part
        else
            config_name = "imported-trojan-" .. os.date("%Y%m%d-%H%M%S")
        end
    else
        log.debug("${red}✗${clear} Unsupported protocol: %s", protocol)
        return
    end
    
    if not server or not port then
        log.debug("${red}✗${clear} Failed to parse subscription link")
        return
    end
    
        -- Generate client config tables and save via json
        local function base_client_table()
                return {
                        log = { level = "info", timestamp = true },
                        dns = {
                                servers = {
                                        { type = "https", server = "1.1.1.1", tag = "dns-remote" },
                                        { type = "local", tag = "dns-direct" },
                                },
                                rules = {},
                                final = "dns-remote",
                        },
                        inbounds = {
                                { type = "socks", tag = "socks-in", listen = "127.0.0.1", listen_port = 1080, sniff = true },
                                { type = "http", tag = "http-in", listen = "127.0.0.1", listen_port = 1087, sniff = true },
                        },
                        outbounds = {},
                        route = {
                                rules = {
                                        { protocol = "dns", outbound = "direct" },
                                        { domain_suffix = { "local", "lan" }, outbound = "direct" },
                                },
                                final = "ss-out",
                                auto_detect_interface = true,
                                default_domain_resolver = {
                                        server = "dns-direct",
                                        strategy = "prefer_ipv4",
                                },
                        },
                }
        end

        local cfg_tbl
        if protocol == "ss" or protocol == "shadowsocks" then
                cfg_tbl = base_client_table()
                cfg_tbl.outbounds = {
                        { 
                            type = "shadowsocks", 
                            tag = "ss-out", 
                            server = server, 
                            server_port = tonumber(port), 
                            method = method or "aes-256-gcm", 
                            password = password, 
                            network = {"tcp","udp"},
                            domain_resolver = {
                                server = "dns-direct",
                                strategy = "prefer_ipv4",
                            },
                        },
                        { type = "direct", tag = "direct" },
                        { type = "block", tag = "block" },
                }
                cfg_tbl.route.final = "ss-out"
        elseif protocol == "trojan" then
                cfg_tbl = base_client_table()
                cfg_tbl.outbounds = {
                        { 
                            type = "trojan", 
                            tag = "trojan-out", 
                            server = server, 
                            server_port = tonumber(port), 
                            password = password,
                            domain_resolver = {
                                server = "dns-direct",
                                strategy = "prefer_ipv4",
                            },
                        },
                        { type = "direct", tag = "direct" },
                        { type = "block", tag = "block" },
                }
                cfg_tbl.route.final = "trojan-out"
        else
                log.debug("${red}✗${clear} Unsupported protocol: %s", protocol)
                return
        end

        local config_file = path.join(get_config_dir(), config_name .. ".json")
        json.savefile(config_file, cfg_tbl, { indent = true })
    
    log.debug("")
    log.debug(string.format("${green}✓${clear} Configuration imported: ${yellow}%s${clear}", config_name))
    log.debug("${dim}Server: %s:%s${clear}", server, port)
    log.debug("${dim}Protocol: %s${clear}", protocol)
    if method then
        log.debug("${dim}Method: %s${clear}", method)
    end
    log.debug("")
    log.debug("Start with: ${cyan}sing-box-helper start %s${clear}", config_name)
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
            log.debug("${yellow}Please specify a configuration name${clear}")
            log.debug("Usage: sing-box-helper start <config-name>")
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

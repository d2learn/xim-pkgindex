-- https://github.com/orgs/community/discussions/174283#discussioncomment-14533335

package = {
    -- base info
    name = "github-notifications-clear",
    description = "Clear github's notifications (unread)",

    maintainers = "d2learn",
    licenses = "Apache-2.0",
    repo = "https://github.com/d2learn/xim-pkgindex",
    docs = "https://github.com/orgs/community/discussions/174283",

    -- xim pkg info
    type = "script",
    status = "stable", -- dev, stable, deprecated
    categories = { "tools", "github", "notifications" },

    xpm = {
        linux = {
            ["latest"] = { ref = "0.0.1" },
            ["0.0.1"] = {},
        },
        windows = { ref = "linux" },
        macosx = { ref = "linux" },
    },
}

import("core.base.json")
import("lib.detect.find_tool")

import("xim.libxpkg.log")

function xpkg_main(person_access_token)
    if not person_access_token then
        log.error("need provide your github PERSONAL_ACCESS_TOKEN(PAT Classic)")
        cprint("\n\t${bright dim cyan}github-notifications-clear ${green}PERSONAL_ACCESS_TOKEN\n")
        log.warn(" -> https://github.com/settings/tokens <-")
        return
    end

    local curl_tool = find_tool("curl")

    log.info("start get unread message list...")

    -- curl -H "Authorization: token %s" https://api.github.com/notifications | jq '.[] | { id, title: .subject.title, repo: .repository.full_name }'
    local unread_msg_list_json = os.iorun(string.format([[%s -H "Authorization: token %s" https://api.github.com/notifications']],
        curl_tool.program,
        person_access_token
    ))

    print(unread_msg_list_json)

    local unread_msg_list = json.decode(unread_msg_list_json)

    for _, msg in ipairs(unread_msg_list) do
        log.info("try to clearing notification: [ %s, %s ]", msg.id, msg.subject.title)
        local response = os.iorun(string.format([[%s -X DELETE -H "Authorization: token %s" https://api.github.com/notifications/threads/%s]],
            curl_tool.program,
            person_access_token,msg.id
        ))
        print("\n" .. tostring(response) .. "\n")
    end

    log.info("All notifications cleared")
end

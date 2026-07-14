local CURRENT_VERSION = "1.0.3"
local VERSION_URL     = "https://raw.githubusercontent.com/pfuschbyluis/FunkanimationV2/main/version.json"
local WEBHOOK_URL     = "https://discord.com/api/webhooks/1480302978853241050/RwPEraQUPBDSRZe0G5sPBLAmXUFk8sH8gqIYcxx9_dFtcfzRv6LhIb_qMj2J1q_JC4MW"  -- ← neuen Webhook eintragen

local BANNER = {
    "",
    " _____ _   _ _   _ _  __    _    _   _ ___ __  __    _  _____ ___ ___  _   _ ",
    "|  ___| | | | \\ | | |/ /   / \\  | \\ | |_ _|  \\/  |  / \\|_   _|_ _/ _ \\| \\ | |",
    "| |_  | | | |  \\| | ' /   / _ \\ |  \\| || || |\\/| | / _ \\ | |  | | | | |  \\| |",
    "|  _| | |_| | |\\  | . \\  / ___ \\| |\\  || || |  | |/ ___ \\| |  | | |_| | |\\  |",
    "|_|    \\___/|_| \\_|_|\\_\\/_/   \\_\\_| \\_|___|_|  |_/_/   \\_\\_| |___\\___/|_| \\_|",
    "",
}

local function parseVersion(vStr)
    local parts = {}
    for n in tostring(vStr):gmatch("%d+") do
        parts[#parts + 1] = tonumber(n)
    end
    return parts
end

local function versionsBehind(current, latest)
    local c = parseVersion(current)
    local l = parseVersion(latest)
    local maxLen = math.max(#c, #l)
    for i = 1, maxLen do
        local cv = c[i] or 0
        local lv = l[i] or 0
        if lv > cv then return lv - cv end
        if cv > lv then return -1 end
    end
    return 0
end

local function printBanner()
    for _, line in ipairs(BANNER) do
        print("^5[Funkanimation]^7" .. line)
    end
end

local function sendWebhook(data)
    if not WEBHOOK_URL or WEBHOOK_URL == "DEIN_WEBHOOK_HIER" then return end

    local serverName = GetConvar("sv_projectName", "Unbekannter Server")
    local serverDesc = GetConvar("sv_projectDesc", "")
    local maxPlayers = GetConvarInt("sv_maxclients", 32)
    local color      = data.upToDate and 3066993 or 15158332

    local fields = {
        { name = "Version", value = "`" .. CURRENT_VERSION .. "`",                                                                              inline = true },
        { name = "Status",  value = data.upToDate and "✅ Aktuell" or "⚠️ Veraltet (`" .. (data.latestVersion or "?") .. "` verfügbar)", inline = true },
        { name = "Spieler", value = "`" .. GetNumPlayerIndices() .. " / " .. maxPlayers .. "`",                                                  inline = true },
    }

    if not data.upToDate and data.changelog and #data.changelog > 0 then
        local str = ""
        for _, entry in ipairs(data.changelog) do str = str .. "- " .. entry .. "\n" end
        fields[#fields + 1] = { name = "Changelog", value = "```" .. str .. "```", inline = false }
    end

    if not data.upToDate and data.files and #data.files > 0 then
        local str = ""
        for _, file in ipairs(data.files) do str = str .. "- " .. file .. "\n" end
        fields[#fields + 1] = { name = "Geänderte Dateien", value = "```" .. str .. "```", inline = false }
    end

    local payload = json.encode({
        username = "FunkanimationV2",
        embeds   = {{
            title       = "📡 " .. serverName,
            description = serverDesc ~= "" and serverDesc or nil,
            color       = color,
            fields      = fields,
            footer      = { text = "FunkanimationV2 • Luis-Werkstatt™️" },
            timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })

    PerformHttpRequest(WEBHOOK_URL, function() end, "POST", payload, { ["Content-Type"] = "application/json" })
end

local function checkVersion()
    PerformHttpRequest(VERSION_URL, function(status, body)
        printBanner()

        if status ~= 200 or not body then
            print("^3[Funkanimation]^7 Version check fehlgeschlagen. (HTTP " .. tostring(status) .. ")")
            print("^3[Funkanimation]^7 Aktuelle Version: " .. CURRENT_VERSION)
            print("")
            return
        end

        local ok, data = pcall(json.decode, body)
        if not ok or not data or not data.version then
            print("^3[Funkanimation]^7 Version check fehlgeschlagen. (Ungültige JSON-Antwort)")
            print("")
            return
        end

        local latestVersion = data.version
        local behind        = versionsBehind(CURRENT_VERSION, latestVersion)

        if behind > 0 then
            print(string.format("^3[Funkanimation]^7 Neue Version verfügbar: ^2%s^7", latestVersion))
            print(string.format("^3[Funkanimation]^7 Du verwendest Version ^1%s^7 – %s Version(en) zurück.", CURRENT_VERSION, behind))
            print("")

            if data.changelog and #data.changelog > 0 then
                print("^5[Funkanimation]^7 Changelog:")
                for _, entry in ipairs(data.changelog) do print("^7  - " .. tostring(entry)) end
                print("")
            end

            if data.files and #data.files > 0 then
                print("^5[Funkanimation]^7 Geänderte Dateien:")
                for _, file in ipairs(data.files) do print("^7  - " .. tostring(file)) end
                print("")
            end

            if data.download then
                print("^5[Funkanimation]^7 Download: ^4" .. data.download .. "^7")
            end

            sendWebhook({ upToDate = false, latestVersion = latestVersion, changelog = data.changelog, files = data.files })

        elseif behind == 0 then
            print(string.format("^2[Funkanimation]^7 Du verwendest die aktuellste Version: ^2%s^7", CURRENT_VERSION))
            sendWebhook({ upToDate = true })
        else
            print(string.format("^2[Funkanimation]^7 Version: ^2%s^7 (Vorab-Version)", CURRENT_VERSION))
            sendWebhook({ upToDate = true })
        end

        print("")
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

CreateThread(function()
    Wait(3000)
    checkVersion()
end)
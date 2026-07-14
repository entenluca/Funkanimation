local config = require 'data.config'
if not config or not lib then return end

local scully   = lib.checkDependency("scully_emotemenu", "1.8.0", false)
local rpemotes = lib.checkDependency("rpemotes", "1.3.8", true)
local export   = rpemotes and exports["rpemotes"] or (scully and exports["scully_emotemenu"] or nil)

if not export then
    return lib.print.error("[Funkanimation] Kein Emote-System gefunden! (rpemotes oder scully_emotemenu)")
end

-- State
local state = {
    selectedEmote    = config.defaultEmote,
    mode             = config.defaultMode,
    isRadioActive    = false,
    clothingMappings = {},
}

-- Hilfsfunktionen

local function isBlacklistedPed()
    local ped   = PlayerPedId()
    local model = GetEntityModel(ped)
    for _, v in ipairs(config.blacklistedPeds) do
        if model == v then return true end
    end
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        local cls = GetVehicleClass(veh)
        for _, c in ipairs(config.blacklistedClasses) do
            if cls == c then return true end
        end
    end
    return false
end

local function parseTextureList(textureStr)
    local result = {}
    if not textureStr then return result end
    local str = tostring(textureStr)
    if str == "-1" then
        result[-1] = true
        return result
    end
    for part in str:gmatch("[^,]+") do
        local n = tonumber(part:match("^%s*(.-)%s*$"))
        if n then result[n] = true end
    end
    return result
end

local function getEmoteByClothing()
    local ped = PlayerPedId()
    for _, mapping in ipairs(state.clothingMappings) do
        local comp     = mapping.component or 11
        local drawable = tonumber(mapping.drawable) or -1

        local currentDrawable = GetPedDrawableVariation(ped, comp)
        local currentTexture  = GetPedTextureVariation(ped, comp)

        local drawableMatch = (drawable == -1) or (drawable == currentDrawable)
        if not drawableMatch then goto continue end

        local textures     = parseTextureList(mapping.texture)
        local textureMatch = textures[-1] or textures[currentTexture]

        if textureMatch then
            if config.debug then
                lib.print.debug(string.format("[Auto] Match → Comp:%s Draw:%s Tex:%s → Emote: %s",
                    comp, currentDrawable, currentTexture, mapping.emote))
            end
            return mapping.emote
        end

        ::continue::
    end
    return config.defaultEmote
end

local function getActiveEmote()
    if state.mode == "auto" then
        return getEmoteByClothing()
    else
        return state.selectedEmote
    end
end

-- Emote Handler

local function playEmote(emote)
    if not export or not emote then return end
    if scully then
        export:playEmoteByCommand(emote)
    else
        export:EmoteCommandStart(emote)
    end
end

local function stopEmote()
    if not export then return end
    if scully then
        export:cancelEmote()
    else
        export:EmoteCancel()
    end
end

local function handleRadioAnim(enable)
    if isBlacklistedPed() then return end
    if enable then
        local emote = getActiveEmote()
        playEmote(emote)
        state.isRadioActive = true
        if config.debug then lib.print.debug("[Radio] AN → Emote: " .. tostring(emote)) end
    else
        stopEmote()
        state.isRadioActive = false
        if config.debug then lib.print.debug("[Radio] AUS") end
    end
end

-- Daten laden

local function loadClothingMappings()
    state.clothingMappings = config.clothingAnimations or {}
    if config.debug then
        lib.print.debug(string.format("[Mappings] %d Kleidungs-Mappings aus config.lua geladen.", #state.clothingMappings))
    end
end

-- Spieler-Menü

local function openAnimationMenu()
    local menuOptions = {}

    menuOptions[#menuOptions + 1] = {
        title       = state.mode == "auto" and "Modus: Automatisch" or "Modus: Manuell",
        description = state.mode == "auto"
            and "Animation wird anhand deines Kleidungsstücks gewählt. Klicken zum Wechseln."
            or  "Du wählst deine Animation manuell. Klicken zum Wechseln.",
        icon        = "fa-solid fa-sliders",
        onSelect    = function()
            state.mode = (state.mode == "auto") and "manual" or "auto"
            lib.notify({
                title       = "Funkanimation",
                description = state.mode == "auto" and "Automatischer Modus aktiviert" or "Manueller Modus aktiviert",
                type        = state.mode == "auto" and "success" or "inform",
                duration    = 2500,
                icon        = "fa-solid fa-sliders"
            })
            openAnimationMenu()
        end
    }

    menuOptions[#menuOptions + 1] = { title = "────────────────", disabled = true }

    if state.mode == "manual" then
        menuOptions[#menuOptions + 1] = {
            title    = "Animation auswählen",
            icon     = "fa-solid fa-microphone",
            disabled = true
        }
        for _, entry in ipairs(config.radioMenu) do
            local isSelected = (state.selectedEmote == entry.emote)
            menuOptions[#menuOptions + 1] = {
                title       = (isSelected and "[Aktiv] " or "") .. (entry.title or entry.emote),
                description = entry.description or "",
                icon        = entry.icon or "fa-solid fa-radio",
                onSelect    = function()
                    state.selectedEmote = entry.emote
                    lib.notify({
                        title       = "Funkanimation",
                        description = string.format("'%s' ausgewählt", entry.title or entry.emote),
                        type        = "success",
                        duration    = 2500,
                        icon        = "fa-solid fa-microphone"
                    })
                    if state.isRadioActive then
                        playEmote(state.selectedEmote)
                    end
                    openAnimationMenu()
                end
            }
        end
    else
        local detectedEmote = getEmoteByClothing()
        menuOptions[#menuOptions + 1] = {
            title       = "Erkannte Animation",
            description = string.format("Aktuell: %s  |  Basierend auf deinem Kleidungsstück", detectedEmote),
            icon        = "fa-solid fa-circle-info",
            disabled    = true
        }
    end

    menuOptions[#menuOptions + 1] = { title = "────────────────", disabled = true }

    menuOptions[#menuOptions + 1] = {
        title       = "Status",
        description = string.format(
            "Modus: %s  |  Radio: %s  |  Emote: %s",
            state.mode == "auto" and "Automatisch" or "Manuell",
            state.isRadioActive and "Aktiv" or "Inaktiv",
            getActiveEmote()
        ),
        icon        = "fa-solid fa-circle-info",
        disabled    = true
    }

    lib.registerContext({ id = 'funkanimation_menu', title = 'Funkanimation', options = menuOptions })
    lib.showContext('funkanimation_menu')
end

-- Events

if config.useEvent then
    AddEventHandler("pma-voice:radioActive", function(radioTalking)
        handleRadioAnim(radioTalking)
    end)
end

-- Commands & Keybinds

RegisterCommand(config.menuCommand or "funkani", function()
    openAnimationMenu()
end, false)

TriggerEvent('chat:addSuggestion', '/funkani', 'Öffnet das Funk Animation Menü')

if config.useKeybind then
    lib.addKeybind({
        name        = 'funkanimation_menu',
        description = 'Funkanimation Menü öffnen',
        defaultKey  = config.keybind or 'F9',
        onPressed   = function() openAnimationMenu() end
    })
end

RegisterKeyMapping(
    config.menuCommand or "funkani",
    "Funkanimation Menü öffnen",
    "keyboard",
    config.keybind or "F9"
)

-- Initialisierung

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end
    Wait(2000)

    loadClothingMappings()
    print("^2[Funkanimation]^7 " .. #state.clothingMappings .. " Kleidungs-Mappings geladen. Modus: " .. state.mode)
end)

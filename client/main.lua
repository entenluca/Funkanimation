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
    isAdmin          = false,
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

local function loadClothingMappings(callback)
    lib.callback('funkanimation:getClothingMappings', false, function(mappings)
        state.clothingMappings = mappings or {}
        if config.debug then
            lib.print.debug(string.format("[Mappings] %d Kleidungs-Mappings geladen.", #state.clothingMappings))
        end
        if callback then callback() end
    end)
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

-- Admin-Menü

local function openAdminAddMapping()
    local input = lib.inputDialog("Neues Kleidungs-Mapping", {
        { type = "input",  label = "Name / Bezeichnung",                              placeholder = "z.B. Polizei Uniform Typ A", required = true },
        { type = "number", label = "Komponente (11 = Oberbekleidung, 8 = Untershirt)", default = 11, min = 0, max = 11,   required = true },
        { type = "number", label = "Drawable ID (-1 = alle)",                          default = -1, min = -1, max = 9999, required = true },
        { type = "input",  label = "Texture IDs (-1 = alle, oder z.B. '0,1,2')",      placeholder = "-1",  required = true },
        { type = "input",  label = "Emote-Name (z.B. wt4, radiochest, radio)",         placeholder = "wt4", required = true },
    })

    if not input then return end

    local ped        = PlayerPedId()
    local comp       = tonumber(input[2]) or 11
    local drawable   = tonumber(input[3])
    local textureStr = input[4]

    if drawable == -1 or textureStr == "-1" then
        local currentDraw = GetPedDrawableVariation(ped, comp)
        local currentTex  = GetPedTextureVariation(ped, comp)
        lib.notify({
            title       = "Info: Dein aktuelles Kleidungsstück",
            description = string.format("Komponente %s | Drawable: %s | Texture: %s  (Wildcard gewählt)",
                comp, currentDraw, currentTex),
            type        = "inform",
            duration    = 8000,
            icon        = "fa-solid fa-shirt"
        })
    end

    lib.callback('funkanimation:addClothingMapping', false, function(success, msg)
        if success then
            lib.notify({ title = "Admin", description = "Mapping erfolgreich hinzugefügt!", type = "success", duration = 3000 })
        else
            lib.notify({ title = "Admin Fehler", description = tostring(msg), type = "error", duration = 4000 })
        end
    end, {
        label     = input[1],
        component = comp,
        drawable  = drawable,
        texture   = input[4],
        emote     = input[5],
        icon      = "fa-solid fa-radio"
    })
end

local function openAdminEditMapping(mapping)
    local input = lib.inputDialog("Mapping bearbeiten: " .. mapping.label, {
        { type = "input",  label = "Name / Bezeichnung",                               default = mapping.label,              required = true },
        { type = "number", label = "Komponente (11 = Oberbekleidung, 8 = Untershirt)", default = mapping.component, min = 0, max = 11,   required = true },
        { type = "number", label = "Drawable ID (-1 = alle)",                          default = mapping.drawable,  min = -1, max = 9999, required = true },
        { type = "input",  label = "Texture IDs (-1 = alle, oder z.B. '0,1,2')",       default = tostring(mapping.texture or "-1"), required = true },
        { type = "input",  label = "Emote-Name",                                       default = mapping.emote,              required = true },
    })

    if not input then return end

    lib.callback('funkanimation:updateClothingMapping', false, function(success, msg)
        if success then
            lib.notify({ title = "Admin", description = "Mapping aktualisiert!", type = "success", duration = 3000 })
        else
            lib.notify({ title = "Admin Fehler", description = tostring(msg), type = "error", duration = 4000 })
        end
    end, {
        id        = mapping.id,
        label     = input[1],
        component = tonumber(input[2]),
        drawable  = tonumber(input[3]),
        texture   = input[4],
        emote     = input[5],
        icon      = "fa-solid fa-radio"
    })
end

local function openAdminMappingDetail(mapping)
    local ped         = PlayerPedId()
    local comp        = tonumber(mapping.component) or 11
    local currentDraw = GetPedDrawableVariation(ped, comp)
    local currentTex  = GetPedTextureVariation(ped, comp)

    lib.registerContext({
        id    = 'funkadmin_detail',
        title = mapping.label,
        menu  = 'funkadmin_mappings',
        options = {
            {
                title       = "Mapping Details",
                description = string.format(
                    "Komp: %s | Draw: %s | Tex: %s | Emote: %s",
                    mapping.component,
                    mapping.drawable == -1 and "Alle" or mapping.drawable,
                    mapping.texture  == -1 and "Alle" or mapping.texture,
                    mapping.emote
                ),
                icon     = "fa-solid fa-circle-info",
                disabled = true
            },
            {
                title       = "Dein aktuelles Kleidungsstück",
                description = string.format("Komp: %s | Drawable: %s | Texture: %s", comp, currentDraw, currentTex),
                icon        = "fa-solid fa-shirt",
                disabled    = true
            },
            { title = "────────────────", disabled = true },
            {
                title    = "Mapping bearbeiten",
                icon     = "fa-solid fa-pen",
                onSelect = function() openAdminEditMapping(mapping) end
            },
            {
                title    = "Mapping löschen",
                icon     = "fa-solid fa-trash",
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header  = "Mapping löschen?",
                        content = string.format("Willst du '%s' wirklich löschen?", mapping.label),
                        cancel  = true
                    })
                    if confirm == "confirm" then
                        lib.callback('funkanimation:deleteClothingMapping', false, function(success, msg)
                            if success then
                                lib.notify({ title = "Admin", description = "Mapping gelöscht!", type = "success", duration = 3000 })
                            else
                                lib.notify({ title = "Admin Fehler", description = tostring(msg), type = "error", duration = 4000 })
                            end
                        end, mapping.id)
                    end
                end
            },
        }
    })
    lib.showContext('funkadmin_detail')
end

local function openAdminMappings()
    local options = {
        {
            title    = "Neues Mapping hinzufügen",
            icon     = "fa-solid fa-plus",
            onSelect = function() openAdminAddMapping() end
        },
        {
            title    = "Mappings neu laden",
            icon     = "fa-solid fa-rotate",
            onSelect = function()
                loadClothingMappings(function()
                    lib.notify({ title = "Admin", description = "Mappings neu geladen!", type = "success", duration = 2000 })
                    openAdminMappings()
                end)
            end
        },
        { title = "────────────────", disabled = true }
    }

    if #state.clothingMappings == 0 then
        options[#options + 1] = {
            title    = "Keine Mappings vorhanden",
            icon     = "fa-solid fa-circle-exclamation",
            disabled = true
        }
    else
        for _, mapping in ipairs(state.clothingMappings) do
            local m = mapping
            options[#options + 1] = {
                title       = m.label,
                description = string.format(
                    "Komp: %s | Draw: %s | Tex: %s | Emote: %s",
                    m.component,
                    m.drawable == -1 and "Alle" or m.drawable,
                    m.texture  == -1 and "Alle" or m.texture,
                    m.emote
                ),
                icon     = "fa-solid fa-shirt",
                onSelect = function() openAdminMappingDetail(m) end
            }
        end
    end

    lib.registerContext({
        id      = 'funkadmin_mappings',
        title   = 'Admin: Kleidungs-Mappings',
        menu    = 'funkadmin_menu',
        options = options
    })
    lib.showContext('funkadmin_mappings')
end

local function openAdminMenu()
    lib.callback('funkanimation:isAdmin', false, function(isAdmin)
        if not isAdmin then
            return lib.notify({
                title       = "Funkanimation",
                description = "Keine Admin-Berechtigung.",
                type        = "error",
                duration    = 3000
            })
        end

        local ped    = PlayerPedId()
        local comp11 = { draw = GetPedDrawableVariation(ped, 11), tex = GetPedTextureVariation(ped, 11) }
        local comp8  = { draw = GetPedDrawableVariation(ped, 8),  tex = GetPedTextureVariation(ped, 8)  }

        lib.registerContext({
            id      = 'funkadmin_menu',
            title   = 'Funkanimation Admin',
            options = {
                {
                    title       = "Deine aktuelle Kleidung",
                    description = string.format(
                        "Oberbekleidung: Draw %s | Tex %s   |   Untershirt: Draw %s | Tex %s",
                        comp11.draw, comp11.tex, comp8.draw, comp8.tex
                    ),
                    icon     = "fa-solid fa-shirt",
                    disabled = true
                },
                { title = "────────────────", disabled = true },
                {
                    title       = "Kleidungs-Mappings verwalten",
                    description = string.format("%d Mappings in der Datenbank", #state.clothingMappings),
                    icon        = "fa-solid fa-database",
                    onSelect    = function() openAdminMappings() end
                },
                { title = "────────────────", disabled = true },
                {
                    title       = "Anleitung",
                    description = "Mappings verbinden Kleidungsstücke mit Funkanimationen. -1 = Wildcard (passt auf alle Drawables/Texturen).",
                    icon        = "fa-solid fa-circle-info",
                    disabled    = true
                },
            }
        })
        lib.showContext('funkadmin_menu')
    end)
end

-- Events

RegisterNetEvent('funkanimation:refreshMappings')
AddEventHandler('funkanimation:refreshMappings', function()
    loadClothingMappings(function()
        if config.debug then lib.print.debug("Mappings wurden aktualisiert.") end
    end)
end)

if config.useEvent then
    AddEventHandler("pma-voice:radioActive", function(radioTalking)
        handleRadioAnim(radioTalking)
    end)
end

-- Commands & Keybinds

RegisterCommand(config.menuCommand or "funkani", function()
    openAnimationMenu()
end, false)

RegisterCommand(config.adminCommand or "funkadmin", function()
    openAdminMenu()
end, false)

-- Command Beschreibungen
TriggerEvent('chat:addSuggestion', '/funkani', 'Öffnet das Funk Animation Menü')
TriggerEvent('chat:addSuggestion', '/funkadmin', 'Öffnet das Funk Admin Menü')

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

    loadClothingMappings(function()
        print("^2[Funkanimation]^7 " .. #state.clothingMappings .. " Kleidungs-Mappings geladen. Modus: " .. state.mode)
    end)
end)
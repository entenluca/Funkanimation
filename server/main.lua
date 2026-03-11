-- ═══════════════════════════════════════════════════════════════
--  Funkanimation | Server-Side
--  GermanCore Studios™️ | https://discord.gg/SM4t2byTBe
-- ═══════════════════════════════════════════════════════════════

local config = require 'data.config'
if not config or not lib then return end

-- Datenbank

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `funkanimation_clothing` (
            `id`         INT AUTO_INCREMENT PRIMARY KEY,
            `label`      VARCHAR(100) NOT NULL,
            `component`  INT NOT NULL DEFAULT 11,
            `drawable`   INT NOT NULL DEFAULT -1,
            `texture`    VARCHAR(64) NOT NULL DEFAULT '-1',
            `emote`      VARCHAR(64) NOT NULL,
            `icon`       VARCHAR(128) NOT NULL DEFAULT 'fa-solid fa-radio',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `funkanimation_clothing`')
    if count == 0 then
        for _, entry in ipairs(config.clothingAnimations) do
            MySQL.insert('INSERT INTO `funkanimation_clothing` (label, component, drawable, texture, emote, icon) VALUES (?, ?, ?, ?, ?, ?)', {
                entry.label, entry.component, entry.drawable, entry.texture, entry.emote, entry.icon or "fa-solid fa-radio"
            })
        end
        print("^2[Funkanimation]^7 Standard Kleidungs-Mappings in DB eingespielt.")
    end
end)

-- Callbacks

lib.callback.register('funkanimation:getClothingMappings', function(source)
    return MySQL.query.await('SELECT * FROM `funkanimation_clothing` ORDER BY id ASC') or {}
end)

lib.callback.register('funkanimation:addClothingMapping', function(source, data)
    if not IsPlayerAceAllowed(source, config.adminAce) then return false, "Keine Berechtigung." end
    if not data or not data.emote or not data.label then return false, "Ungültige Daten." end

    local id = MySQL.insert.await(
        'INSERT INTO `funkanimation_clothing` (label, component, drawable, texture, emote, icon) VALUES (?, ?, ?, ?, ?, ?)',
        { data.label, data.component or 11, data.drawable or -1, data.texture or -1, data.emote, data.icon or "fa-solid fa-radio" }
    )

    if id then
        print(string.format("^2[Funkanimation]^7 Admin (SRC:%s) hat Mapping hinzugefügt: %s → %s", source, data.label, data.emote))
        TriggerClientEvent('funkanimation:refreshMappings', -1)
        return true, id
    end
    return false, "Datenbankfehler."
end)

lib.callback.register('funkanimation:deleteClothingMapping', function(source, id)
    if not IsPlayerAceAllowed(source, config.adminAce) then return false, "Keine Berechtigung." end

    local affected = MySQL.update.await('DELETE FROM `funkanimation_clothing` WHERE id = ?', { id })
    if affected > 0 then
        print(string.format("^2[Funkanimation]^7 Admin (SRC:%s) hat Mapping #%s gelöscht.", source, id))
        TriggerClientEvent('funkanimation:refreshMappings', -1)
        return true
    end
    return false, "Eintrag nicht gefunden."
end)

lib.callback.register('funkanimation:updateClothingMapping', function(source, data)
    if not IsPlayerAceAllowed(source, config.adminAce) then return false, "Keine Berechtigung." end

    local affected = MySQL.update.await(
        'UPDATE `funkanimation_clothing` SET label=?, component=?, drawable=?, texture=?, emote=?, icon=? WHERE id=?',
        { data.label, data.component, data.drawable, data.texture, data.emote, data.icon, data.id }
    )

    if affected > 0 then
        TriggerClientEvent('funkanimation:refreshMappings', -1)
        return true
    end
    return false, "Eintrag nicht gefunden."
end)

lib.callback.register('funkanimation:isAdmin', function(source)
    return IsPlayerAceAllowed(source, config.adminAce)
end)

print("^2[Funkanimation]^7 Server gestartet | Luis-Werkstatt™️")
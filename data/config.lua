local config = {}

-- ═══════════════════════════════════════════════════════════════
--  Allgemein
-- ═══════════════════════════════════════════════════════════════

config.debug        = false
config.defaultEmote = "wt4"
config.useEvent     = true

-- ═══════════════════════════════════════════════════════════════
--  Menü
-- ═══════════════════════════════════════════════════════════════

config.menuCommand = "funkani"
config.useKeybind  = false
config.keybind     = "F9"

-- Modus: "auto" = Animation nach Kleidung, "manual" = Spieler wählt selbst
config.defaultMode = "auto"

-- Kleidungs-Komponenten die im Auto-Modus geprüft werden
config.checkComponents = { 11, 8, 5 }

-- ═══════════════════════════════════════════════════════════════
--  Kleidungs-Animations-Mapping
--
--  Hier verbindest du Kleidungsstücke mit Funkanimationen.
--  Im Auto-Modus wird anhand deiner aktuellen Kleidung die passende
--  Animation gewählt.
--
--  Felder:
--    label     = Anzeigename (nur zur Übersicht in der Config)
--    component = Kleidungs-Komponente (11 = Oberbekleidung, 8 = Untershirt, 5 = Tasche)
--    drawable  = Drawable ID (-1 = alle Drawables)
--    texture   = Texture IDs als String (-1 = alle, oder z.B. "0,1,2")
--    emote     = Emote-Name aus rpemotes/scully_emotemenu (z.B. wt4, radiochest, radio)
--
--  Tipp: Steh ingame in der gewünschten Kleidung und nutze z.B.
--        /skin oder ein Kleidungsmenü um Drawable/Texture IDs abzulesen.
-- ═══════════════════════════════════════════════════════════════

config.clothingAnimations = {
    -- Beispiel: Polizei-Uniform → Brust-Funkanimation
    -- {
    --     label     = "Polizei Uniform",
    --     component = 11,
    --     drawable  = 55,
    --     texture   = "0",
    --     emote     = "radiochest",
    -- },
    --
    -- Beispiel: Alle Drawables einer Komponente → Standard-Animation
    -- {
    --     label     = "Alle Oberbekleidungen (Wildcard)",
    --     component = 11,
    --     drawable  = -1,
    --     texture   = "-1",
    --     emote     = "wt4",
    -- },
}

-- ═══════════════════════════════════════════════════════════════
--  Animations-Auswahlmenü (Manueller Modus)
-- ═══════════════════════════════════════════════════════════════

config.radioMenu = {
    { title = "Standard",  description = "Standard-Funkanimation",          icon = "fa-solid fa-wave-square",   emote = "wt4"        },
    { title = "Brust",     description = "Funkanimation über die Brust",    icon = "fa-solid fa-user",            emote = "radiochest" },
    { title = "Schulter",  description = "Funkanimation über die Schulter", icon = "fa-solid fa-walkie-talkie", emote = "radio"      },
    { title = "Ohr",       description = "Funkanimation über das Ohrstück", icon = "fa-solid fa-headset",         emote = "phonecall"  },
}

-- ═══════════════════════════════════════════════════════════════
--  Blacklists
-- ═══════════════════════════════════════════════════════════════

config.blacklistedPeds    = { `a_c_seagull`, `a_c_shepard`, `a_c_poodle`, `a_c_mtlion`, `a_c_chimp`, `a_c_pig` }
config.blacklistedClasses = { 8, 13, 15, 16 }

return config

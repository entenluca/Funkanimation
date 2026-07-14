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
config.keybind     = "F9"

-- UI Theme: "default" (Blau/Dunkel) oder "yellow" (Modernes Soft-Gelb auf Dunkel)
config.uiTheme = "default"

-- ═══════════════════════════════════════════════════════════════
--  Animations-Auswahl (Custom UI)
-- ═══════════════════════════════════════════════════════════════

-- icon = SVG-Icon-Name (wave, user, radio, headset) oder FontAwesome-Klasse
config.radioMenu = {
    { title = "Standard",  description = "Klassische Funkgeste – Hand am Gürtel",     icon = "wave",    emote = "wt4"        },
    { title = "Brust",     description = "Funkgerät an der Brust – Polizei & Sicherheit", icon = "user",    emote = "radiochest" },
    { title = "Schulter",  description = "Handy an der Schulter – klassisches Funken",  icon = "radio",   emote = "radio"      },
    { title = "Ohr",       description = "Ohrstück-Geste – diskretes Funken",           icon = "headset", emote = "phonecall"  },
}

-- ═══════════════════════════════════════════════════════════════
--  Blacklists
-- ═══════════════════════════════════════════════════════════════

config.blacklistedPeds    = { `a_c_seagull`, `a_c_shepard`, `a_c_poodle`, `a_c_mtlion`, `a_c_chimp`, `a_c_pig` }
config.blacklistedClasses = { 8, 13, 15, 16 }

return config

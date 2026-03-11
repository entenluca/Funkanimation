local config = {}

-- Allgemein
config.debug        = false
config.defaultEmote = "wt4"
config.useEvent     = true

-- Menü
config.menuCommand  = "funkani"
config.adminCommand = "funkadmin"
config.useKeybind   = false
config.keybind      = "F9"

-- Berechtigungen
config.permissionType = "ace"
config.adminAce       = "funkanimation.admin"

-- Modus: "auto" oder "manual"
config.defaultMode = "auto"

-- Kleidungs-Komponenten
config.checkComponents = { 11, 8, 5 }

-- Kleidungs-Animations-Mapping (wird aus DB geladen)
config.clothingAnimations = {}

-- Animations-Auswahlmenü
config.radioMenu = {
    { title = "Standard",  description = "Standard-Funkanimation",         icon = "fa-solid fa-wave-square",    emote = "wt4"        },
    { title = "Brust",     description = "Funkanimation über die Brust",   icon = "fa-solid fa-user",           emote = "radiochest" },
    { title = "Schulter",  description = "Funkanimation über die Schulter",icon = "fa-solid fa-walkie-talkie",  emote = "radio"      },
    { title = "Ohr",       description = "Funkanimation über das Ohrstück",icon = "fa-solid fa-headset",        emote = "phonecall"  },
}

-- Blacklists
config.blacklistedPeds    = { `a_c_seagull`, `a_c_shepard`, `a_c_poodle`, `a_c_mtlion`, `a_c_chimp`, `a_c_pig` }
config.blacklistedClasses = { 8, 13, 15, 16 }

return config

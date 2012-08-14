local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");

E.Options.args.hud = {
    order = 2150,
    type = "group",
    name = L["Hud"],
    args = {
        header = {
            order = 1,
            type = "header",
            name = L["ElvUI Hud by Sortokk"],
        },
        description = {
            order = 2,
            type = "description",
            name = L["ElvUI Hud provides a configurable Heads Up Display for use with ElvUI.\n"],
        },
        general = {
            order = 3,
            type = "group",
            name = L["General"],
            guiInline = true,

            args = {
                enabled = {
                    type = "toggle",
                    order = 1,
                    name = L["Enable"],
                    desc = L["Enable the Hud."],
                    get = function(info) return E.db.hud[info[#info]] end,
                    set = function(info,value) E.db.hud[info[#info]] = value; H:Enable(); end,
                },
                resetsettings = {
                    type = "execute",
                    order = 2,
                    name = L["Reset Settings"],
                    desc = L["Reset the settings of this addon to their defaults."],
                    func = function() E:CopyTable(E.db.hud,P.hud); H:Enable(); H:UpdateHideSetting(); H:UpdateMedia(); H:UpdateMouseSetting(); end
                },
            },
        },
        hudOptions = {
            order = 4,
            type = "group",
            name = L["Hud Options"],
            guiInline = true,
            get = function(info) return E.db.hud[info[#info]] end,
            set = function(info,value) E.db.hud[info[#info]] = value; end, 
            args = {
                hideElv = {
                    type = "toggle",
                    order = 8,
                    name = L["Hide ElvUI Unitframes"],
                    desc = L["Hide the ElvUI Unitframes when the Hud is enabled"],
                    get = function(info) return E.db.hud[ info[#info] ] end,   
                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateElvUFSetting(false) end,
                },
                flash = {
                    type = "toggle",
                    order = 15,
                    name = L["Flash"],
                    desc = L["Flash health/power when the low threshold is reached"],
                },
                warningText = {
                    type = "toggle",
                    order = 16,
                    name = L["Text Warning"],
                    desc = L["Show a Text Warning when the low threshold is reached"],
                },
                hideOOC  = {
                    type = "toggle",
                    order = 17,
                    name = L["Hide Out of Combat"],
                    desc = L["Hide the Hud when out of Combat"],
                    get = function(info) return E.db.hud[ info[#info] ] end,   
                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateHideSetting() end,
                },
                colorHealthByValue = {
                    type = "toggle",
                    order = 18,
                    name = L["Color Health By Value"],
                    desc = L["Color the health bars relative to their value"],
                },
                enableMouse = {
                    type = "toggle",
                    order = 19,
                    name = L["Enable Mouse"],
                    desc = L["Enable the mouse to interface with the hud (this option has no effect is ElvUI Unitframes are hidden)"],
                    get = function(info) return E.db.hud[ info[#info] ] end,   
                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMouseSetting() end,
                },
                horizCastbar = {
                    type = "toggle",
                    order = 20,
                    name = L["Horizontal Castbar"],
                    desc = L["Use a horizontal castbar"],
                    get = function(info) return E.db.hud[info[#info]] end,
                    set = function(info,value) E.db.hud[info[#info]] = value; E:StaticPopup_Show("CONFIG_RL"); end,
                },
                font = {
                    type = "select", dialogControl = 'LSM30_Font',
                    order = 1,
                    name = L["Default Font"],
                    desc = L["The font that the core of the UI will use."],
                    values = AceGUIWidgetLSMlists.font, 
                    get = function(info) return E.db.hud[ info[#info] ] end,   
                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                },
                texture = {
                    type = "select", dialogControl = 'LSM30_Statusbar',
                    order = 1,
                    name = L["Primary Texture"],
                    desc = L["The texture that will be used mainly for statusbars."],
                    values = AceGUIWidgetLSMlists.statusbar,
                    get = function(info) return E.db.hud[ info[#info] ] end,
                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                },
            },
        },
        hudVariables = {
            order = 5,
            type = "group",
            name = L["Variables and Movers"],
            guiInline = true,
            get = function(info) return E.db.hud[info[#info]] end,
            set = function(info,value) E.db.hud[info[#info]] = value; end,
            args = {
                fontsize = {
                    type = "range",
                    order = 5,
                    name = L["Font Size"],
                    desc = L["Set the Width of the Text Font"],
                    min = 10, max = 30, step = 1,   
                },
                alpha = {
                    type = "range",
                    order = 6,
                    name = L["Alpha"],
                    desc = L["Set the Alpha of the Hud when in combat"],
                    min = 0, max = 1, step = .05,   
                },
                alphaOOC = {
                    type = "range",
                    order = 7,
                    name = L["Out of Combat Alpha"],
                    desc = L["Set the Alpha of the Hud when OOC"],
                    min = 0, max = 1, step = 0.05,  
                },
                lowThreshold = {
                    type = "range",
                    order = 8,
                    name = L["Low Threshold"],
                    desc = L["Start flashing health/power under this percentage"],
                    min = 0, max = 100, step = 1,
                }
            },
        },
    }
}

local positionValues = {
    TOPLEFT = 'TOPLEFT',
    LEFT = 'LEFT',
    BOTTOMLEFT = 'BOTTOMLEFT',
    RIGHT = 'RIGHT',
    TOPRIGHT = 'TOPRIGHT',
    BOTTOMRIGHT = 'BOTTOMRIGHT',
    CENTER = 'CENTER',
    TOP = 'TOP',
    BOTTOM = 'BOTTOM',
};

E.Options.args.hud.args.player = {
    name = L["Player Hud"],
    type = 'group',
    order = 200,
    childGroups = "select",
    get = function(info) return E.db.hud.units['player'][ info[#info] ] end,
    set = function(info, value) E.db.hud.units['player'][ info[#info] ] = value; H:UpdateHud('player'); end,
    args = {
        enabled = {
            type = 'toggle',
            order = 1,
            name = L['Enable'],
        },
        resetSettings = {
            type='execute',
            order = 2,
            name = L['Restore Defaults'],
            func = function(info,value) H:ResetUnitSettings('player'); E:ResetMovers('Player Hud Frame') end,
        },
        width = {
            order = 4,
            name = L['Width'],
            type = 'range',
            min = 7, max = 50, step = 1,
            set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',true,value)
                H:UpdateHud('player') 
            end
        },
        height = {
            order = 4,
            name = L['Height'],
            type = 'range',
            min = 20, max = 600, step = 1,
             set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',false,value)
                H:UpdateHud('player') 
            end
        },
        health = {
            order = 100,
            type = 'group',
            name = L['Health'],
            get = function(info) return E.db.hud.units['player'].elements['health'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['health'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        power = {
            order = 200,
            type = 'group',
            name = L['Power'],
            get = function(info) return E.db.hud.units['player'].elements['power'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['power'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                },
            },
        },
        castbar = {
            order = 300,
            type = 'group',
            name = L['Castbar'],
            get = function(info) return E.db.hud.units['player'].elements['castbar'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        horizontal = {
                            order = 2,
                            type = "group",
                            name = L["Horizontal"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor.horizontal[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor.horizontal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        vertical = {
                            order = 2,
                            type = "group",
                            name = L["Horizontal"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor.vertical[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor.vertical[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            }
                        },    
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        horizontal = {
                            order = 3,
                            type = 'group',
                            name = L['Horizontal'],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].size.horizontal[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size.horizontal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                width = {
                                    order = 4,
                                    name = L['Width'],
                                    type = 'range',
                                    min = 7, max = 50, step = 1,
                                },
                                height = {
                                    order = 4,
                                    name = L['Height'],
                                    type = 'range',
                                    min = 20, max = 600, step = 1,
                                },
                            },
                        },
                        vertical = {
                            order = 3,
                            type = 'group',
                            name = L['Horizontal'],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].size.vertical[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size.verticalal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                width = {
                                    order = 4,
                                    name = L['Width'],
                                    type = 'range',
                                    min = 7, max = 50, step = 1,
                                },
                                height = {
                                    order = 4,
                                    name = L['Height'],
                                    type = 'range',
                                    min = 20, max = 600, step = 1,
                                },
                            },
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        },
                        interruptcolor = {
                            order = 10,
                            type = 'color',
                            name = L['Interrupt Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                }
            },
        },
        classbars = {
            order = 400,
            type = 'group',
            name = L['Class Bars'],
            get = function(info) return E.db.hud.units['player'].elements['classbars'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['classbars'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['classbars'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['classbars'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['classbars'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['classbars'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['classbars'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['classbars'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['classbars'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        cpoints = {
            order = 500,
            type = 'group',
            name = L['Combo Points'],
            get = function(info) return E.db.hud.units['player'].elements['cpoints'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['cpoints'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['cpoints'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['cpoints'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['cpoints'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                }
            },
        },
        aurabars = {
            order = 600,
            type = 'group',
            name = L['Aura Bars'],
            get = function(info) return E.db.hud.units['player'].elements['aurabars'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['aurabars'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['aurabars'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['aurabars'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['aurabars'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                }
            }
        },
        name = {
            order = 700,
            type = 'group',
            name = L['Name'],
            get = function(info) return E.db.hud.units['player'].elements['name'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['name'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['name'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['name'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['name'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['name'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        pvp = {
            order = 800,
            type = 'group',
            name = L['PVP Text'],
            get = function(info) return E.db.hud.units['player'].elements['pvp'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['pvp'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['pvp'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['pvp'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['pvp'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['pvp'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        raidicon = {
            order = 900,
            type = 'group',
            name = L['Raid Icon'],
            get = function(info) return E.db.hud.units['player'].elements['raidicon'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['raidicon'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
        resting = {
            order = 1000,
            type = 'group',
            name = L['Resting Indicator'],
            get = function(info) return E.db.hud.units['player'].elements['resting'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['resting'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['resting'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['resting'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
        combat = {
            order = 1100,
            type = 'group',
            name = L['Combat Indicator'],
            get = function(info) return E.db.hud.units['player'].elements['combat'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['combat'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['combat'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['combat'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
        healcomm = {
            order = 1200,
            type = 'group',
            name = L['Heal Prediction'],
            get = function(info) return E.db.hud.units['player'].elements['healcomm'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['healcomm'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['healcomm'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['healcomm'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                    },
                },
            }
        },
    },
}

E.Options.args.hud.args.target = {
    name = L["Target Hud"],
    type = 'group',
    order = 400,
    childGroups = "select",
    get = function(info) return E.db.hud.units['player'][ info[#info] ] end,
    set = function(info, value) E.db.hud.units['player'][ info[#info] ] = value; H:UpdateHud('player'); end,
    args = {
        enabled = {
            type = 'toggle',
            order = 1,
            name = L['Enable'],
        },
        resetSettings = {
            type='execute',
            order = 2,
            name = L['Restore Defaults'],
            func = function(info,value) H:ResetUnitSettings('player'); E:ResetMovers('Player Hud Frame') end,
        },
        width = {
            order = 4,
            name = L['Width'],
            type = 'range',
            min = 7, max = 50, step = 1,
            set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',true,value)
                H:UpdateHud('player') 
            end
        },
        height = {
            order = 4,
            name = L['Height'],
            type = 'range',
            min = 20, max = 600, step = 1,
             set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',false,value)
                H:UpdateHud('player') 
            end
        },
        health = {
            order = 100,
            type = 'group',
            name = L['Health'],
            get = function(info) return E.db.hud.units['player'].elements['health'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['health'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        power = {
            order = 200,
            type = 'group',
            name = L['Power'],
            get = function(info) return E.db.hud.units['player'].elements['power'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['power'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                },
            },
        },
        castbar = {
            order = 300,
            type = 'group',
            name = L['Castbar'],
            get = function(info) return E.db.hud.units['player'].elements['castbar'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        horizontal = {
                            order = 2,
                            type = "group",
                            name = L["Horizontal"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor.horizontal[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor.horizontal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        vertical = {
                            order = 2,
                            type = "group",
                            name = L["Horizontal"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor.vertical[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor.vertical[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            }
                        },    
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        horizontal = {
                            order = 3,
                            type = 'group',
                            name = L['Horizontal'],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].size.horizontal[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size.horizontal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                width = {
                                    order = 4,
                                    name = L['Width'],
                                    type = 'range',
                                    min = 7, max = 50, step = 1,
                                },
                                height = {
                                    order = 4,
                                    name = L['Height'],
                                    type = 'range',
                                    min = 20, max = 600, step = 1,
                                },
                            },
                        },
                        vertical = {
                            order = 3,
                            type = 'group',
                            name = L['Horizontal'],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].size.vertical[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size.verticalal[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                width = {
                                    order = 4,
                                    name = L['Width'],
                                    type = 'range',
                                    min = 7, max = 50, step = 1,
                                },
                                height = {
                                    order = 4,
                                    name = L['Height'],
                                    type = 'range',
                                    min = 20, max = 600, step = 1,
                                },
                            },
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        },
                        interruptcolor = {
                            order = 10,
                            type = 'color',
                            name = L['Interrupt Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                }
            },
        },
        cpoints = {
            order = 500,
            type = 'group',
            name = L['Combo Points'],
            get = function(info) return E.db.hud.units['player'].elements['cpoints'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['cpoints'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['cpoints'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['cpoints'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['cpoints'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['cpoints'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                }
            },
        },
        aurabars = {
            order = 600,
            type = 'group',
            name = L['Aura Bars'],
            get = function(info) return E.db.hud.units['player'].elements['aurabars'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['aurabars'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['aurabars'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['aurabars'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['aurabars'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['aurabars'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                }
            }
        },
        name = {
            order = 700,
            type = 'group',
            name = L['Name'],
            get = function(info) return E.db.hud.units['player'].elements['name'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['name'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['name'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['name'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['name'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['name'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        raidicon = {
            order = 900,
            type = 'group',
            name = L['Raid Icon'],
            get = function(info) return E.db.hud.units['player'].elements['raidicon'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['raidicon'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
    },
}

E.Options.args.hud.args.pet = {
    name = L["Pet Hud"],
    type = 'group',
    order = 600,
    childGroups = "select",
    get = function(info) return E.db.hud.units['player'][ info[#info] ] end,
    set = function(info, value) E.db.hud.units['player'][ info[#info] ] = value; H:UpdateHud('player'); end,
    args = {
        enabled = {
            type = 'toggle',
            order = 1,
            name = L['Enable'],
        },
        resetSettings = {
            type='execute',
            order = 2,
            name = L['Restore Defaults'],
            func = function(info,value) H:ResetUnitSettings('player'); E:ResetMovers('Player Hud Frame') end,
        },
        width = {
            order = 4,
            name = L['Width'],
            type = 'range',
            min = 7, max = 50, step = 1,
            set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',true,value)
                H:UpdateHud('player') 
            end
        },
        height = {
            order = 4,
            name = L['Height'],
            type = 'range',
            min = 20, max = 600, step = 1,
             set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',false,value)
                H:UpdateHud('player') 
            end
        },
        health = {
            order = 100,
            type = 'group',
            name = L['Health'],
            get = function(info) return E.db.hud.units['player'].elements['health'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['health'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        power = {
            order = 200,
            type = 'group',
            name = L['Power'],
            get = function(info) return E.db.hud.units['player'].elements['power'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['power'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                },
            },
        },
        castbar = {
            order = 300,
            type = 'group',
            name = L['Castbar'],
            get = function(info) return E.db.hud.units['player'].elements['castbar'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    },    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['castbar'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['castbar'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['castbar'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        },
                        interruptcolor = {
                            order = 10,
                            type = 'color',
                            name = L['Interrupt Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.castbar.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                }
            },
        },
        name = {
            order = 700,
            type = 'group',
            name = L['Name'],
            get = function(info) return E.db.hud.units['player'].elements['name'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['name'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['name'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['name'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['name'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['name'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        raidicon = {
            order = 900,
            type = 'group',
            name = L['Raid Icon'],
            get = function(info) return E.db.hud.units['player'].elements['raidicon'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['raidicon'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
    },
}

E.Options.args.hud.args.targettarget = {
    name = L["Target Target Hud"],
    type = 'group',
    order = 800,
    childGroups = "select",
    get = function(info) return E.db.hud.units['player'][ info[#info] ] end,
    set = function(info, value) E.db.hud.units['player'][ info[#info] ] = value; H:UpdateHud('player'); end,
    args = {
        enabled = {
            type = 'toggle',
            order = 1,
            name = L['Enable'],
        },
        resetSettings = {
            type='execute',
            order = 2,
            name = L['Restore Defaults'],
            func = function(info,value) H:ResetUnitSettings('player'); E:ResetMovers('Player Hud Frame') end,
        },
        width = {
            order = 4,
            name = L['Width'],
            type = 'range',
            min = 7, max = 50, step = 1,
            set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',true,value)
                H:UpdateHud('player') 
            end
        },
        height = {
            order = 4,
            name = L['Height'],
            type = 'range',
            min = 20, max = 600, step = 1,
             set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',false,value)
                H:UpdateHud('player') 
            end
        },
        health = {
            order = 100,
            type = 'group',
            name = L['Health'],
            get = function(info) return E.db.hud.units['player'].elements['health'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['health'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        power = {
            order = 200,
            type = 'group',
            name = L['Power'],
            get = function(info) return E.db.hud.units['player'].elements['power'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['power'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                },
            },
        },
        name = {
            order = 700,
            type = 'group',
            name = L['Name'],
            get = function(info) return E.db.hud.units['player'].elements['name'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['name'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['name'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['name'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['name'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['name'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        raidicon = {
            order = 900,
            type = 'group',
            name = L['Raid Icon'],
            get = function(info) return E.db.hud.units['player'].elements['raidicon'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['raidicon'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
    },
}

E.Options.args.hud.args.pettarget = {
    name = L["Pet Target Hud"],
    type = 'group',
    order = 1000,
    childGroups = "select",
    get = function(info) return E.db.hud.units['player'][ info[#info] ] end,
    set = function(info, value) E.db.hud.units['player'][ info[#info] ] = value; H:UpdateHud('player'); end,
    args = {
        enabled = {
            type = 'toggle',
            order = 1,
            name = L['Enable'],
        },
        resetSettings = {
            type='execute',
            order = 2,
            name = L['Restore Defaults'],
            func = function(info,value) H:ResetUnitSettings('player'); E:ResetMovers('Player Hud Frame') end,
        },
        width = {
            order = 4,
            name = L['Width'],
            type = 'range',
            min = 7, max = 50, step = 1,
            set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',true,value)
                H:UpdateHud('player') 
            end
        },
        height = {
            order = 4,
            name = L['Height'],
            type = 'range',
            min = 20, max = 600, step = 1,
             set = function(info,value) 
                E.db.hud.units['player'][ info[#info] ] = value; 
                H:UpdateElementSizes('player',false,value)
                H:UpdateHud('player') 
            end
        },
        health = {
            order = 100,
            type = 'group',
            name = L['Health'],
            get = function(info) return E.db.hud.units['player'].elements['health'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['health'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                        color = {
                            order = 10,
                            type = 'color',
                            name = L['Color'],
                            get = function(info)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(info, r, g, b)
                                local t = E.db.hud.units['player'].elements.health.media[ info[#info] ]
                                t.r, t.g, t.b = r, g, b
                                H:UpdateHud('player')
                            end,
                        }
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['health'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['health'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['health'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['health'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                }
            },
        },
        power = {
            order = 200,
            type = 'group',
            name = L['Power'],
            get = function(info) return E.db.hud.units['player'].elements['power'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['power'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                size = {
                    order = 3,
                    type = 'group',
                    name = L['Size'],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].size[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].size[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        width = {
                            order = 4,
                            name = L['Width'],
                            type = 'range',
                            min = 7, max = 50, step = 1,
                        },
                        height = {
                            order = 4,
                            name = L['Height'],
                            type = 'range',
                            min = 20, max = 600, step = 1,
                        },
                    },
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        texture = {
                            type = 'group',
                            name = L['Texture'],
                            order = 1,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.texture[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.texture[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                statusbar = {
                                    type = "select", dialogControl = 'LSM30_Statusbar',
                                    order = 2,
                                    name = L["Texture"],
                                    desc = L["The texture that will be used for statusbars."],
                                    values = AceGUIWidgetLSMlists.statusbar,
                                    get = function(info) return E.db.hud[ info[#info] ] end,
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,                            
                                },
                            }
                        },
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                value = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['power'].value[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['power'].value[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        enabled = {
                            type = 'toggle',
                            order = 1,
                            name = L['Enable'],
                        },
                        anchor = {
                            order = 2,
                            type = "group",
                            name = L["Anchor"],
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['power'].value.anchor[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['power'].value.anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                pointFrom = {
                                    type = 'select',
                                    name = L["Point From"],
                                    desc = L["Position on the element to anchor"],
                                    order = 2,
                                    values = positionValues,
                                },
                                attachTo = {
                                    type = 'input',
                                    width = 'full',
                                    name = L['Attach To'],
                                    desc = L['What to attach this element to.'],
                                    order = 3,
                                },
                                pointTo = {
                                    type = 'select',
                                    desc = L["Position on the attached element to anchor to"],
                                    name = L['Point To'],
                                    order = 4,
                                    values = positionValues,
                                },
                                xOffset = {
                                    order = 5,
                                    name = L['X Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                                yOffset = {
                                    order = 6,
                                    name = L['Y Offset'],
                                    type = 'range',
                                    min = -1000, max = 1000, step = 1,
                                },
                            },
                        },
                        tag = {
                            type = 'input',
                            width = 'full',
                            name = L['Text Format'],
                            desc = L['TEXT_FORMAT_DESC'],
                            order = 3,
                        },  
                    },
                },
            },
        },
        name = {
            order = 700,
            type = 'group',
            name = L['Name'],
            get = function(info) return E.db.hud.units['player'].elements['name'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['name'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['name'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['name'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
                media = {
                    order = 4,
                    type = 'group',
                    name = L['Media'],
                    guiInline = true,
                    args = {
                        font = {
                            type = 'group',
                            name = L['Font'],
                            order = 2,
                            guiInline = true,
                            get = function(info) return E.db.hud.units['player'].elements['name'].media.font[ info[#info] ] end,
                            set = function(info,value) E.db.unitframe.units['player'].elements['name'].media.font[ info[#info] ] = value; H:UpdateHud('player') end,
                            args = {
                                override = {
                                    type = "toggle",
                                    order = 1,
                                    name = L["Override"],
                                    desc = L["Override the default statusbar texture for the hud"],
                                },
                                font = {
                                    type = "select", dialogControl = 'LSM30_Font',
                                    order = 1,
                                    name = L["Default Font"],
                                    desc = L["The font that the core of the UI will use."],
                                    values = AceGUIWidgetLSMlists.font, 
                                    get = function(info) return E.db.hud[ info[#info] ] end,   
                                    set = function(info, value) E.db.hud[ info[#info] ] = value; H:UpdateMedia() end,
                                },
                                fontsize = {
                                    type = "range",
                                    order = 5,
                                    name = L["Font Size"],
                                    desc = L["Set the Width of the Text Font"],
                                    min = 10, max = 30, step = 1,   
                                }, 
                            }
                        },
                    },
                },
                tag = {
                    type = 'input',
                    width = 'full',
                    name = L['Text Format'],
                    desc = L['TEXT_FORMAT_DESC'],
                    order = 3,
                },  
            }
        },
        raidicon = {
            order = 900,
            type = 'group',
            name = L['Raid Icon'],
            get = function(info) return E.db.hud.units['player'].elements['raidicon'][ info[#info] ] end,
            set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'][ info[#info] ] = value; H:UpdateHud('player') end,
            args = {
                enabled = {
                    type = 'toggle',
                    order = 1,
                    name = L['Enable'],
                },
                anchor = {
                    order = 2,
                    type = "group",
                    name = L["Anchor"],
                    guiInline = true,
                    get = function(info) return E.db.hud.units['player'].elements['raidicon'].anchor[ info[#info] ] end,
                    set = function(info,value) E.db.unitframe.units['player'].elements['raidicon'].anchor[ info[#info] ] = value; H:UpdateHud('player') end,
                    args = {
                        pointFrom = {
                            type = 'select',
                            name = L["Point From"],
                            desc = L["Position on the element to anchor"],
                            order = 2,
                            values = positionValues,
                        },
                        attachTo = {
                            type = 'input',
                            width = 'full',
                            name = L['Attach To'],
                            desc = L['What to attach this element to.'],
                            order = 3,
                        },
                        pointTo = {
                            type = 'select',
                            desc = L["Position on the attached element to anchor to"],
                            name = L['Point To'],
                            order = 4,
                            values = positionValues,
                        },
                        xOffset = {
                            order = 5,
                            name = L['X Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                        yOffset = {
                            order = 6,
                            name = L['Y Offset'],
                            type = 'range',
                            min = -1000, max = 1000, step = 1,
                        },
                    }    
                },
            }
        },
    },
}

local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:GetModule('HUD');
local LSM = LibStub("LibSharedMedia-3.0");

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

function H:GenerateElementOptionTable(unit,element,order,name,hasAnchor,hasSize,hasTexture,hasFont,hasColor,hasValue,hasTag)
	options = {
		order = order,
		type = 'group',
		name = L[name],
		get = function(info) return E.db.hud.units[unit].elements[element][ info[#info] ] end,
		set = function(info,value)  E.db.hud.units[unit].elements[element][ info[#info] ] = value; H:UpdateFrames(unit) end,
		args = {
			enabled = {
                type = 'toggle',
                order = 1,
                name = L['Enable'],
            },
		}
	}
	if hasAnchor then
		if not ((unit == 'player' or unit == 'target') and element == 'castbar') then
			options.args.anchor = {
				order = 2,
	            type = "group",
	            name = L["Anchor"],
	            guiInline = true,
	            get = function(info) return E.db.hud.units[unit].elements[element].anchor[ info[#info] ] end,
	            set = function(info,value) E.db.hud.units[unit].elements[element].anchor[ info[#info] ] = value; H:UpdateFrame(unit) end,
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
			}
		else
			options.arg.anchor = {
                order = 2,
                type = "group",
                name = L["Anchor"],
                guiInline = true,
                get = function(info) return E.db.hud.units[unit].elements[element].anchor[ info[#info] ] end,
                set = function(info,value) E.db.hud.units[unit].elements[element].anchor[ info[#info] ] = value; H:UpdateAllFrames() end,
                args = {
                    horizontal = {
                        order = 2,
                        type = "group",
                        name = L["Horizontal"],
                        guiInline = true,
                        get = function(info) return E.db.hud.units[unit].elements[element].anchor.horizontal[ info[#info] ] end,
                        set = function(info,value) E.db.hud.units[unit].elements[element].anchor.horizontal[ info[#info] ] = value; H:UpdateAllFrames() end,
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
                        get = function(info) return E.db.hud.units[unit].elements[element].anchor.vertical[ info[#info] ] end,
                        set = function(info,value) E.db.hud.units[unit].elements[element].anchor.vertical[ info[#info] ] = value; H:UpdateAllFrames() end,
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
            }
		end
	end
	if hasSize then
		if not ((unit == 'player' or unit == 'target') and element == 'castbar') then
			options.args.size = {
				order = 3,
	            type = 'group',
	            name = L['Size'],
	            guiInline = true,
	            get = function(info) return E.db.hud.units[unit].elements[element].size[ info[#info] ] end,
	            set = function(info,value) E.db.hud.units[unit].elements[element].size[ info[#info] ] = value; H:UpdateFrame(unit) end,
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
			}
		else
			options.arg.size = {
                order = 3,
                type = 'group',
                name = L['Size'],
                guiInline = true,
                get = function(info) return E.db.hud.units[unit].elements[element].size[ info[#info] ] end,
                set = function(info,value) E.db.hud.units[unit].elements[element].size[ info[#info] ] = value; H:UpdateAllFrames() end,
                args = {
                    horizontal = {
                        order = 3,
                        type = 'group',
                        name = L['Horizontal'],
                        guiInline = true,
                        get = function(info) return E.db.hud.units[unit].elements[element].size.horizontal[ info[#info] ] end,
                        set = function(info,value) E.db.hud.units[unit].elements[element].size.horizontal[ info[#info] ] = value; H:UpdateAllFrames() end,
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
                        get = function(info) return E.db.hud.units[unit].elements[element].size.vertical[ info[#info] ] end,
                        set = function(info,value) E.db.hud.units[unit].elements[element].size.verticalal[ info[#info] ] = value; H:UpdateAllFrames() end,
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
            }
        end
	end
	if hasTexture or hasFont or hasColor then
		options.args.media = {
			order = 4,
            type = 'group',
            name = L['Media'],
            guiInline = true,
            args = { }
		}
		if hasTexture then
			options.args.media.args.texture = {
				type = 'group',
                name = L['Texture'],
                order = 1,
                guiInline = true,
                get = function(info) return E.db.hud.units[unit].elements[element].media.texture[ info[#info] ] end,
                set = function(info,value) E.db.hud.units[unit].elements[element].media.texture[ info[#info] ] = value; H:UpdateFrame(unit) end,
                args = {
                    override = {
                        type = "toggle",
                        order = 1,
                        name = L["Override"],
                        desc = L["Override the default statusbar texture for the hud to use this texture for the element"],
                    },
                    statusbar = {
                        type = "select", dialogControl = 'LSM30_Statusbar',
                        order = 2,
                        name = L["Texture"],
                        desc = L["The texture that will be used for statusbars on this element."],
                        values = AceGUIWidgetLSMlists.statusbar,
                    },
                }
			}
		end
		if hasFont then
			options.args.media.args.font = {
                type = 'group',
                name = L['Font'],
                order = 2,
                guiInline = true,
                get = function(info) return E.db.hud.units[unit].elements[element].media.font[ info[#info] ] end,
                set = function(info,value) E.db.hud.units[unit].elements[element].media.font[ info[#info] ] = value; H:UpdateFrame(unit) end,
                args = {
                    override = {
                        type = "toggle",
                        order = 1,
                        name = L["Override"],
                        desc = L["Override the default font for the hud to use this font for this element"],
                    },
                    font = {
                        type = "select", dialogControl = 'LSM30_Font',
                        order = 1,
                        name = L["Default Font"],
                        desc = L["Set the font for this element"],
                        values = AceGUIWidgetLSMlists.font, 
                    },
                    fontsize = {
                        type = "range",
                        order = 5,
                        name = L["Font Size"],
                        desc = L["Set the font size for this element"],
                        min = 10, max = 30, step = 1,   
                    }, 
                }
            }
		end
		if hasColor then
			if element ~= 'castbar' then
				options.args.media.args.color = {
                    order = 10,
                    type = 'color',
                    name = L['Color'],
                    get = function(info)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        return t.r, t.g, t.b, t.a
                    end,
                    set = function(info, r, g, b)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        t.r, t.g, t.b = r, g, b
                        H:UpdateAllFrames()
                    end,
                }
	        else
	        	options.args.media.args.color = {
                    order = 10,
                    type = 'color',
                    name = L['Color'],
                    get = function(info)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        return t.r, t.g, t.b, t.a
                    end,
                    set = function(info, r, g, b)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        t.r, t.g, t.b = r, g, b
                        H:UpdateAllFrames()
                    end,
                }
                options.args.media.args.interruptcolor = {
                    order = 11,
                    type = 'color',
                    name = L['Interrupt Color'],
                    get = function(info)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        return t.r, t.g, t.b, t.a
                    end,
                    set = function(info, r, g, b)
                        local t = E.db.hud.units[unit].elements[element].media[ info[#info] ]
                        t.r, t.g, t.b = r, g, b
                        H:UpdateAllFrames()
                    end,
                }
	        end
        end
	end
	if hasValue then
		options.args.value = {
            order = 10,
            type = "group",
            name = L["Anchor"],
            guiInline = true,
            get = function(info) return E.db.hud.units[unit].elements[element].value[ info[#info] ] end,
            set = function(info,value) E.db.hud.units[unit].elements[element].value[ info[#info] ] = value; H:UpdateAllFrames() end,
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
                    get = function(info) return E.db.hud.units[unit].elements[element].value.anchor[ info[#info] ] end,
                    set = function(info,value) E.db.hud.units[unit].elements[element].value.anchor[ info[#info] ] = value; H:UpdateAllFrames() end,
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
            },
        }
    end

    if hasTag then
    	if hasValue then
	    	options.args.value.args.tag = {
	            type = 'input',
	            width = 'full',
	            name = L['Text Format'],
	            desc = L['TEXT_FORMAT_DESC'],
	            order = 3,
	        }
        else
        	options.args.tag = {
	            type = 'input',
	            width = 'full',
	            name = L['Text Format'],
	            desc = L['TEXT_FORMAT_DESC'],
	            order = 3,
	        }
	    end
	end
    return options
end

local function healthOptions(unit) return H:GenerateElementOptionTable(unit,'health',100,'Health',true,true,true,true,true,true,true) end
local function powerOptions(unit) return H:GenerateElementOptionTable(unit,'power',200,'Power',true,true,true,true,false,true,true) end
local function castbarOptions(unit) return H:GenerateElementOptionTable(unit,'castbar',300,'Castbar',true,true,true,true,true,false,false) end
local function nameOptions(unit) return H:GenerateElementOptionTable(unit,'name',400,'Name',true,false,false,true,false,false,true) end
local function classbarOptions(unit) return H:GenerateElementOptionTable(unit,'classbars',500,'Classbars',true,true,true,true,false,true,false) end
local function cpointOptions(unit) return H:GenerateElementOptionTable(unit,'cpoints',600,'Combo Points',true,true,true,true,false,false,false) end
local function aurabarOptions(unit) return H:GenerateElementOptionTable(unit,'aurabars',700,'Aurabars',true,true,true,true,false,false,false) end
local function raidIconOptions(unit) return H:GenerateElementOptionTable(unit,'raidicon',800,'Raid Icon',true,false,false,false,false,false,false) end
local function restingOptions(unit) return H:GenerateElementOptionTable(unit,'resting',900,'Resting Indicator',true,false,false,false,false,false,false) end
local function combatOptions(unit) return H:GenerateElementOptionTable(unit,'combat',1000,'Combat Indicator',true,false,false,false,false,false,false) end
local function pvpOptions(unit) return H:GenerateElementOptionTable(unit,'pvp',1100,'PVP Text',true,false,false,true,false,false,true) end
local function healcommOptions(unit) return H:GenerateElementOptionTable(unit,'healcomm',false,false,true,false,false,false,false) end

local elementOptions = {
	['health'] = healthOptions,
	['power'] = powerOptions,
	['castbar'] = castbarOptions,
	['name'] = nameOptions,
	['classbars'] = classbarOptions,
	['cpoints'] = cpointOptions,
	['aurabars'] = aurabarOptions,
	['raidicon'] = raidIconOptions,
	['resting'] = restingOptions,
	['combat'] = combatOptions,
	['pvp'] = pvpOptions,
	['healcommOptions'] = healcommOptions,
}

function H:GenerateUnitOptionTable(unit,name,order,mover,elements)
	options = {
        name = L[name],
        type = 'group',
        order = 200,
        childGroups = "select",
        get = function(info) return E.db.hud.units[unit][ info[#info] ] end,
        set = function(info, value) E.db.hud.units[unit][ info[#info] ] = value; H:UpdateFrame(unit); end,
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
                func = function(info,value) H:ResetUnitSettings(unit); E:ResetMovers(mover) end,
            },
            width = {
                order = 4,
                name = L['Width'],
                type = 'range',
                min = 7, max = 50, step = 1,
                get = function(info) return E.db.hud.units[unit][ info[#info] ] end,
                set = function(info,value)
                    E.db.hud.units['player'][ info[#info] ] = value;
                    H:UpdateElementSizes('player',true,value)
                    H:UpdateAllFrames() 
                end
            },
            height = {
                order = 5,
                name = L['Height'],
                type = 'range',
                min = 20, max = 600, step = 1,
                get = function(info) return E.db.hud.units[unit][ info[#info] ] end,
                set = function(info,value) 
                    E.db.hud.units['player'][ info[#info] ] = value; 
                    H:UpdateElementSizes('player',false,value)
                    H:UpdateAllFrames() 
                end
            },
        }
    }
    for element,_ in pairs(elements) do
        options.args[element] = elementOptions[element]
    end
end

local nameMap = {
    ['player'] = {
        ['name'] = 'Player Hud',
        ['mover'] = 'Player Hud Frame'
    },
    ['target'] = {
        ['name'] = 'Target Hud',
        ['mover'] = 'Target Hud Frame'
    },
    ['pet'] = {
        ['name'] = 'Pet Hud',
        ['mover'] = 'Pet Hud Frame'
    },
    ['targettarget'] = {
        ['name'] = 'Target Target Hud',
        ['mover'] = 'Target Target Hud Frame'
    },
     ['pettarget'] = {
        ['name'] = 'Pet Target Hud',
        ['mover'] = 'Pet Target Hud Frame'
    },
}

function H:GenerateOptionTables()
    local order = 200
    local step = 200
    for unit,_ in pairs(self.units) do
        E.Options.args.hud.args[unit] = self:GenerateUnitOptionTable(unit,nameMap[unit].name,order,nameMap[unit].mover,self.units[unit].elements)
        order = order + step
    end
end
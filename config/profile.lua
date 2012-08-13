local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P['hud'] = {
    ['enabled'] = true,
    ['hideElv'] = true,
    ['horizCastbar'] = true,
    ['unicolor'] = true,
    ['flash'] = true,
    ['enableMouse'] = false, -- Turn off the mouse for click through
    ['warningText'] = true,
    ['lowThreshold'] = 20, -- flash health and mana bars below this %
    ['colorHealthByValue'] = true,
    ['hideOOC'] = true,
    ['font'] = "ElvUI Font",
    ['statusbar'] = "Minimalist",
    ['fontsize'] = 12,
    ['alpha'] = 1,
    ['alphaOOC'] = 0,
}

P['hud']['layout'] = {
    ['player'] = {
        ['enabled'] = true,
        ['height'] = 150,
        ['width'] = 39,
        ['elements'] = {
            ['health'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'LEFT',
                    ['attachTo'] = 'self',
                    ['pointTo'] = 'LEFT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 150,
                    ['width'] = 15,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                    ['color'] = unpack({ 0.05, 0.05, 0.05 })
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'TOPRIGHT',
                        ['attachTo'] = 'health',
                        ['pointTo'] = 'TOPLEFT',
                        ['xOffset'] = -20,
                        ['yOffset'] = -15,
                    },
                },
            },
            ['power'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'LEFT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'RIGHT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 150,
                    ['width'] = 10,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'TOPLEFT',
                        ['attachTo'] = 'power',
                        ['pointTo'] = 'TOPRIGHT',
                        ['xOffset'] = 10,
                        ['yOffset'] = -15,
                    },
                },
            },
            ['castbar'] = {
                ['enabled'] = true,
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                    ['color'] = { r = 0.78, g = 0.25, b = 0.25 },
                    ["interruptcolor"] = { r = 0.1,g = 0.1,b = 0.1 },
                },
                ['size'] = {
                    ['horizontal'] = {
                        ['height'] = 26,
                        ['width'] = 300,
                    },
                    ['vertical'] = {
                        ['height'] = 150,
                        ['width'] = 10,
                    },
                },
                ['anchor'] = {
                    ['horizontal'] = {
                        ['pointFrom'] = 'CENTER',
                        ['attachTo'] = 'ui',
                        ['pointTo'] = 'CENTER',
                        ['xOffset'] = 0,
                        ['yOffset'] = -75,
                    },
                    ['vertical'] = {
                        ['pointFrom'] = 'BOTTOM',
                        ['attachTo'] = 'power',
                        ['pointTo'] = 'BOTTOM',
                        ['xOffset'] = 0,
                        ['yOffset'] = 0,
                    },
                },
            },
            ['name'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOM',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'TOP',
                    ['xOffset'] = 0,
                    ['yOffset'] = 15,
                },
                ['media'] = {
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['classbars'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOMRIGHT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOMLEFT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 146,
                    ['width'] = 7,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
                -- value for warlock demonology spec
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'BOTTOMRIGHT',
                        ['attachTo'] = 'classbars',
                        ['pointTo'] = 'BOTTOMLEFT',
                        ['xOffset'] = -4,
                        ['yOffset'] = 15,
                    },
                },
            },
            ['threat'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOMLEFT',
                    ['attachTo'] = 'power',
                    ['pointTo'] = 'BOTTOMRIGHT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 112,
                    ['width'] = 7,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['aurabars'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'TOP',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOM',
                    ['xOffset'] = 9,
                    ['yOffset'] = -60,
                },
                ['size'] = {
                    ['height'] = 30,
                    ['width'] = 225,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['raidicon'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'CENTER',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'CENTER',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0
                }
            },
            ['resting'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'CENTER',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'TOPLEFT',
                    ['xOffset'] = -6,
                    ['yOffset'] = 10
                }
            },
            ['combat'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'CENTER',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'TOPRIGHT',
                    ['xOffset'] = 6,
                    ['yOffset'] = 10
                }
            },
            ['pvp'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'TOP',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOM',
                    ['xOffset'] = 0,
                    ['yOffset'] = -6
                },
                ['media'] = {
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['healcomm'] = {
                ['enabled'] = true,
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                }
            }
        },
    },
    ['target'] = {
        ['enabled'] = true,
        ['height'] = 150,
        ['width'] = 27,
        ['elements'] = {
            ['health'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'RIGHT',
                    ['attachTo'] = 'self',
                    ['pointTo'] = 'RIGHT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 150,
                    ['width'] = 15,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                    ['color'] = unpack({ 0.05, 0.05, 0.05 })
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'LEFT',
                        ['attachTo'] = 'health',
                        ['pointTo'] = 'RIGHT',
                        ['xOffset'] = 20,
                        ['yOffset'] = 0,
                    },
                },
            },
            ['power'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'RIGHT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'LEFT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 150,
                    ['width'] = 10,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'RIGHT',
                        ['attachTo'] = 'power',
                        ['pointTo'] = 'LEFT',
                        ['xOffset'] = -4,
                        ['yOffset'] = 0,
                    },
                },
            },
            ['castbar'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['horizontal'] = {
                        ['pointFrom'] = 'TOP',
                        ['attachTo'] = 'player:castbar',
                        ['pointTo'] = 'BOTTOM',
                        ['xOffset'] = 0,
                        ['yOffset'] = -4,
                    },
                    ['vertical'] = {
                        ['pointFrom'] = 'BOTTOM',
                        ['attachTo'] = 'power',
                        ['pointTo'] = 'BOTTOM',
                        ['xOffset'] = 0,
                        ['yOffset'] = 0,
                    },
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                    ['color'] = { r = 0.78, g = 0.25, b = 0.25 },
                    ["interruptcolor"] = { r = 0.1,g = 0.1,b = 0.1 },
                },
                ['size'] = {
                    ['horizontal'] = {
                        ['height'] = 26,
                        ['width'] = 300,
                    },
                    ['vertical'] = {
                        ['height'] = 150,
                        ['width'] = 10,
                    },
                },
            },
            ['name'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOM',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'TOP',
                    ['xOffset'] = 0,
                    ['yOffset'] = 15,
                },
                ['media'] = {
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['cpoints'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOMLEFT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOMRIGHT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 146,
                    ['width'] = 7,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
            },
            ['aurabars'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'TOP',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOM',
                    ['xOffset'] = 9,
                    ['yOffset'] = -60,
                },
                ['size'] = {
                    ['height'] = 30,
                    ['width'] = 225,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['raidicon'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'CENTER',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'CENTER',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0
                }
            },
        },
    },
    ['pet'] = {
        ['enabled'] = true,
        ['height'] = 113,
        ['width'] = 27,
        ['elements'] = {
            ['health'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'LEFT',
                    ['attachTo'] = 'self',
                    ['pointTo'] = 'LEFT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 112,
                    ['width'] = 15,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                    ['color'] = unpack({ 0.05, 0.05, 0.05 })
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'RIGHT',
                        ['attachTo'] = 'health',
                        ['pointTo'] = 'LEFT',
                        ['xOffset'] = -4,
                        ['yOffset'] = 0,
                    },
                },
            },
            ['power'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'LEFT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'RIGHT',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 112,
                    ['width'] = 10,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
                ['value'] = {
                    ['enabled'] = true,
                    ['anchor'] = {
                        ['pointFrom'] = 'LEFT',
                        ['attachTo'] = 'power',
                        ['pointTo'] = 'RIGHT',
                        ['xOffset'] = 4,
                        ['yOffset'] = 0,
                    },
                },
            },
            ['castbar'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOM',
                    ['attachTo'] = 'power',
                    ['pointTo'] = 'BOTTOM',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0,
                },
                ['size'] = {
                    ['height'] = 112,
                    ['width'] = 10,
                },
                ['media'] = {
                    ['texture'] = {
                        ['ovveride'] = false,
                        ['statusbar'] = "Minimalist",
                    },
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                },
            },
            ['name'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOM',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'TOP',
                    ['xOffset'] = 0,
                    ['yOffset'] = 15,
                },
                ['media'] = {
                    ['font'] = {
                        ['override'] = false,
                        ['font'] = "ElvUI Font",
                        ['fontsize'] = 12,
                    },
                }
            },
            ['raidicon'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'CENTER',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'CENTER',
                    ['xOffset'] = 0,
                    ['yOffset'] = 0
                }
            },
        },
    },
}
                    
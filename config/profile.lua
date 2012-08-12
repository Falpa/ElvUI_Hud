local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P['hud'] = {
    ['enabled'] = true,
    ['simpleLayout'] = false,
    ['simpleTarget'] = false,
    ['petHud'] = true,
    ['hideElv'] = true,
    ['names'] = true,
    ['horizCastbar'] = true,
    ['showThreat'] = true,
    ['classBars'] = true,
    ['showValues'] = true,
    ['unicolor'] = true,
    ['flash'] = true,
    ['enableMouse'] = false, -- Turn off the mouse for click through
    ['warningText'] = true,
    ['lowThreshold'] = 20, -- flash health and mana bars below this %
    ['colorHealthByValue'] = true,
    ['smooth'] = true,
    ['hideOOC'] = true,
    ['height'] = 150,
    ['width'] = 15,
    ['offset'] = 275,
    ['yoffest'] = 0,
    ['font'] = P["general"].font,
    ['texture'] = P["unitframe"].statusbar,
    ['fontsize'] = 12,
    ['alpha'] = 1,
    ['alphaOOC'] = 0,
}

P['hud']['layout'] = {
    ['player'] = {
        ['enabled'] = true,
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
                    ['xOffset'] = 4,
                    ['yOffset'] = 0,
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
            },
            ['classbars'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOMRIGHT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOMLEFT',
                    ['xOffset'] = -6,
                    ['yOffset'] = 0,
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
            },
        },
    },
    ['target'] = {
        ['enabled'] = true,
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
                    ['xOffset'] = -4,
                    ['yOffset'] = 0,
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
            },
            ['cpoints'] = {
                ['enabled'] = true,
                ['anchor'] = {
                    ['pointFrom'] = 'BOTTOMLEFT',
                    ['attachTo'] = 'health',
                    ['pointTo'] = 'BOTTOMRIGHT',
                    ['xOffset'] = 6,
                    ['yOffset'] = 0,
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
            },
        },
    },
    ['pet'] = {
        ['enabled'] = true,
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
                    ['xOffset'] = 4,
                    ['yOffset'] = 0,
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
            },
        },
    },
}
                    
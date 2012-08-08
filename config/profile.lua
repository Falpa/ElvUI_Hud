local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

P['hud'] = {
    ['enabled'] = true,
    ['simpleLayout'] = false,
    ['simpleTarget'] = false,
    ['petHud'] = true,
    ['hideElv'] = true,
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


local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:NewModule('HUD','AceTimer-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0");

H.frames = {}

function H:updateAllElements(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

function H.SetUpAnimGroup(self)
-- The following functions are thanks to Hydra from the ElvUI forums
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

function H.Flash(self,duration)
    if not E.db.hud.flash then return end
    if not self.anim then
        H.SetUpAnimGroup(self)
    end

    self.anim.fadein:SetDuration(duration)
    self.anim.fadeout:SetDuration(duration)
    self.anim:Play()
end

function H:CreateWarningFrame()
	local f=CreateFrame("ScrollingMessageFrame","ElvUIHudWarning",UIParent)
	f:SetFont(LSM:Fetch("font", (E.db.hud or P.hud).font),(E.db.hud or P.hud).fontsize*2,"THINOUTLINE")
	f:SetShadowColor(0,0,0,0)
	f:SetFading(true)
	f:SetFadeDuration(0.5)
	f:SetTimeVisible(0.6)
	f:SetMaxLines(10)
	f:SetSpacing(2)
	f:SetWidth(128)
	f:SetHeight(128)
	f:SetPoint("CENTER",0,E:Scale(-100))
	f:SetMovable(false)
	f:SetResizable(false)
	--f:SetInsertMode("TOP") -- Bugged currently
end

local __Hide = function(frame,event)
    local alpha = E.db.hud.alpha
    local oocalpha = E.db.hud.alphaOOC

	if (event == "PLAYER_REGEN_DISABLED") then
			UIFrameFadeIn(frame, 0.3 * (alpha - frame:GetAlpha()), frame:GetAlpha(), alpha)
	elseif (event == "PLAYER_REGEN_ENABLED") then
			UIFrameFadeOut(frame, 0.3 * (oocalpha + frame:GetAlpha()), frame:GetAlpha(), oocalpha)
	elseif (event == "PLAYER_ENTERING_WORLD") then
			if (not InCombatLockdown()) then
					frame:SetAlpha(oocalpha)
			end
	end
end

local frames = { }

function H:HideOOC(frame)
	if E.db.hud.hideOOC == true then
		local hud_hider = CreateFrame("Frame", nil, UIParent)
		hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
		hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
		hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
		hud_hider:SetScript("OnEvent", function(self,event) __Hide(frame,event) end)
		frame.hud_hider = hud_hider
	end
    tinsert(frames,frame)
end

function H:UpdateHideSetting()
    if not E.db.hud.hideOOC then
        for _,f in pairs(frames) do
            local hud_hider = f.hud_hider
            hud_hider:UnregisterEvent("PLAYER_REGEN_DISABLED")
            hud_hider:UnregisterEvent("PLAYER_REGEN_ENABLED")
            hud_hider:UnregisterEvent("PLAYER_ENTERING_WORLD")
            __Hide(f,"PLAYER_REGEN_DISABLED")
        end
    else
        for _,f in pairs(frames) do
            local hud_hider = f.hud_hider or CreateFrame("Frame",nil,UIParent)
            hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
            hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
            hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
            hud_hider:SetScript("OnEvent", function(self,event) __Hide(f,event) end)
            f.hud_hider = hud_hider
            __Hide(f,"PLAYER_REGEN_ENABLED")
        end
    end
end

function H:Enable()
    for _,f in pairs(frames) do
        f:SetScript("OnEvent", function(self,event) __CheckEnabled(f) end)
        if not E.db.hud.enabled then
            if E.db.hud.hideOOC then
                local hud_hider = f.hud_hider
                hud_hider:UnregisterEvent("PLAYER_REGEN_DISABLED")
                hud_hider:UnregisterEvent("PLAYER_REGEN_ENABLED")
                hud_hider:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
            f:Hide()
            f:EnableMouse(false)
            f:SetAlpha(0)
        else
            if E.db.hud.hideOOC then            
                local hud_hider = f.hud_hider or CreateFrame("Frame",nil,UIParent)
                hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
                hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
                hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
                hud_hider:SetScript("OnEvent", function(self,event) __Hide(f,event) end)
                f.hud_hider = hud_hider
                __Hide(f,"PLAYER_REGEN_ENABLED")
            else
                f:Show()
                f:EnableMouse(E.db.hud.enableMouse)
                f:SetAlpha(E.db.hud.alpha)
            end
        end
    end
end

local media_frames = {}

function H:RegisterFrame(frame)
    tinsert(media_frames,frame)
end

function H:UpdateMedia()
    for _,f in pairs(media_frames) do
        f:SetStatusBarTexture(LSM:Fetch("statusbar", E.db.hud.texture))
        if E.db.hud.showValues then
            if f.value ~= nil then
                f.value:FontTemplate(LSM:Fetch("font", E.db.hud.font), E.db.hud.fontsize, "THINOUTLINE")
            end
        end
    end
end

function H:UpdateMouseSetting()
    for _,f in pairs(frames) do
        if f:IsMouseEnabled() then
            if E.db.hud.enableMouse then
                f:EnableMouse(true)
            else
                f:EnableMouse(false)
            end
        end
    end
end


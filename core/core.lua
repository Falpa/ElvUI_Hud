local E, L, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:NewModule('HUD', 'AceTimer-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0");

local db = E.Options.Hud

function H:updateAllElements(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

function H:setCoords(t, A, B, C, D, E, F)
    local det = A*E - B*D;
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
            
    ULx, ULy = ( B*F - C*E ) / det, ( -(A*F) + C*D ) / det;
    LLx, LLy = ( -B + B*F - C*E ) / det, ( A - A*F + C*D ) / det;
    URx, URy = ( E + B*F - C*E ) / det, ( -D - A*F + C*D ) / det;
    LRx, LRy = ( E - B + B*F - C*E ) / det, ( -D + A -(A*F) + C*D ) / det;
                            
    t:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

function H:Rotate(t)
    local cos, sin = math.cos, math.sin
    local angle = math.rad(90)
    self:setCoords(t, cos(angle), sin(angle), 1, -sin(angle), cos(angle), 1)
end



function H:SetUpAnimGroup()
-- The following functions are thanks to Hydra from the ElvUI forums
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

function H:Flash(duration)
    if not self.anim then
        self:SetUpAnimGroup()
    end

    self.anim.fadein:SetDuration(duration)
    self.anim.fadeout:SetDuration(duration)
    self.anim:Play()
end

function H:CreateWarningFrame()
	local f=CreateFrame("ScrollingMessageFrame","ElvUIHudWarning",UIParent)
	f:SetFont(LSM:Fetch("font", ElvUIHudCF.font),ElvUIHudCF.fontsize*2,"THINOUTLINE")
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

local alpha = db.alpha
local oocalpha = db.oocalpha

local __Hide = function(frame,event)
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

function H:HideOOC(frame)
	if db.hideOOC == true then
		local hud_hider = CreateFrame("Frame", nil, UIParent)
		hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
		hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
		hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
		hud_hider:SetScript("OnEvent", function(self,event) __Hide(frame,event) end)
		frame.hud_hider = hud_hider
	end
end

function ShowFrames()
    if db.simpleLayout then
        oUF_Elv_player_HudHealth:Show()
        oUF_Elv_player_HudPower:Show()
        if db.simpleTarget then
            oUF_Elv_target_HudHealth:Show()
            oUF_Elv_target_HudPower:Show()
        end
    else
        oUF_Elv_player_Hud:Show()
        oUF_Elv_target_Hud:Show()
        if oUF_Elv_pet_Hud then oUF_Elv_pet_Hud:Show() end
    end
end

function HideFrames()
       if db.simpleLayout then
        oUF_Elv_player_HudHealth:Hide()
        oUF_Elv_player_HudPower:Hide()
        if db.simpleTarget then
            oUF_Elv_target_HudHealth:Hide()
            oUF_Elv_target_HudPower:Hide()
        end
    else
        oUF_Elv_player_Hud:Hide()
        oUF_Elv_target_Hud:Hide()
        if oUF_Elv_pet_Hud then oUF_Elv_pet_Hud:Hide() end
    end
end

function H:Enable()
	if db.enabled then
		ShowFrames()
	else
		HideFrames()
	end
end

G["hud"] = {}
G["hud"].frames = {}
G["hud"].texture = LSM:Fetch("statusbar",db.texture,true)
G["hud"].textureRotated = true

H:Rotate(G["hud"].texture)

function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

function GetChildrenTree(frame)
    frames = {}
    if frame:GetChildren() then
        for _,child in pairs(frame:GetChildren()) do
            tinsert(frames,child)
            nf = GetChildrenTree(child)
            merge(frames,nf)
        end
    end
    return frames
end

function H:RegisterHudFrames(frame)
    merge(G["hud"].frames,GetChildrenTree(frame))
end

function H:UpdateMedia()
    if not G["hud"].textureRotated then H:Rotate(G["hud"].texture) end
    for _,f in pairs(frames) do
        if f:GetObjectType() == "StatusBar" then
            f:SetStatusBarTexture(G["hud"].texture))
        end
        if db.showValues then
            if f.value ~= nil then
                f.value:FontTemplate(LSM:Fetch("font", db.font), db.fontsize, "THINOUTLINE")
            end
        end
    end
end

function H:UpdateMouseSetting()
    for _,f in pairs(frames) do
        if f:IsMouseEnabled() then
            if db.enableMouse then
                f:EnableMouse(true)
            else
                f:EnableMouse(false)
            end
        end
    end
end
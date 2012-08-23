local addon, ns = ...
local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, ProfileDB, GlobalDB
local H = E:NewModule('HUD','AceTimer-3.0', 'AceEvent-3.0');
local LSM = LibStub("LibSharedMedia-3.0");
H.frames = {}

function H:updateAllElements(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
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

function H:Hide(frame,event)
    local alpha = E.db.hud.alpha
    local oocalpha = E.db.hud.alphaOOC

    if not UnitExists(frame.unit) then return end
	if (event == "PLAYER_REGEN_DISABLED") then
			UIFrameFadeIn(frame, 0.3 * (alpha - frame:GetAlpha()), frame:GetAlpha(), alpha)
	elseif (event == "PLAYER_REGEN_ENABLED") then
			UIFrameFadeOut(frame, 0.3 * (oocalpha + frame:GetAlpha()), frame:GetAlpha(), oocalpha)
	elseif (event == "PLAYER_ENTERING_WORLD") then
			if (not c) then
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
		hud_hider:SetScript("OnEvent", function(self,event) H:Hide(frame,event) end)
		frame.hud_hider = hud_hider
	end
    tinsert(frames,frame)
end

function H:UpdateHideSetting()
    if not E.db.hud.hideOOC then
        for _,f in pairs(frames) do
            local hud_hider = f.hud_hider
            if not hud_hider then return end
            hud_hider:UnregisterEvent("PLAYER_REGEN_DISABLED")
            hud_hider:UnregisterEvent("PLAYER_REGEN_ENABLED")
            hud_hider:UnregisterEvent("PLAYER_ENTERING_WORLD")
            H:Hide(f,"PLAYER_REGEN_DISABLED")
        end
    else
        for _,f in pairs(frames) do
            local hud_hider = f.hud_hider or CreateFrame("Frame",nil,UIParent)
            hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
            hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
            hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
            hud_hider:SetScript("OnEvent", function(self,event) H:Hide(f,event) end)
            f.hud_hider = hud_hider
            local alpha = E.db.hud[InCombatLockdown() and 'alpha' or 'alphaOOC']
            f:SetAlpha(alpha)
        end
    end
end

function H:DisableFrame(f)
    f:Hide()
    f:EnableMouse(false)
    f:SetAlpha(0)
end

function H:EnableFrame(f,a,m)
    if a == nil then a = 1 end
    if m == nil then m = true end
    f:Show()
    f:EnableMouse(m)
    f:SetAlpha(a)
end

H.updateElvFunction = nil

function H:UpdateElvUFSetting(enableChanged,init)
    if enableChanged then
        local e = E.db.hud.enabled
        if not e or not E.db.hud.hideElv then
            H.updateElvFunction = function(self) H:EnableFrame(self) end
        else
            H.updateElvFunction = function(self) H:DisableFrame(self) end
        end
    else
        if E.db.hud.hideElv then
            H.updateElvFunction = function(self) H:DisableFrame(self) end
        else
            H.updateElvFunction = function(self) H:EnableFrame(self) end
        end
    end
    ElvUF_Player:Hide()
    ElvUF_Player:Show()
end

function H:Enable()
    self:UpdateElvUFSetting(true)
    for _,f in pairs(frames) do
        f:SetScript("OnEvent", function(self,event) __CheckEnabled(f) end)
        if not E.db.hud.enabled then
            if E.db.hud.hideOOC then
                local hud_hider = f.hud_hider
                hud_hider:UnregisterEvent("PLAYER_REGEN_DISABLED")
                hud_hider:UnregisterEvent("PLAYER_REGEN_ENABLED")
                hud_hider:UnregisterEvent("PLAYER_ENTERING_WORLD")
                hud_hider:SetScript("OnEvent", nil)
            end
            H:DisableFrame(f)
        else
            if E.db.hud.hideOOC then            
                local hud_hider = f.hud_hider or CreateFrame("Frame",nil,UIParent)
                hud_hider:RegisterEvent("PLAYER_REGEN_DISABLED")
                hud_hider:RegisterEvent("PLAYER_REGEN_ENABLED")
                hud_hider:RegisterEvent("PLAYER_ENTERING_WORLD")
                hud_hider:SetScript("OnEvent", function(self,event) H:Hide(f,event) end)
                f.hud_hider = hud_hider
                H:Hide(f,"PLAYER_REGEN_ENABLED")
            else
                H:EnableFrame(f,E.db.hud.alpha,E.db.hud.enableMouse)
            end
        end
    end
end

function H:UpdateMouseSetting()
    for _,f in pairs(frames) do
        if E.db.hud.enableMouse or E.db.hud.hideElv then
            f:EnableMouse(true)
        else
            f:EnableMouse(false)
        end
    end
end

function H:Initialize()
    H:CreateWarningFrame()


    ElvUF:RegisterStyle('ElvUI_Hud',function(frame,unit)
        H:ConstructHudFrame(frame,unit)
    end)

    ElvUF:SetActiveStyle('ElvUI_Hud')
    local units = { 'player', 'target', 'pet', 'targettarget', 'pettarget' }
    for _,unit in pairs(units) do
        local stringTitle = E:StringTitle(unit)
        if stringTitle:find('target') then
            stringTitle = gsub(stringTitle, 'target', 'Target')
        end
        ElvUF:Spawn(unit, "ElvUF_"..stringTitle.."Hud")
    end

    H:GenerateOptionTables()
    H:UpdateAllFrames()
    H:UpdateMouseSetting()
    H:UpdateHideSetting()
    
    H:UpdateElvUFSetting(false,true)

    local elv_frames = { ElvUF_Player, ElvUF_Pet, ElvUF_Target, ElvUF_TargetTarget, ElvUF_PetTarget }

    ElvUF_Player:HookScript("OnShow", function(self,event) for _,f in pairs(elv_frames) do
            if f then 
                H.updateElvFunction(f)
            end
        end 
    end)

    ElvUF_Player:Hide()
    ElvUF_Player:Show()

    if not E.db.hud.enabled then
        H:Enable()
    end

    self.version = GetAddOnMetadata(addon,'Version')
    print(L["ElvUI Hud "]..format("v|cff33ffff%s|r",self.version)..L[" is loaded. Thank you for using it and note that I will always support you."])
end

E:RegisterModule(H:GetName())

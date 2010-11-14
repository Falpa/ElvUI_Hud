TukuiHud = { }

TukuiHud.updateAllElements = function(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

TukuiHud.PostUpdateHealthHud = function(health, unit, min, max)
    local r, g, b

    -- overwrite healthbar color for enemy player (a tukui option if enabled), target vehicle/pet too far away returning unitreaction nil and friend unit not a player. (mostly for overwrite tapped for friendly)
    -- I don't know if we really need to call TukuiCF["unitframes"].unicolor but anyway, it's safe this way.
    if (TukuiCF["unitframes"].unicolor ~= true and TukuiCF["unitframes"].enemyhcolor and unit == "target" and UnitIsEnemy(unit, "player")) or (TukuiCF["unitframes"].unicolor ~= true and unit == "target" and not UnitIsPlayer(unit) and UnitIsFriend(unit, "player")) then
        local c = TukuiDB.oUF_colors.reaction[UnitReaction(unit, "player")]
        if c then 
            r, g, b = c[1], c[2], c[3]
            health:SetStatusBarColor(r, g, b)
        else
            -- if "c" return nil it's because it's a vehicle or pet unit too far away, we force friendly color
            -- this should fix color not updating for vehicle/pet too far away from yourself.
            r, g, b = 75/255,  175/255, 76/255
            health:SetStatusBarColor(r, g, b)
        end					
    end

    if min ~= max then
        health.value:SetFormattedText("%d%%", floor(min / max * 100))
    end
end

TukuiHud.PreUpdatePowerHud = function(power, unit)
    local _, pType = UnitPowerType(unit)

    local color = TukuiDB.oUF_colors.power[pType]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

TukuiHud.PostUpdatePowerHud = function(power, unit, min, max)
    local self = power:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local color = TukuiDB.oUF_colors.power[pToken]

    if color then
        power.value:SetTextColor(color[1], color[2], color[3])
    end

    if min ~= max then
        if pType == 0 then
            power.value:SetFormattedText("%d%%", floor(min / max * 100))
        end
    end
end


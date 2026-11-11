local lastPetLevel = 0
local lastPetGuid = nil
local _, playerClass = UnitClass("player")

local function UpdatePetInfo()
    lastPetGuid = UnitGUID("pet")
    if lastPetGuid then
        lastPetLevel = UnitLevel("pet")
    end
end

local function InitializeSettings()
    if not DingLevelUpSettings then
        DingLevelUpSettings = {
            playerAnnounce = true,
            petAnnounce = true
        }
    end
    if playerClass == "HUNTER" then
        UpdatePetInfo()
    end
end

-- Create a hidden frame to "listen" for game events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("UNIT_LEVEL")
frame:RegisterEvent("UNIT_PET")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Ding_Level_Up" then
        InitializeSettings()
        print("|cff00ff00[DingLevelUp]|r loaded.")
        return
    end

    if event == "PLAYER_LEVEL_UP" and DingLevelUpSettings.playerAnnounce then
        local level = arg1 or UnitLevel("player")
        if IsInGuild() then
            SendChatMessage("DING! I just reached level " .. level .. "!", "GUILD")
        else
            print("|cff00ff00[DingLevelUp]|r DING! I just reached level " .. level .. "!")
        end
        return
    elseif playerClass == "HUNTER" and event == "UNIT_PET" then
        UpdatePetInfo()
        return
    end

    if playerClass == "HUNTER" and event == "UNIT_LEVEL" and arg1 == "pet" and DingLevelUpSettings.petAnnounce then
        C_Timer.After(0.5, function()
            local petGuid = UnitGUID("pet")
            local petName = UnitName("pet")
            local petLevel = UnitLevel("pet")

            -- Pet was swapped during 0.5s delay, update and abort announcement
            if petGuid ~= lastPetGuid then
                UpdatePetInfo()
                return
            end

            if petLevel > lastPetLevel and petLevel > 0 then
                if IsInGuild() then
                    SendChatMessage("DING! " .. petName .. " just reached level " .. petLevel .. "!", "GUILD")
                else
                    print("|cff00ff00[DingLevelUp]|r DING! " .. petName .. " just reached level " .. petLevel .. "!")
                end
            end
            lastPetLevel = petLevel
        end)
    end
end)

SLASH_DINGLEVELUP1 = "/ding"
SlashCmdList["DINGLEVELUP"] = function(msg)
    local cmd = msg:lower():trim()
    if cmd == "player" then
        DingLevelUpSettings.playerAnnounce = not DingLevelUpSettings.playerAnnounce
        print("Player Ding: " .. (DingLevelUpSettings.playerAnnounce and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "pet" then
        DingLevelUpSettings.petAnnounce = not DingLevelUpSettings.petAnnounce
        print("Pet Ding: " .. (DingLevelUpSettings.petAnnounce and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "test" then
        local level = UnitLevel("player")
        print("|cff00ff00[DingLevelUp]|r Simulating announcement...")
        if IsInGuild() then
            SendChatMessage("DING! I just reached level " .. level .. "! (Test)", "GUILD")
        else
            print("|cff00ff00[DingLevelUp]|r DING! I just reached level " .. level .. "! (Test)")
        end
    else
        print("|cffffff00DingLevelUp Options:|r")
        print("Type |cffffff00/ding player|r to toggle Player Announce")
        print("Type |cffffff00/ding pet|r to toggle Pet Announce")
    end
end

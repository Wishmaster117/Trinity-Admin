TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

------------------------------------------------------------
-- Librairie icone minimap
------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("TrinityAdmin", {
    type = "launcher",
    text = "TrinityAdmin",
    icon = "Interface\\Icons\\Inv_7xp_inscription_talenttome01",  -- Remplacez par l'icône souhaitée
    OnClick = function(self, button)
        if button == "LeftButton" then
            TrinityAdmin:ToggleUI()  -- Ouvre/ferme votre interface
        elseif button == "RightButton" then
            -- Ajoutez ici d'autres actions si besoin
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("TrinityAdmin")
        tooltip:AddLine("Cliquez pour ouvrir le menu principal.", 1, 1, 1)
    end,
})

-- Table de sauvegarde pour l'icône minimap
TrinityAdminDB = TrinityAdminDB or {}
TrinityAdminDB.minimap = TrinityAdminDB.minimap or { hide = false }

-- Enregistrement de l'icône sur la minimap
local icon = LibStub("LibDBIcon-1.0")
icon:Register("TrinityAdmin", LDB, TrinityAdminDB.minimap)

-- Création des modules dans TrinityAdmin.lua (uniquement ici)
local TeleportModule = TrinityAdmin:NewModule("TeleportPanel")
local GMModule = TrinityAdmin:NewModule("GMPanel")
local NPCModule = TrinityAdmin:NewModule("NPCPanel")
local AccountModule = TrinityAdmin:NewModule("AccountPanel")
local GMFunctionsModule = TrinityAdmin:NewModule("GMFunctionsPanel")

------------------------------------------------------------
-- Fonctions globales appelées depuis l'interface XML
------------------------------------------------------------
function TrinityAdmin_ShowTeleportPanel()
    TeleportModule:ShowTeleportPanel()
end

function TrinityAdmin_ShowGMPanel()
    GMModule:ShowGMPanel()
end

function TrinityAdmin_ShowNPCPanel()
    NPCModule:ShowNPCPanel()
end

function TrinityAdmin_ShowGMFunctionsPanel()
    GMFunctionsModule:ShowGMFunctionsPanel()
end

function TrinityAdmin_ShowAccountPanel()
    AccountModule:ShowAccountPanel()
end

------------------------------------------------------------
-- Fonctions d'initialisation
------------------------------------------------------------
function TrinityAdmin:OnInitialize()
    self:Print("TrinityAdmin OnInitialize fired")
    self:RegisterChatCommand("trinityadmin", "ToggleUI")
    self.gmFlyOn = false
end

function TrinityAdmin:OnEnable()
    TrinityAdminMainFrameTitle:SetText(TrinityAdmin_Translations["TrinityAdmin Main Menu"])
end

function TrinityAdmin:OnDisable()
    self:Print("TrinityAdmin OnDisable fired")
end

------------------------------------------------------------
-- /trinityadmin : ouvre/ferme le mainFrame
------------------------------------------------------------
function TrinityAdmin:ToggleUI()
    if TrinityAdminMainFrame:IsShown() then
        TrinityAdminMainFrame:Hide()
    else
        TrinityAdminMainFrame:Show()
    end
end

------------------------------------------------------------
-- Gestion du "menu principal" (les 4 boutons désormais)
------------------------------------------------------------
function TrinityAdmin:ShowMainMenu()
    if TeleportModule.panel then TeleportModule.panel:Hide() end
    if GMModule.panel then GMModule.panel:Hide() end
    if NPCModule.panel then NPCModule.panel:Hide() end
    if AccountModule.panel then AccountModule.panel:Hide() end
    if GMFunctionsModule.panel then GMFunctionsModule.panel:Hide() end

    TrinityAdminMainFrameTeleportButton:Show()
    TrinityAdminMainFrameGMButton:Show()
    TrinityAdminMainFrameNPCButton:Show()
    TrinityAdminMainFrameGMFunctionsButton:Show()
    TrinityAdminMainFrameAccountButton:Show()

    TrinityAdminMainFrame:Show()
end

------------------------------------------------------------
-- Fonction pour cacher le menu principale quand on est dans les sous menus
------------------------------------------------------------
function TrinityAdmin:HideMainMenu()
    TrinityAdminMainFrameTeleportButton:Hide()
    TrinityAdminMainFrameGMButton:Hide()
    TrinityAdminMainFrameNPCButton:Hide()
    TrinityAdminMainFrameGMFunctionsButton:Hide()
    TrinityAdminMainFrameAccountButton:Hide()

    TrinityAdminMainFrame:Show()
end


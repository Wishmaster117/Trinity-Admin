TrinityAdmin = LibStub("AceAddon-3.0"):NewAddon("TrinityAdmin", "AceConsole-3.0", "AceEvent-3.0")

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
local DatabaseModule = TrinityAdmin:NewModule("DatabasePanel")
local ServerAdminModule = TrinityAdmin:NewModule("ServerAdmin") -- Module gestion serveur
local GameObjectsModule = TrinityAdmin:NewModule("GameObjects") -- Module gestion des objets
local AddItemModule = TrinityAdmin:NewModule("AddItem") -- Module pour ajouter et apprendre
local AdvancedItemsModule = TrinityAdmin:NewModule("AdvancedItems") -- Advanced items
local ModuleCharacterModule = TrinityAdmin:NewModule("ModuleCharacter") -- Character Module
local WaypointsModule = TrinityAdmin:NewModule("Waypoints")
local AhBotModule = TrinityAdmin:NewModule("AhBot")
local GuildModule = TrinityAdmin:NewModule("Guild")
local LearnDamageModule = TrinityAdmin:NewModule("LearnDamage")
local AdvancedGobModule = TrinityAdmin:NewModule("AdvancedGob")
local AdvancedNpcModule = TrinityAdmin:NewModule("AdvancedNpc")
local MiscModule = TrinityAdmin:NewModule("Misc")
local cheatModule = TrinityAdmin:NewModule("cheat")
local DebugModule = TrinityAdmin:NewModule("Debug")
local OthersModule = TrinityAdmin:NewModule("Others")
local TicketsModule = TrinityAdmin:NewModule("Tickets")






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

function TrinityAdmin_ShowDatabasePanel()
    DatabaseModule:ShowDatabasePanel()
end

function TrinityAdmin_ShowServerAdminPanel()
    ServerAdminModule:ShowServerAdminPanel()
end

function TrinityAdmin_ShowGameObjectsPanel()
    GameObjectsModule:ShowGameObjectsPanel()
end

function TrinityAdmin_ShowAddItemPanel()
    AddItemModule:ShowAddItemPanel()
end

function TrinityAdmin_ShowAdvancedItemsPanel()
    AdvancedItemsModule:ShowAdvancedItemsPanel()
end

function TrinityAdmin_ShowModuleCharacterPanel()
    ModuleCharacterModule:ShowModuleCharacterPanel()
end

function TrinityAdmin_ShowWaypointsPanel()
    WaypointsModule:ShowWaypointsPanel()
end

function TrinityAdmin_ShowAhBotPanel()
    AhBotModule:ShowAhBotPanel()
end

function TrinityAdmin_ShowGuildPanel()
    GuildModule:ShowGuildPanel()
end

function TrinityAdmin_ShowLearnDamagePanel()
    LearnDamageModule:ShowLearnDamagePanel()
end

function TrinityAdmin_ShowAdvancedGobPanel()
    AdvancedGobModule:ShowAdvancedGobPanel()
end

function TrinityAdmin_ShowAdvancedNpcPanel()
    AdvancedNpcModule:ShowAdvancedNpcPanel()
end

function TrinityAdmin_ShowMiscPanel()
    MiscModule:ShowMiscPanel()
end

function TrinityAdmin_ShowcheatPanel()
    cheatModule:ShowcheatPanel()
end

function TrinityAdmin_ShowDebugPanel()
    DebugModule:ShowDebugPanel()
end

function TrinityAdmin_ShowOthersPanel()
    OthersModule:ShowOthersPanel()
end
function TrinityAdmin_ShowTicketsPanel()
    TicketsModule:ShowTicketsPanel()
end
------------------------------------------------------------
-- Fonctions d'initialisation
------------------------------------------------------------
function TrinityAdmin:OnInitialize()
    self:Print("Welcome to TrinityCore GM Tools By TheWarlock : http://www.leeroylegacy.online")
    self:RegisterChatCommand("trinityadmin", "ToggleUI")
    self.gmFlyOn = false
end

function TrinityAdmin:OnEnable()
    TrinityAdminMainFrameTitle:SetText(TrinityAdmin_Translations["TrinityAdmin Main Menu"])
	-- Rendre la frame principale déplaçable
    TrinityAdminMainFrame:SetMovable(true)
    TrinityAdminMainFrame:EnableMouse(true)
    TrinityAdminMainFrame:RegisterForDrag("LeftButton")
    TrinityAdminMainFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    TrinityAdminMainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    
    -- Rendre la frame redimensionnable
    -- TrinityAdminMainFrame:SetResizable(true)
    -- 
    -- -- Créez un "handle" dans le coin inférieur droit pour le redimensionnement
    -- local resizeButton = CreateFrame("Frame", "TrinityAdminMainFrameResizeButton", TrinityAdminMainFrame)
    -- resizeButton:SetSize(16, 16)
    -- resizeButton:SetPoint("BOTTOMRIGHT", TrinityAdminMainFrame, "BOTTOMRIGHT", 0, 0)
    -- resizeButton:EnableMouse(true)
    -- resizeButton:SetScript("OnMouseDown", function(self, button)
    --     TrinityAdminMainFrame:StartSizing("BOTTOMRIGHT")
    -- end)
    -- resizeButton:SetScript("OnMouseUp", function(self, button)
    --     TrinityAdminMainFrame:StopMovingOrSizing()
    -- end)
    -- 
    -- -- Ajoutez une texture pour visualiser le handle (optionnel)
    -- local resizeTex = resizeButton:CreateTexture(nil, "OVERLAY")
    -- resizeTex:SetAllPoints()
    -- resizeTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
end

function TrinityAdmin:OnDisable()
    self:Print("TrinityAdmin Fermé")
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
	if DatabaseModule.panel then DatabaseModule.panel:Hide() end
	if ServerAdminModule.panel then ServerAdminModule.panel:Hide() end
    if GameObjectsModule.panel then GameObjectsModule.panel:Hide() end
    if AddItemModule.panel then AddItemModule.panel:Hide() end
	if AdvancedItemsModule.panel then AdvancedItemsModule.panel:Hide() end
	if ModuleCharacterModule.panel then ModuleCharacterModule.panel:Hide() end
	if WaypointsModule.panel then WaypointsModule.panel:Hide() end
	if AhBotModule.panel then AhBotModule.panel:Hide() end
	if GuildModule.panel then GuildModule.panel:Hide() end
	if LearnDamageModule.panel then LearnDamageModule.panel:Hide() end
	if AdvancedGobModule.panel then AdvancedGobModule.panel:Hide() end
	if AdvancedNpcModule.panel then AdvancedNpcModule.panel:Hide() end
	if MiscModule.panel then MiscModule.panel:Hide() end
	if cheatModule.panel then cheatModule.panel:Hide() end
	if DebugModule.panel then DebugModule.panel:Hide() end
	if OthersModule.panel then OthersModule.panel:Hide() end
    if TicketsModule.panel then TicketsModule.panel:Hide() end		
	
	

    TrinityAdminMainFrameTeleportButton:Show()
    TrinityAdminMainFrameGMButton:Show()
    TrinityAdminMainFrameNPCButton:Show()
    TrinityAdminMainFrameGMFunctionsButton:Show()
    TrinityAdminMainFrameAccountButton:Show()
	TrinityAdminMainFrameDatabaseButton:Show()
	TrinityAdminMainFrameServerAdminButton:Show()
    TrinityAdminMainFrameGameObjectsButton:Show()
    TrinityAdminMainFrameAddItemButton:Show()
	TrinityAdminMainFrameAdvancedItemsButton:Show()
	TrinityAdminMainFrameModuleCharacterButton:Show()
	TrinityAdminMainFrameWaypointsButton:Show()
	TrinityAdminMainFrameAhBotButton:Show()
	TrinityAdminMainFrameGuildButton:Show()
	TrinityAdminMainFrameLearnDamageButton:Show()
	TrinityAdminMainFrameAdvancedGobButton:Show()
	TrinityAdminMainFrameAdvancedNpcButton:Show()
	TrinityAdminMainFrameMiscButton:Show()
	TrinityAdminMainFramecheatButton:Show()
	TrinityAdminMainFrameDebugButton:Show()
	TrinityAdminMainFrameOthersButton:Show()
    TrinityAdminMainFrameTicketsButton:Show()	
	

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
	TrinityAdminMainFrameDatabaseButton:Hide()
	TrinityAdminMainFrameServerAdminButton:Hide()
    TrinityAdminMainFrameGameObjectsButton:Hide()
    TrinityAdminMainFrameAddItemButton:Hide()
	TrinityAdminMainFrameAdvancedItemsButton:Hide()
	TrinityAdminMainFrameModuleCharacterButton:Hide()
	TrinityAdminMainFrameWaypointsButton:Hide()
	TrinityAdminMainFrameAhBotButton:Hide()
	TrinityAdminMainFrameGuildButton:Hide()
	TrinityAdminMainFrameLearnDamageButton:Hide()
	TrinityAdminMainFrameAdvancedGobButton:Hide()
	TrinityAdminMainFrameAdvancedNpcButton:Hide()
	TrinityAdminMainFrameMiscButton:Hide()
	TrinityAdminMainFramecheatButton:Hide()
	TrinityAdminMainFrameDebugButton:Hide()
	TrinityAdminMainFrameOthersButton:Hide()	
	TrinityAdminMainFrameTicketsButton:Hide()
	
	
	
    TrinityAdminMainFrame:Show()
end


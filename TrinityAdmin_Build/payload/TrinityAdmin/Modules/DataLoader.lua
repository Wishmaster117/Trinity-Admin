local addonName, TA = ...

------------------------------------------------------------
-- Utilitaires partagés
------------------------------------------------------------
function TA.RemoveAccents(str)
    local a = { ["à"]="a",["â"]="a",["ä"]="a",["é"]="e",["è"]="e",
                ["ê"]="e",["ë"]="e",["î"]="i",["ï"]="i",["ô"]="o",
                ["ö"]="o",["ù"]="u",["û"]="u",["ü"]="u",["ç"]="c" }
    return (str:gsub("[%z\1-\127\194-\244][\128-\191]*",
                     function(c) return a[c] or c end))
end

local function MergeInto(dst, src)
    if #src > 0 then               -- tableau indexé
        local n = #dst
        for i = 1, #src do dst[n+i] = src[i] end
    else                            -- table associative
        for k, v in pairs(src) do dst[k] = v end
    end
end
TA.MergeInto = MergeInto

------------------------------------------------------------
-- Table des chunks
------------------------------------------------------------
local CHUNKS = {
    Items1   = "Datas/ItemsDataPart1.lua",   -- PRÉ-CHARGÉS via XML
    Items2   = "Datas/ItemsDataPart2.lua",
    Items3   = "Datas/ItemsDataPart3.lua",

    NPC1     = "Datas/NpcDataPart1.lua",     -- ► choisissez : XML   ou   sous-addon LoD
    NPC2     = "Datas/NpcDataPart2.lua",
    NPC3     = "Datas/NpcDataPart3.lua",
    NPC4     = "Datas/NpcDataPart4.lua",
    NPC5     = "Datas/NpcDataPart5.lua",
    NPC6     = "Datas/NpcDataPart6.lua",
    NPC7     = "Datas/NpcDataPart7.lua",

    GOB      = "Datas/GameObjectsData.lua",
    ItemSets = "Datas/ItemSetData.lua",
    Skills   = "Datas/SkillsData.lua",
    Teleport = "Datas/TeleportTable.lua",
    Titles   = "Datas/TitlesData.lua",
}

-- chunks qui sont *déjà* exécutés parce qu’ils figurent dans Datas/Includes.xml
local PRELOADED = {
    Items1 = true, Items2 = true, Items3 = true, NPC1 = true, NPC2 = true, NPC3 = true, NPC4 = true, NPC5 = true, NPC6 = true, NPC7 = true, GOB = true, ItemSets = true, Skills = true, Teleport = true, Titles = true,
}

------------------------------------------------------------
-- Chargeur
------------------------------------------------------------
local loaded = {}

function TA:LoadDataChunk(name)
    if loaded[name] or PRELOADED[name] then return end

    local path = CHUNKS[name]
    if not path then   error("Unknown chunk "..tostring(name), 2) end

    -- ►  Option 1 : vous avez laissé le fichier dans Includes.xml  → déjà exécuté
    -- ►  Option 2 : vous avez créé un sous-addon LoD appelé exactement “NPC1”, etc.
    local ok = IsAddOnLoaded(name) or select(2, pcall(LoadAddOn, name))
    if not ok then
        error(("Chunk '%s' n’est ni pré-chargé ni disponible en LoadOnDemand."):format(name), 2)
    end
    loaded[name] = true
end
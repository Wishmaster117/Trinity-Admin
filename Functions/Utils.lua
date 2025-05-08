-- Functions/Utils.lua
local LibStub = _G.LibStub
local C_Timer = _G.C_Timer

-- FontString unique pour mesurer le texte
local measuringFS = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
measuringFS:Hide()

local function AutoSize(frame, hPadding, vPadding, fontObject)
    hPadding = hPadding or 20
    vPadding = vPadding or 6

    local text = ""
    if frame:IsObjectType("Button") then
        text = frame:GetText() or ""
    elseif frame:IsObjectType("EditBox") then
        text = frame:GetText() or ""
    else
        return
    end

    measuringFS:SetFontObject(fontObject or "GameFontNormal")
    measuringFS:SetText(text)

    local w = measuringFS:GetStringWidth() + hPadding
    local h = measuringFS:GetStringHeight() + vPadding

    frame:SetWidth(w)
    if frame.SetHeight then
        frame:SetHeight(h)
    end

    -- **Spécifique aux EditBox “InputBoxTemplate”** :
    -- on étire aussi leurs textures bordure/fond
    if frame.Left and frame.Middle and frame.Right then
        frame.Left:SetHeight(h)
        frame.Middle:SetHeight(h)
        frame.Right:SetHeight(h)
    end
end

-- Injection dans l’addon (inchangé)
local function Inject()
    local ok, TrinityAdmin = pcall(function()
        return LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
    end)
    if ok and TrinityAdmin then
        TrinityAdmin.AutoSize = AutoSize
    end
end

Inject()
C_Timer.After(0.1, Inject)


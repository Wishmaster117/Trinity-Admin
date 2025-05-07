local TrinityAdmin = LibStub("AceAddon-3.0"):GetAddon("TrinityAdmin")
local UIFuncs = TrinityAdmin:NewModule("UIFuncs")  -- crée un sous-module nommé "UIFuncs"

function UIFuncs:AutoSizeButton(button, padding)
  padding = padding or 20
  local fs = button:GetFontString()
  fs:SetText(button:GetText() or "")
  button:SetWidth(fs:GetStringWidth() + padding)
end

function UIFuncs:AutoSizeEditBox(editBox, padding)
  padding = padding or 10
  -- idem, avec un FontString caché
  if not editBox.__measureFS then
    local fs = editBox:CreateFontString(nil, "OVERLAY")
    fs:SetFontObject(editBox:GetFontObject())
    fs:Hide()
    editBox.__measureFS = fs
  end
  local fs = editBox.__measureFS
  fs:SetText(editBox:GetText() or "")
  editBox:SetWidth(fs:GetStringWidth() + padding)
end
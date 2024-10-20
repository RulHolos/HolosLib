---@class UI.MenuSE
local M = {}
MenuSE = M

function M.LoadResources()
end

function M.PlayOpenMenu()
    lstg.PlaySound("se_general_menu", 1.0, 0.0)
end

---@param v number?
function M.PlaySelectWidget(v)
    lstg.PlaySound("se_general_select", v or 1.0, 0.0)
end

function M.PlayConfirm()
    lstg.PlaySound("se_general_confirm", 1.0, 0.0)
end

function M.PlayCancel()
    lstg.PlaySound("se_general_cancel", 1.0, 0.0)
end
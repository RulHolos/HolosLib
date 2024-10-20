---@class UI.Menu.SelectGameMode : UI.Object.ViewBase
local M = {}
UISelectGameMode = M

local function createWidget(mode, callback)
    ---@class ui.menu.SelectGameMode.Widget
    local v = {
        mode = mode,
        image = "menu_game_mode_image_" .. mode,
        image_select = "menu_game_mode_image_select" .. mode,
        finish = false,
        disable = false,
        callback = callback,
    }
    return v
end

function M:init()
    
end

function M:frame()

end

function M:render()
    if self.alpha < 0.0001 then
        return
    end
end

function M:enter()
    ViewBase.enter(self)
end

function M:exit()
    ViewBase.exit(self)
end

---@nodiscard
function M.create()
    local v = UIBase.makeInstance(M)
    v:init()
    return v;
end
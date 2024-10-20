---@class UI.Menu.Logo : UI.Object.ViewBase
local M = {}
UILogo = M

function M:init()
    UIBase.loadImageFromFile(
        "menu_logo_layer_bottom",
        "resources/ui/menu/logo_layer_bottom.png",
        true
    )
    UIBase.loadImageFromFile(
        "menu_logo_layer_font",
        "resources/ui/menu/logo_layer_font.png",
        true
    )
    UIBase.loadImageFromFile(
        "menu_reimu",
        "resources/ui/menu/reimu.png",
        true
    )
    lstg.SetImageCenter("menu_reimu", 550, 500)
    ViewBase.init(self)
    self.layer = -1
    self.type_first_time = false
    self.logo_bottom_value = 1
    self.logo_font_value = 1
    self.reimu_value = 1
    self.reimu_rot = 0
    self.reimu_rot_v = 0
end

function M:frame()
    ViewBase.frame(self)
    self.reimu_rot_v = approach_step(self.reimu_rot_v, self.reimu_rot, 0.9)
end

function M:render()
    if self.alpha < 0.0001 then
        return
    end

    local scale = Screen.Height / 900
    local x, y = Screen.Width / 2, Screen.Height / 2

    local color_bottom = lstg.Color(255 * self.alpha * self.logo_bottom_value, 255, 255, 255)
    lstg.SetImageState("menu_logo_layer_bottom", "", color_bottom)
    local scale_offset = 1.2 - 0.2 * lstg.sin(90 * self.logo_bottom_value)
    lstg.Render("menu_logo_layer_bottom", x, y, 0, scale * scale_offset)

    if self.logo_font_value < 0.2 then
        local a = 255 * self.alpha * (10 / 2) * self.logo_font_value
        local color_font = lstg.Color(a, 255, 255, 255)
        lstg.SetImageState("menu_logo_layer_font", "", color_font)
    elseif self.logo_font_value < 0.4 then
        local k = (10 / 2) * (self.logo_font_value - 0.2)
        local c = 255 * k
        local color_font = lstg.Color(255 * self.alpha, c, c, c)
        lstg.SetImageState("menu_logo_layer_font", "add+alpha", color_font)
    else
        local k = (10 / 6) * (self.logo_font_value - 0.4)
        local c = 255 * (1 - k)
        local color_font = lstg.Color(255 * self.alpha, c, c, c)
        lstg.SetImageState("menu_logo_layer_font", "add+alpha", color_font)
    end
    lstg.Render("menu_logo_layer_font", x, y, 0, scale)

    local color_reimu = lstg.Color(255 * self.alpha * self.reimu_value, 255, 255, 255)
    lstg.SetImageState("menu_reimu", "", color_reimu)
    local reimu_x_offset = -64 + 64 * lstg.sin(90 * self.reimu_value)
    lstg.Render("menu_reimu", x + reimu_x_offset - 206 * scale, y + 67 * scale, self.reimu_rot_v, scale)
end

---@private
function M:initTypeFirstTime()
    self.logo_bottom_value = 0
    self.logo_font_value = 0
    self.reimu_value = 0
end

---@private
function M:initTypeNormal()
    self.logo_bottom_value = 1
    self.logo_font_value = 1
    self.reimu_value = 1
end

---@param b boolean
function M:SetTypeFirstTime(b)
    self.type_first_time = b
end

function M:GetTotalFrameOfFirstTimeEnter()
    return 60
end

function M:enter()
    if self.type_first_time then
        Task.New(self, function()
            self.alpha = 1
            self:initTypeFirstTime()
            
            for i = 1, 20 do
                self.logo_bottom_value = i / 20
                Task.Wait(1)
            end

            for i = 1, 20 do
                self.logo_font_value = i / 20
                Task.Wait(1)
            end
            
            for i = 1, 20 do
                self.reimu_value = i / 20
                Task.Wait(1)
            end
        end)
    else
        Task.New(self, function()
            self:initTypeNormal()
        end)
        ViewBase.enter(self)
    end
end

function M:exit()
    Task.New(self, function()
        self:initTypeNormal()
    end)
    ViewBase.exit(self)
end

---@nodiscard
function M.create()
    local v = UIBase.makeInstance(M)
    v:init()
    return v;
end
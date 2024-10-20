Include("lib/UI/title/Logo.lua")
Include("lib/UI/title/SelectGameMode.lua")

---@class UI.Menu.Main : UI.Object.ViewBase
local M = {}
UIMain = M

---@param image_index number
---@param disable boolean
---@param callback function
local function createWidget(image_index, disable, callback)
    ---@class UI.Menu.Main.Widget
    ---@field image_disable string
    ---@field image string
    ---@field image_select string
    ---@field enable boolean
    ---@field callback fun()
    ---@field shake_timer number
    ---@field select_timer number

    ---@class UI.Menu.Main.Widget
    local v = {
        image_disable = "menu_main_option_disable_" .. image_index,
        image = "menu_main_option_" .. image_index,
        image_select = "menu_main_option_select_" .. image_index,
        enable = not disable,
        callback = callback,
        shake_timer = 0,
        select_timer = 0,
    }
    return v
end

local function loadImages()
    lstg.LoadTexture("menu_main_option_new", "resources/ui/menu/main_option_new.png", true)
    for i = 0, 9 do
        local j = i + 1
        lstg.LoadImage("menu_main_option_disable_" .. j, "menu_main_option_new", 640, i * 60, 320, 64)
        lstg.LoadImage("menu_main_option_" .. j,         "menu_main_option_new", 320, i * 60, 320, 64)
        lstg.LoadImage("menu_main_option_select_"  .. j, "menu_main_option_new",   0, i * 60, 320, 64)
        lstg.SetImageCenter("menu_main_option_disable_" .. j, 14, 14)
        lstg.SetImageCenter("menu_main_option_"         .. j, 14, 14)
        lstg.SetImageCenter("menu_main_option_select_"  .. j, 14, 14)
    end
end

function M:init()
    loadImages()
    ViewBase.init(self)
    self.logo = UILogo.create()
    self.type_first_time = false

    local start_extra = createWidget(2, false, function()
        UIGlobal.start_mode = "start"

        ---@type UI.Menu.SelectGameMode
        local view = self.view_stack_manager:FindObject("UI.Menu.SelectGameMode")
        view:refresh("extra")
        self.view_stack_manager:PushView(view)
    end)
    if true then -- TODO : Replace by StageSystem.groups["Extra"]
        start_extra.enable = false
    end

    local start_practice = createWidget(3, false, function()
        -- start practice
        UIGlobal.start_mode = "practice"

        ---@type UI.Menu.SelectGameMode
        local view = self.view_stack_manager:FindObject("UI.Menu.SelectGameMode")
        view:refresh("practice")
        self.view_stack_manager:PushView(view)
    end)
    local start_boss_practice = createWidget(4, false, function()
        -- start scene practice

        UIGlobal.start_mode = "scene practice"

        ---@type UI.Menu.SelectGameMode
        local view = self.view_stack_manager:FindObject("UI.Menu.SelectGameMode")
        view:refresh("scene practice")
        self.view_stack_manager:PushView(view)
    end)

    ---@private
    ---@type UI.Menu.Main.Widget[]
    self.widgets = {
        createWidget(1, false, function()
            -- start main

            UIGlobal.start_mode = "start"

            ---@type UI.Menu.SelectGameMode
            local view = self.view_stack_manager:FindObject("UI.Menu.SelectGameMode")
            view:refresh("start")
            self.view_stack_manager:PushView(view)
        end),
        start_extra,
        start_practice,
        start_boss_practice,
        createWidget(5, false, function()
            -- start replay
            UIGlobal.start_mode = "replay"
            local view = self.view_stack_manager:FindObject("UI.Menu.ReplayList")
            view:refresh("load")
            self.view_stack_manager:PushView(view)
        end),
        createWidget(8, false, function()
            ---@type UI.Menu.Settings
            local view = self.view_stack_manager:FindObject("UI.Menu.Settings")
            view:refresh()
            self.view_stack_manager:PushView(view)
        end),
        createWidget(9, false, function()
            ---@type UI.Menu.Manual
            local view = self.view_stack_manager:FindObject("UI.Menu.Manual")
            self.view_stack_manager:PushView(view)
        end),
        createWidget(10, false, function()
            -- Quit
            self.view_stack_manager:PopView("enter")
            ---@type UI.Menu.Background
            local view = self.view_stack_manager:FindObject("Ui.Menu.Background")
            if view then
                view:exit()
            end
            Task.New(self, function()
                Task.Wait(UIConfig.FadeOutFrames)
                lstg.quit_flag = true
            end)
        end)
    }
    self.widgets_index = 1
    self.widgets_offset_list = {
        18,
        0,
        2,
        26,
        70,
        110,
        132,
        152,
        174,
        214,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    }
end

function M:frame()
    ViewBase.frame(self)
    self.logo:frame()
    for _, v in ipairs(self.widgets) do
        v.shake_timer = math.max(0, v.shake_timer - 0.1)
    end
    if not self.lock then
        if Input.IsKeyPressed("Up") then
            self.widgets_index = UIBase.navigateToPrevious(self.widgets_index, 1, self.widgets, function(widget) return widget.enable end)
            self.widgets[self.widgets_index].shake_timer = 1
            --MenuSE.PlaySelectWidget()
        elseif Input.IsKeyPressed("Down") then
            self.widgets_index = UIBase.navigateToNext(self.widgets_index, 1, self.widgets, function(widget) return widget.enable end)
            self.widgets[self.widgets_index].shake_timer = 1
            --MenuSE.PlaySelectWidget()
        elseif Input.IsKeyPressed("Shoot") then
            if self.widgets[self.widgets_index] then
                self.widgets[self.widgets_index].callback()
                --MenuSE.PlayConfirm()
            end
        elseif Input.IsKeyPressed("Spell") then
            if self.widgets_index ~= #self.widgets then
                self.widgets_index = #self.widgets
                --MenuSE.PlayCancel()
            else
                if self.widgets[self.widgets_index] then
                    self.widgets[self.widgets_index].callback()
                    --MenuSE.PlayCancel()
                end
            end
        end
    end
    for i, v in ipairs(self.widgets) do
        v.select_timer = balance(
            v.select_timer,
            0, 1, 1 / 4,
            i == self.widgets_index
        )
    end
end

function M:render()
    self.logo:render()

    if self.alpha < 0.0001 then
        return
    end

    local scale = Screen.Height / 1134
    local x, y = 77 * scale, 634 * scale
    local dx = -16 + 16 * lstg.sin(90 * self.alpha)
    local dx_list = self.widgets_offset_list

    local color = lstg.Color(255 * self.alpha, 255, 255, 255)
    for i, v in ipairs(self.widgets) do
        local shake_dy = lstg.sin(self.timer * 89) * v.shake_timer
        local widget_y = y + shake_dy - (i - 1) * scale * 47
        local w_x = x + dx + scale * dx_list[i]
        if v.enable then
            color.a = 255 * self.alpha * (1 - v.select_timer)
            lstg.SetImageState(v.image, "", color)
            lstg.Render(v.image, w_x, widget_y, 0, scale)
            color.a = 255 * self.alpha * v.select_timer
            lstg.SetImageState(v.image_select, "", color)
            lstg.Render(v.image_select, w_x, widget_y, 0, scale)
        else
            color.a = 255 * self.alpha
            lstg.SetImageState(v.image_disable, "", color)
            lstg.Render(v.image_disable, w_x, widget_y, 0, scale)
        end
    end
end

function M:enter()
    if self.type_first_time then
        self.logo:SetTypeFirstTime(true)
        self.logo:enter()
        self.logo:SetTypeFirstTime(false)
        Task.New(self, function()
            Task.Wait(self.logo:GetTotalFrameOfFirstTimeEnter())
            ViewBase.enter(self)
        end)
    else
        self.logo:enter()
        ViewBase.enter(self)
    end
end

function M:exit()
    self.logo:exit()
    ViewBase.exit(self)
end

function M:SetTypeFirstTime(b)
    self.type_first_time = b
end

function M:GetTotalFrameOfFirstTimeEnter()
    return self.logo:GetTotalFrameOfFirstTimeEnter() + UIConfig.FadeInFrames
end

---@nodiscard
function M.create()
    local v = UIBase.makeInstance(M)
    v:init()
    return v;
end
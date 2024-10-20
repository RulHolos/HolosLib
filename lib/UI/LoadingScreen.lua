Include("lib/UI/View.lua")
Include("lib/UI/title.lua")

---@class UI.Scene.Loading : StageSystem.Stage
local loading_scene = StageSystem.New("loading", true, true)

local function loadImageFromFile(name, file)
    lstg.LoadTexture(name, file, true)
    local w, h = lstg.GetTextureSize(name)
    lstg.LoadImage(name, name, 0, 0, w, h)
end

function loading_scene:init()
    self.Showing = false

    if UIConfig.DisableLoadingScene then
        StageSystem.Set("title")
        return
    end

    loadImageFromFile("loading_background_layer_bottom", "resources/ui/loading/background_layer_bottom.png")
    loadImageFromFile("loading_background_layer_center", "resources/ui/loading/background_layer_center.png")
    loadImageFromFile("loading_background_layer_mesh", "resources/ui/loading/background_layer_mesh.png")
    loadImageFromFile("loading_background_layer_top", "resources/ui/loading/background_layer_top.png")

    lstg.CreateRenderTarget("loading_background_layer_mesh_composition")
    lstg.CreateRenderTarget("loading_background_layer_mask")

    lstg.LoadTexture("loading_image", "resources/ui/loading/image.png", true)
    lstg.LoadImage("loading_image_tree", "loading_image", 0,   0, 380, 220)
    lstg.LoadImage("loading_image_font", "loading_image", 0, 220, 380, 220)
    lstg.SetImageCenter("loading_image_tree", 380, 220) -- 右下角为图片中心
    lstg.SetImageCenter("loading_image_font", 380, 220)

    self.Showing = true
    self.bg_w = 1512 -- 美工给的 psd 文件像素尺寸
    self.bg_h = 1134
    self.bg_a = 0
    self.mesh_w = 363 -- 六边形网格贴图
    self.mesh_h = 290

    Task.New(self, function()
        -- 淡入
        for i = 1, 60 do
            self.bg_a = i / 60
            Task.Wait(1)
        end
        -- 加载过程
        Task.Wait(UIConfig.WaitOnLoading)
        -- 淡出
        for i = 1, 60 do
            self.bg_a = 1 - i / 60
            Task.Wait(1)
        end
        -- 切换到主菜单
        StageSystem.Set("title")
    end)
end

function loading_scene:render()
    if not self.Showing then
        return
    end

    SetViewMode("ui")

    local scale = 480 / self.bg_h

    local channel = self.bg_a * 255
    local color_dark = lstg.Color(255, channel, channel, channel)

    -- 六边形网格

    lstg.PushRenderTarget("loading_background_layer_mesh_composition")
    lstg.RenderClear(lstg.Color(0))
    local mesh_w = self.mesh_w * scale
    local mesh_h = self.mesh_h * scale
    local count_x = math.ceil(Screen.Width / mesh_w)
    local count_y = math.ceil(Screen.Height / mesh_h)
    local start_x = Screen.Width / 2 - (mesh_w * (count_x - 1)) / 2
    local start_y = Screen.Height / 2 - (mesh_h * (count_y + 1)) / 2 + (self.timer / 2) % mesh_h
    lstg.SetImageState("loading_background_layer_mesh", "", color_dark)
    for j = 1, (count_y + 1) do
        for i = 1, count_x do
            lstg.Render("loading_background_layer_mesh",
                start_x + (i - 1) * mesh_w,
                start_y + (j - 1) * mesh_h,
                0,
                scale
            )
        end
    end
    lstg.PopRenderTarget() -- "loading_background_layer_mesh_composition"

    -- 遮罩

    lstg.PushRenderTarget("loading_background_layer_mask")
    lstg.RenderClear(lstg.Color(0))
    lstg.SetImageState("loading_background_layer_center", "add+alpha", lstg.Color(255, 255, 255, 255))
    lstg.Render("loading_background_layer_center", Screen.Width / 2, Screen.Height / 2, 0, scale)
    lstg.PopRenderTarget() -- "loading_background_layer_mask"

    -- 组合为背景

    lstg.SetImageState("loading_background_layer_bottom", "", color_dark)
    lstg.SetImageState("loading_background_layer_center", "", color_dark)
    lstg.SetImageState("loading_background_layer_top", "", color_dark)
    lstg.Render("loading_background_layer_bottom", Screen.Width / 2, Screen.Height / 2, 0, scale)
    lstg.Render("loading_background_layer_center", Screen.Width / 2, Screen.Height / 2, 0, scale)
    PostEffect.DrawMaskEffect("loading_background_layer_mesh_composition", "loading_background_layer_mask")
    lstg.Render("loading_background_layer_top", Screen.Width / 2, Screen.Height / 2, 0, scale)

    -- 少女祈祷中

    local width = scale * 380 -- 树和加载文本向右挪
    local dx = width - width * lstg.sin(self.bg_a * 90)
    local color_alpha = lstg.Color(channel, 255, 255, 255)
    lstg.SetImageState("loading_image_tree", "", color_alpha)
    local chanel_flash = 191 + 64 * lstg.sin(self.timer * 8)
    local color_flash = lstg.Color(channel, chanel_flash, chanel_flash, chanel_flash)
    lstg.SetImageState("loading_image_font", "", color_flash)
    lstg.Render("loading_image_tree", Screen.Width + dx, 0, 0, scale)
    lstg.Render("loading_image_font", Screen.Width + dx, 0, 0, scale)

    SetViewMode("world")
end
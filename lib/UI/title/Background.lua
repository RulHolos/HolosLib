local random = require("random")

---@class UI.Menu.Background : UI.Object.ViewBase
local M = {}
UIBackground = M

local function loadResources()
    UIBase.loadImageFromFile(
        "menu_background_layer_bottom",
        "resources/ui/menu/background_layer_bottom.png",
        true
    )
    UIBase.loadImageFromFile(
        "menu_background_layer_center",
        "resources/ui/menu/background_layer_center.png",
        true
    )

    lstg.LoadImage(
        "menu_background_layer_center_top",
        "menu_background_layer_center",
        93, 0, 1326, 160
    )
    lstg.SetImageCenter("menu_background_layer_center_top", 1326 / 2, 0)
    lstg.LoadImage(
        "menu_background_layer_center_bottom",
        "menu_background_layer_center",
        93, 974, 1326, 160
    )
    lstg.SetImageCenter("menu_background_layer_center_bottom", 1326 / 2, 160)

    lstg.LoadTexture(
        "ui_general_particles",
        "resources/ui/general/particles.png",
        true
    )
    lstg.LoadImage("ui_general_particles_1", "ui_general_particles", 0, 0, 128, 128)
    lstg.LoadImage("ui_general_particles_2", "ui_general_particles", 128, 0, 64, 64)
end

local function unloadResources()
    UIBase.unloadImage("ui_general_particles_1")
    UIBase.unloadImage("ui_general_particles_2")

    UIBase.unloadTexture("ui_general_particles")

    UIBase.unloadImage("menu_background_layer_center_top")
    UIBase.unloadImage("menu_background_layer_center_bottom")

    UIBase.unloadImageFromFile("menu_background_layer_bottom")
    UIBase.unloadImageFromFile("menu_background_layer_center")
end

---@class UI.Menu.Background.ParticleSystem
local ParticleSystem = {}
function ParticleSystem:init()
    ---@type UI.Menu.Background.ParticleSystem.ParticleInstance[]
    self.list = {}
    self.rng = random.pcg32_fast()
    self.images = {
        "ui_general_particles_1",
        "ui_general_particles_2"
    }
    self.timer = -1
end
function ParticleSystem:frame()
    local rng = self.rng
    self.timer = self.timer + 1
    for i = #self.list, 1, -1 do
        if self.list[i].y < 0 then
            table.remove(self.list, i)
        else
            self.list[i].timer = self.list[i].timer + 1
        end
    end
    if self.timer % 6 == 0 then
        for _ = 1, 1 do
            local type = rng:integer(1, 10)
            if type <= 4 then
                type = 1
            else
                type = 2
            end
            local scale = rng:number(0.3, 0.5)
            ---@class UI.Menu.Background.ParticleSystem.ParticleInstance
            local p = {
                timer = 0,
                type = type,

                x = rng:number(-64, Screen.Width),
                y = Screen.Height,
                
                rot = rng:number(0, 360),
                hscale0 = scale,
                vscale0 = scale,
                hscale = scale,
                vscale = scale,
                image = self.images[type],
                alpha = 0,

                spin = rng:sign() * rng:number(0.5, 2),
                speed_a = -80 + rng:number(-4, 4),
                speed_v = rng:number(1, 2),
                hspin_v = 90,
                hspin_t = 0
            }
            if type == 1 then
                local rate = rng:integer(1, 10)
                if rate <= 2 then
                    p.hspin_v = rng:number(0, 360)
                    p.hspin_t = rng:sign() * rng:number(2, 4)
                end
            end
            table.insert(self.list, p)
        end
    end
    for _, p in ipairs(self.list) do
        p.rot = p.rot + p.spin
        local vx, vy = p.speed_v * lstg.cos(p.speed_a), p.speed_v * lstg.sin(p.speed_a)
        p.x = p.x + vx
        p.y = p.y + vy
        p.alpha = 0.2 * normalize(p.y, 0, 64, Screen.Height - 64, Screen.Height)
        p.hscale = p.hscale0 * lstg.sin(p.hspin_v)
        p.hspin_v = p.hspin_v + p.hspin_t
    end
end
function ParticleSystem:render(alpha)
    local color = Color(255, 255, 255, 255)
    for _, p in ipairs(self.list) do
        color.a = alpha * p.alpha * 255
        lstg.SetImageState(p.image, "mul+add", color)
        lstg.Render(p.image, p.x, p.y, p.rot, p.hscale, p.vscale)
    end
end
function ParticleSystem.create()
    local v = UIBase.makeInstance(ParticleSystem)
    v:init()
    return v
end

function M:init()
    ViewBase.init(self)
    self.layer = -1000
    self.particle_system = ParticleSystem.create()
end
function M:frame()
    ViewBase.frame(self)
    self.particle_system:frame()
end
function M:render()
    if self.alpha < 0.0001 then
        return
    end

    local scale = Screen.Height / 900
    local channel = self.alpha * 255
    local color_black = Color(255, channel, channel, channel)
    local color_alpha = Color(channel, 255, 255, 255)

    lstg.SetImageState("menu_background_layer_bottom", "", color_alpha)
    lstg.SetImageState("menu_background_layer_center_top", "", color_alpha)
    lstg.SetImageState("menu_background_layer_center_bottom", "", color_alpha)

    local x, y = Screen.Width / 2, Screen.Height / 2
    Render("menu_background_layer_bottom", x, y, 0, scale)

    local center_width = 1326 * scale
    local dx = (self.timer * 0.4) % center_width
    for i = -2, 1 do
        Render("menu_background_layer_center_top", x + center_width * i + dx, Screen.Height, 0, scale)
    end
    for i = -1, 2 do
        Render("menu_background_layer_center_bottom", x + center_width * i - dx, 0, 0, scale)
    end

    self.particle_system:render(self.alpha)
end
function M:enter()
    loadResources()
    ViewBase.enter(self)
end
function M:exit()
    ViewBase.exit(self)
    Task.New(self, function()
        Task.Wait(UIConfig.FadeOutFrames + 1)
        unloadResources()
    end)
end

---@nodiscard
function M.create()
    local v = UIBase.makeInstance(M)
    v:init()
    return v
end
---@class UI.Game.MusicNameDisplay
local MusicNameDisplay = {}

---@param name string
function MusicNameDisplay:init(name)
    self.layer = LAYER_TOP - 1
    self.music_name = "♪ " .. i18n.localize("music." .. name .. ".name")
    self.alpha = 0
    self.y_offset = -24
    
    Task.New(self, function()
        for i = 1, 60 do
            local k = i / 60
            self.alpha = k
            self.y_offset = -24 + 24 * sin(90 * k)
            Task.Wait(1)
        end
        Task.Wait(120)
        for i = 1, 60 do
            local k = i / 60
            self.alpha = 1 - k
            Task.Wait(1)
        end
        self.alpha = 0
        Del(self)
    end)
end

function MusicNameDisplay:render()
    -- TODO: Draw text
end

Audio.AddMusicEventListener("UI.Game.MusicNameDisplay", "play", function(name)
    if StageSystem.current_stage and (not StageSystem.current_stage.is_menu) then
        New(MusicNameDisplay, name)
    end
end)

return MusicNameDisplay
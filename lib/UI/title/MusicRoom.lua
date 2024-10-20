---@class UI.Menu.MusicRoom : UI.Object.ViewBase
local M = {}
UIMusicRoom = M

---@param index number
---@param callback function
local function createWidget(index, callback)
    ---@class UI.Menu.MusicRoom.Widget
    ---@field index number
    ---@field music_id string
    ---@field disable boolean
    ---@field callback fun()

    ---@type UI.Menu.MusicRoom.Widget
    local v = {
        index = index,
        music_id = "",
        disable = false,
        callback = callback,
    }
    return v
end

function M:init()
    UIBase.loadImageFromFile(
        "menu_music_room_background",
        "assets/ui/menu/music_room_background.png",
        true
    )
    ViewBase.init(self)

    ---@type UI.Menu.MusicRoom.Widget[]
    self.widgets = {}
    self.widgets_index = 1
    self.widgets_index_value = 1
    self.widgets_index_2 = 0
    self.widgets_index_value_2 = 0
    self.comment_index_last = 0
    self.comment_index_next = 0
    self.comment_image_value = 0

    self.navigate_to_previous_widget = function()
        if #self.widgets < 1 then
            self.widgets_index = 1
            return
        end
        self.widgets_index = clamp(self.widgets_index, 1, #self.widgets)
        for i = (self.widgets_index - 1), 1, -1 do
            self.widgets_index = i
            return
        end
        for i = #self.widgets, (self.widgets_index + 1), -1 do
            self.widgets_index = i
            return
        end
    end
    self.navigate_to_next_widget = function()
        if #self.widgets < 1 then
            self.widgets_index = 1
            return
        end
        self.widgets_index = clamp(self.widgets_index, 1, #self.widgets)
        for i = (self.widgets_index + 1), #self.widgets do
            self.widgets_index = i
            return
        end
        for i = 1, (self.widgets_index - 1) do
            self.widgets_index = i
            return
        end
    end
    self.update_comment = function()
        self.comment_image_value = 0
        self.comment_index_last = self.comment_index_next
        local index = self.widgets_index
        if self.widgets[self.widgets_index].disable then
            index = 0
        end
        self.comment_index_next = index
    end

    self:refresh()
end

function M:refresh()
    
end
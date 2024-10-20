local patch = "lib/UI/"
Include(patch .. "Config.lua")
Include(patch .. "Base.lua")
Include(patch .. "MenuSE.lua")

---@class UI.Object
local M = {}

---@class UI.Object.Base
local Base = {}
M.Base = Base
function Base:init()
    self.layer = LAYER_TOP
    self.alpha = 0
    self.lock = true
end
function Base:frame()
    Task.Do(self)
end
function Base:render()
    
end

---@class UI.Object.Manager
local Manager = {}
ViewManager = Manager
function Manager:init()
    ---@private
    ---@type UI.Object.Base[]
    self.update_list = {}

    ---@private
    ---@type UI.Object.Base[]
    self.draw_list = {}

    ---@private
    self.is_update = false
    ---@private
    self.is_draw = false

    ---@private
    ---@type UI.Object.Base[]
    self.request_add_queue = {}

    ---@private
    ---@type UI.Object.Base[]
    self.request_remove_queue = {}
end
function Manager:frame()
    self.is_update = true

    for _, v in ipairs(self.update_list) do
        v:frame()
    end
    if #self.request_add_queue > 0 then
        for _, v in ipairs(self.request_add_queue) do
            table.insert(self.update_list, v)
            table.insert(self.draw_list, v)
        end
        table.sort(self.draw_list, function(a, b)
            return a.layer < b.layer
        end)
        ClearArray(self.request_remove_queue)
    end
    if #self.request_remove_queue > 0 then
        for _, v in ipairs(self.request_remove_queue) do
            RemoveItemInArray(self.update_list, v)
            RemoveItemInArray(self.draw_list, v)
        end
        ClearArray(self.request_remove_queue)
    end

    self.is_update = false
end
function Manager:render()
    SetViewMode("ui")
    self.is_render = true
    for _, v in ipairs(self.draw_list) do
        v:render()
    end
    self.is_render = false
    SetViewMode("world")
end
---@param v UI.Object.Base
function Manager:AddObject(v)
    assert(v ~= nil)
    assert(not self.is_render)
    if self.is_update then
        table.insert(self.request_add_queue, v)
    else
        table.insert(self.update_list, v)
        table.insert(self.draw_list, v)
        table.sort(self.draw_list, function(a, b)
            return a.layer < b.layer
        end)
    end
end
---@param v UI.Object.Base
function Manager:RemoveObject(v)
    assert(v ~= nil)
    assert(not self.is_render)
    if self.is_update then
        table.insert(self.request_remove_queue, v)
    else
        RemoveItemInArray(self.update_list, v)
        RemoveItemInArray(self.draw_list, v)
    end
end
function Manager.create()
    local v = UIBase.makeInstance(Manager)
    v:init()
    return v
end

---@class UI.Object.ViewBase : UI.Object.Base
local viewBase = {}
M.ViewBase = viewBase
ViewBase = viewBase
function viewBase:init()
    Base.init(self)
    self.alpha = 0
    self.lock = true
    self.timer = -1
    ---@type UI.Object.ViewStackManager
    self.view_stack_manager = nil
end
function viewBase:frame()
    self.timer = self.timer + 1
    Base.frame(self)
end
function viewBase:render()
    Base.render(self)
end
function viewBase:enter()
    Task.New(self, function()
        for i = 1, UIConfig.FadeInFrames do
            self.alpha = i / UIConfig.FadeInFrames
            Task.Wait(1)
        end
        self.lock = false
    end)
end
function viewBase:exit()
    Task.New(self, function()
        self.lock = true
        for i = (UIConfig.FadeInFrames - 1), 0, -1 do
            self.alpha = i / UIConfig.FadeInFrames
            Task.Wait(1)
        end
    end)
end

---@alias UI.Object.ViewStackManager.DiscardType '"enter"' | '"exit"' | '"both"'

---@class UI.Object.ViewStackManager : UI.Object.Manager
local viewStackManager = {}
M.ViewStackManager = viewStackManager
ViewStackManager = viewStackManager
function viewStackManager:init()
    ---@private
    ---@type table<string, UI.Object.ViewBase>
    self.view_collection = {}

    ---@private
    ---@type UI.Object.ViewBase[]
    self.update_list = {}

    ---@private
    ---@type UI.Object.ViewBase[]
    self.draw_list = {}

    ---@private
    self.is_update = false
    ---@private
    self.is_draw = false

    ---@private
    ---@type UI.Object.ViewBase[]
    self.request_add_queue = {}

    ---@private
    ---@type UI.Object.ViewBase[]
    self.request_remove_queue = {}

    ---@private
    ---@type UI.Object.ViewBase[]
    self.stack = {}
end
function viewStackManager:frame()
    Manager.frame(self)
end
function viewStackManager:render()
    Manager.render(self)
end
---@param v UI.Object.ViewBase
function viewStackManager:AddObject(v)
    Manager.AddObject(self, v)
    assert(v.view_stack_manager == nil)
    v.view_stack_manager = self
end
---@param v UI.Object.ViewBase
function viewStackManager:RemoveObject(v)
    if v._ViewStackManager_name then
        self.view_collection[v._ViewStackManager_name] = nil
        v._ViewStackManager_name = nil
    end
    v.view_stack_manager = nil
    Manager.RemoveObject(self, v)
end
---@param name string
---@param v UI.Object.ViewBase
function viewStackManager:AddObjectWithName(name, v)
    if self:FindObject(name) then
        self:RemoveObjectWithName(name)
    end
    self:AddObject(v)
    v._ViewStackManager_name = name
    self.view_collection[name] = v
end
---@param name string
function viewStackManager:RemoveObjectWithName(name)
    assert(self.view_collection[name])
    self:RemoveObject(self.view_collection[name])
end
---@generic T
---@param name string
---@return T
function viewStackManager:FindObject(name)
    return self.view_collection[name]
end
---@param v UI.Object.ViewBase
---@param discard_type UI.Object.ViewStackManager.DiscardType
---@overload fun(UI.Object.ViewStackManager:self, v:UI.Object.ViewBase)
function viewStackManager:PushView(v, discard_type)
    assert(v ~= nil)
    assert(not self.is_draw)
    -- 先插入，让栈处于 |...|要离开的视图A|要进入的视图B| 结构
    table.insert(self.stack, v)
    -- 现在对两个顶部视图同时执行动作
    -- 视图A 栈顶之下 离开
    -- 视图B 处于栈顶 进入
    local top_index = #self.stack
    if (top_index >= 2) then
        if discard_type ~= "both" and discard_type ~= "exit" then
            self.stack[top_index - 1]:exit()
        end
    end
    if (top_index >= 1) then
        if discard_type ~= "both" and discard_type ~= "enter" then
            self.stack[top_index]:enter()
        end
    end
end
---@param discard_type UI.Object.ViewStackManager.DiscardType
---@overload fun(UI.Object.ViewStackManager:self)
function viewStackManager:PopView(discard_type)
    assert(not self.is_draw)
    assert(#self.stack > 0)
    -- 当前栈处于 |...|要进入的视图A|要离开的视图B| 结构
    -- 先对两个顶部视图同时执行动作
    -- 视图A 栈顶之下 进入
    -- 视图B 处于栈顶 离开
    local top_index = #self.stack
    if (top_index >= 2) then
        if discard_type ~= "both" and discard_type ~= "enter" then
            self.stack[top_index - 1]:enter()
        end
    end
    if (top_index >= 1) then
        if discard_type ~= "both" and discard_type ~= "exit" then
            self.stack[top_index]:exit()
        end
    end
    table.remove(self.stack)
end
---@param v UI.Object.ViewBase
---@return boolean
function viewStackManager:IsViewAtStackTop(v)
    local top_index = #self.stack
    if top_index >= 1 then
        return self.stack[top_index] == v
    end
    return false
end
---@param v UI.Object.ViewBase
---@return boolean
function viewStackManager:IsViewUnderStackTop(v)
    -- 从栈顶向栈底查找，这样一般情况下能比较快地找到需要的
    local top_index_1 = (#self.stack) - 1
    for i = top_index_1, 1, -1 do
        if self.stack[i] == v then
            return true
        end
    end
    return false
end
---@return boolean
function viewStackManager:IsViewStackEmpty()
    return (#self.stack) == 0
end
function ViewStackManager.create()
    local v = UIBase.makeInstance(viewStackManager)
    v:init()
    return v
end
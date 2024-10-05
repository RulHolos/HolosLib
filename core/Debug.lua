---@class lstg.Debug
local M = {}

---@class lstg.Debug.View
local W = {}
function W:GetWindowName() return "View" end
function W:GetMenuGroupName() return "Tool" end
function W:GetEnabled() return self.Enabled end
---@param value boolean
function W:SetEnabled(value) self.Enabled = value end
function W:Update() end
function W:Layout() end

---@type lstg.Debug.ViewCollection.Item[]
local view_collection = {}

function M.AddView(id, view)
    local index = 0
    for i, v in ipairs(view_collection) do
        if v.id == id then
            index = i
            break
        end
    end

    ---@class lstg.Debug.ViewCollection.Item
    local t = {
        id = id,
        view = view
    }
    if index > 0 then
        view_collection[index] = t
    else
        table.insert(view_collection, t)
    end
end

---

local imgui_exists, imgui = pcall(require, "imgui")

---@param vkey number
---@return fun():boolean
function M.KeyDownTrigger(vkey)
    local _last_state = false
    local _state = false
    return function()
        _state = lstg.GetKeyState(vkey)
        if not _last_state and _state then
            _last_state = _state
            return true
        else
            _last_state = _state
            return false
        end
    end
end

local F1_trigger = M.KeyDownTrigger(KEY.F1)
local F3_trigger = M.KeyDownTrigger(KEY.F3)

local b_show_all = true
local b_show_menubar = false

local b_show_demo_window = false
local b_show_memuse_window = false
local b_show_framept_window = false
local b_show_testinput_window = false
local b_show_resmgr_window = false

---@param view lstg.Debug.View
local function layoutViewMenuItem(view)
    local enabled = view:GetEnabled()
    if imgui.ImGui.MenuItem(view:GetWindowName(), nil, enabled) then
        enabled = not enabled
    end
    view:SetEnabled(enabled)
end

---@param view lstg.Debug.View
local function layoutView(view)
    local enabled = view:GetEnabled()
    if not enabled then
        return
    end
    local ImGui = imgui.ImGui
    local show = false
    show, enabled = ImGui.Begin(view:GetWindowName(), enabled)
    view:SetEnabled(enabled)
    if show then
        view:Layout()
    end
    ImGui.End()
end

function M.Update()
    if imgui_exists then
        local flag = false
        if b_show_all then
            flag = flag or b_show_menubar
            flag = flag or b_show_demo_window
            flag = flag or b_show_memuse_window
            flag = flag or b_show_framept_window
            flag = flag or b_show_testinput_window
            flag = flag or b_show_resmgr_window
            for _, v in ipairs(view_collection) do
                flag = flag or v.view:GetEnabled()
            end
        end
        imgui.backend.NewFrame(flag)
        for _, v in ipairs(view_collection) do
            v.view:Update()
        end
    end
end

function M.Layout()
    if F1_trigger() then
        b_show_all = not b_show_all
    end
    if F3_trigger() then
        b_show_menubar = not b_show_menubar
    end
    if imgui_exists then
        imgui.ImGui.NewFrame()
        if b_show_all then
            if b_show_menubar then
                if imgui.ImGui.BeginMainMenuBar() then
                    if imgui.ImGui.BeginMenu("Game") then
                        for _, v in ipairs(view_collection) do
                            if v.view:getMenuGroupName() == "Game" then
                                layoutViewMenuItem(v.view)
                            end
                        end
                        imgui.ImGui.EndMenu()
                    end
                    if imgui.ImGui.BeginMenu("Tool") then
                        if imgui.ImGui.MenuItem("Memory Usage", nil, b_show_memuse_window) then b_show_memuse_window = not b_show_memuse_window end
                        if imgui.ImGui.MenuItem("Frame Statistics", nil, b_show_framept_window) then b_show_framept_window = not b_show_framept_window end
                        if imgui.ImGui.MenuItem("Test Input", nil, b_show_testinput_window) then b_show_testinput_window = not b_show_testinput_window end
                        if imgui.ImGui.MenuItem("Resource Manager", nil, b_show_resmgr_window) then b_show_resmgr_window = not b_show_resmgr_window end
                        if imgui.ImGui.MenuItem("Demo", nil, b_show_demo_window) then b_show_demo_window = not b_show_demo_window end
                        for _, v in ipairs(view_collection) do
                            if v.view:getMenuGroupName() == "Tool" then
                                layoutViewMenuItem(v.view)
                            end
                        end
                        imgui.ImGui.EndMenu()
                    end
                    imgui.ImGui.EndMainMenuBar()
                end
            end
            
            if b_show_demo_window then
                b_show_demo_window = imgui.ImGui.ShowDemoWindow(b_show_demo_window)
            end
            if b_show_memuse_window and imgui.backend.ShowMemoryUsageWindow then
                b_show_memuse_window = imgui.backend.ShowMemoryUsageWindow(b_show_memuse_window)
            end
            if b_show_framept_window and imgui.backend.ShowFrameStatistics then
                b_show_framept_window = imgui.backend.ShowFrameStatistics(b_show_framept_window)
            end

            if b_show_testinput_window and imgui.backend.ShowTestInputWindow then
                b_show_testinput_window = imgui.backend.ShowTestInputWindow(b_show_testinput_window)
            end

            if b_show_resmgr_window and imgui.backend.ShowResourceManagerDebugWindow then
                b_show_resmgr_window = imgui.backend.ShowResourceManagerDebugWindow(b_show_resmgr_window)
            end

            for _, v in ipairs(view_collection) do
                layoutView(v.view)
            end
        end
        imgui.ImGui.EndFrame()
    end
end

function M.Draw()
    if imgui_exists then
        if b_show_all then
            imgui.ImGui.Render()
            imgui.backend.RenderDrawData()
        end
    end
end

return M
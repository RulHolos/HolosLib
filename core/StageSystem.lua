---@generic T
---@param C T
---@return T
local function make_instance(C)
    local I = {}
    setmetatable(I, { __index = C })
    return I
end

--- StageSystem.Stage

---@class StageSystem.Stage
local S = {}

S.stage_name = "__default__"
S.is_menu = false

function S:init() end
function S:frame() end
function S:render() end
function S:del() end

--- StageSystem

---@class StageSystem
local M = {}

M.stages = {}
M.current_stage = S
M.next_stage = S
M.preserve_resources = false

---@param stage_name string
---@param is_entry_stage boolean
---@param is_menu boolean
---@return StageSystem.Stage
function M.New(stage_name, is_entry_stage, is_menu)
    assert(type(stage_name) == "string")
    assert(type(is_entry_stage) == "boolean" and type(is_menu) == "boolean")

    ---@type StageSystem.Stage
    local result = {
        init = S.init,
        frame = S.frame,
        render = S.render,
        del = S.del,
        stage_name = stage_name,
        is_menu = is_menu
    }
    M.stages[stage_name] = result
    if is_entry_stage then
        M.next_stage = result
    end
    return result
end

---@param stage_name string
function M.Set(stage_name)
    assert(type(stage_name) == "string")

    M.next_stage = M.stages[stage_name]
    assert(M.next_stage, "Stage doesn't exist with the specified name.")
end

function M.Change()
    M.DeleteCurrentStage()
    M.CreateNextStage()
end

function M.DeleteCurrentStage()
    M.current_stage:del()
    lstg.ResetPool()
    if M.preserve_resources then
        M.preserve_resources = false
    else
        lstg.RemoveResource("stage")
    end
end

function M.CreateNextStage()
    local next_stage = M.next_stage
    M.next_stage = nil
    assert(next_stage, "There is no next stage.")
    M.current_stage = make_instance(next_stage)
    M.current_stage.timer = 0
    M.current_stage:init()
end

function M.Update()
    Task.Do(M.current_stage)
    M.current_stage:frame()
    M.current_stage.timer = M.current_stage.timer + 1
end

--- init

M.stages[S.stage_name] = S
M.Set(S.stage_name)
M.Change()

--- global

StageSystem = M
return M
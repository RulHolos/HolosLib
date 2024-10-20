---@class UI.Base
local M = {}
UIBase = M

--- 实例化一个类  
--- 相当于创建一个新的 table 并设置类为其元表  
---@generic C
---@param class_type C
---@return C
function M.makeInstance(class_type)
    local instance = {}
    local metatable = { __index = class_type }
    setmetatable(instance, metatable)
    return instance
end

---@param name string
---@param file string
---@param mipmap boolean
---@return number
---@return number
function M.loadImageFromFile(name, file, mipmap)
    lstg.LoadTexture(name, file, mipmap)
    local w, h = lstg.GetTextureSize(name)
    lstg.LoadImage(name, name, 0, 0, w, h)
    return w, h
end

---@param name string
function M.unloadImageFromFile(name)
    -- 重复查找两次是因为可能全局和关卡资源池都有加载

    -- 先移除 sprite 
    local pool = lstg.CheckRes(2, name)
    if pool then
        lstg.RemoveResource(pool, 2, name)
    end
    pool = lstg.CheckRes(2, name)
    if pool then
        lstg.RemoveResource(pool, 2, name)
    end
    -- 然后是纹理
    pool = lstg.CheckRes(1, name)
    if pool then
        lstg.RemoveResource(pool, 1, name)
    end
    pool = lstg.CheckRes(1, name)
    if pool then
        lstg.RemoveResource(pool, 1, name)
    end
end

---@param name string
function M.unloadTexture(name)
    -- 重复查找两次是因为可能全局和关卡资源池都有加载
    local pool = lstg.CheckRes(1, name)
    if pool then
        lstg.RemoveResource(pool, 1, name)
    end
    pool = lstg.CheckRes(1, name)
    if pool then
        lstg.RemoveResource(pool, 1, name)
    end
end

---@param name string
function M.unloadImage(name)
    -- 重复查找两次是因为可能全局和关卡资源池都有加载
    local pool = lstg.CheckRes(2, name)
    if pool then
        lstg.RemoveResource(pool, 2, name)
    end
    pool = lstg.CheckRes(2, name)
    if pool then
        lstg.RemoveResource(pool, 2, name)
    end
end

---@generic T
---@param current_index number
---@param default_index number
---@param array T[] 
---@param is_enabled fun(value:T): boolean
function M.navigateToNext(current_index, default_index, array, is_enabled)
    assert(type(current_index) == "number")
    assert(type(default_index) == "number")
    assert(type(array) == "table")
    if is_enabled then
        assert(type(is_enabled) == "function")
    else
        is_enabled = function(_) return true end
    end
    -- 跳过空白列表
    if #array == 0 then
        return default_index
    end
    -- 首先规范化索引范围
    current_index = math.max(1, math.min(current_index, #array))
    -- 第一阶段查找，向下查找
    for i = (current_index + 1), #array do
        if is_enabled(array[i]) then
            return i
        end
    end
    -- 第二阶段查找，折返
    for i = 1, (current_index - 1) do
        if is_enabled(array[i]) then
            return i
        end
    end
    -- 索引没有变化
    return current_index
end

---@generic T
---@param current_index number
---@param default_index number
---@param array T[] 
---@param is_enabled fun(value:T): boolean
function M.navigateToPrevious(current_index, default_index, array, is_enabled)
    assert(type(current_index) == "number")
    assert(type(default_index) == "number")
    assert(type(array) == "table")
    if is_enabled then
        assert(type(is_enabled) == "function")
    else
        is_enabled = function(_) return true end
    end
    -- 跳过空白列表
    if #array == 0 then
        return default_index
    end
    -- 首先规范化索引范围
    current_index = math.max(1, math.min(current_index, #array))
    -- 第一阶段查找，向上查找
    for i = (current_index - 1), 1, -1 do
        if is_enabled(array[i]) then
            return i
        end
    end
    -- 第二阶段查找，折返
    for i = #array, (current_index + 1), -1 do
        if is_enabled(array[i]) then
            return i
        end
    end
    -- 索引没有变化
    return current_index
end

return M

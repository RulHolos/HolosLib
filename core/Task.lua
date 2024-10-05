---@class Task
Task = {}
Task.Stack = {}
Task.Coroutines = {}

---@generic T
---@param target T
---@param callback fun()
---@return thread
function Task.New(target, callback)
    if not target.Task then
        target.Task = {}
    end

    local rt = coroutine.create(callback)
    table.insert(target.Task, rt)
    return rt
end

---@generic T
---@param target T
function Task.Do(target)
    if target.Task then
        for _, co in pairs(target.Task) do
            if coroutine.status(co) ~= 'dead' then
                table.insert(Task.Stack, target)
                table.insert(Task.Coroutines, co)

                local flag, errmsg = coroutine.resume(co)
                if errmsg then
                    error(tostring(errmsg) .. "\n========== coroutine traceback ==========\n" .. debug.traceback(co) .. "\n========== C traceback ==========")
                end
                Task.Stack[#Task.Stack] = nil
                Task.Coroutines[#Task.Coroutines] = nil
            end
        end
    end
end

---@generic T
---@param target T
---@param keepself boolean
function Task.Clear(target, keepself)
    if keepself then
        local flag = false
        local co = Task.Coroutines[#Task.Coroutines]
        for i = 1, #target.Task do
            if target.Task[i] == co then
                flag = true
                break
            end
        end
        target.Task = nil
        if flag then
            target.Task = { co }
        end
    else
        target.Task = nil
    end
end

---@param t number Number of frames to wait.
function Task.Wait(t)
    assert(type(t) == "number")
    t = t or 1
    t = math.max(1, math.floor(t))
    for i = 1, t do
        coroutine.yield()
    end
end

---@param t number Wait until Self's timer reaches this number.
function Task.WaitUntil(t)
    assert(type(t) == "number")
    t = math.floor(t)
    while Task.GetSelf().timer < t do
        coroutine.yield()
    end
end

function Task.GetSelf()
    local c = Task.Stack[#Task.Stack]
    if c.TaskSelf then
        return c.TaskSelf
    else
        return c
    end
end
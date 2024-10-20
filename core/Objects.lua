--- Object Groups
GROUP_NONE = 0
GROUP_ENEMY_BULLET = 1
GROUP_ENEMY = 2
GROUP_PLAYER_BULLET = 3
GROUP_PLAYER = 4
GROUP_IMMORTAL = 5
GROUP_ITEM = 6
GROUP_BOMB = 7
--- Layer Groups
LAYER_BACKGROUND = -700
LAYER_ENEMY = -600
LAYER_PLAYER_BULLET = -500
LAYER_PLAYER = -400
LAYER_ITEM = -300
LAYER_ENEMY_BULLET = -200
LAYER_ENEMY_BULLET_EF = -100
LAYER_TOP = 0

--- Classes

AllClasses = {}
ClassName = {}

---@class Object
Object = { 0, 0, 0, 0, 0, 0;
    is_class = true,
    init = function() end,
    frame = function() end,
    render = DefaultRenderFunc,
    colli = function(other) end,
    kill = function() end,
    del = function() end,
}
table.insert(AllClasses, Object)

---Define a new class and returns it.
---@param base Object
---@param define Object
---@overload fun(base:Object)
function Class(base, define)
    if not base then
        base = Object
    end
    if (type(base) ~= "table") or not base.is_class then
        error("Invalid base class or base class doesn't exist.")
    end
    local result = { 0, 0, 0, 0, 0, 0 }
    result.is_class = true
    result.init = base.init
    result.frame = base.frame
    result.render = base.render
    result.colli = base.colli
    result.kill = base.kill
    result.del = base.del

    if define and type(define) == "table" then
        for k, v in pairs(define) do
            result[k] = v
        end
    end

    table.insert(AllClasses, result)
    return result
end

function InitAllClasses()
    for _, v in pairs(AllClasses) do
        v[1] = v.init
        v[2] = v.frame
        v[3] = v.render
        v[4] = v.colli
        v[5] = v.kill
        v[6] = v.del
    end
end

--- Global functions

function RawDel(o)
    if o then
        o.status = 'del'
        if o._servants then
            --_del_servants(o)
        end
    end
end

function RawKill(o)
    if o then
        o.status = 'kill'
        if o._servants then
            --_kill_servants(o)
        end
    end
end

function PreserveObject(o)
    o.status = 'normal'
end

local OldKill = Kill
local OldDel = Del

function Kill(o)
    if o then
        if o._servants then
            --_kill_servants(o)
        end
        OldKill(o)
    end
end

function Del(o)
    if o then
        if o._servants then
            --_del_servants(o)
        end
        OldDel(o)
    end
end


function SetV2(obj, v, angle, rot, aim)
    if aim then
        SetV(obj, v, angle + Angle(obj, Player), rot)
    else
        SetV(obj, v, angle, rot)
    end
end

--- Tables

function RemoveItemInArray(t, v)
    for i = #t, 1, -1 do
        if t[i] == v then
            table.remove(t, i)
        end
    end
end

function ClearArray(t)
    for i = #t, 1, -1 do
        t[i] = nil
    end
end
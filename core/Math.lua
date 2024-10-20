PI = math.pi
PIx2 = math.pi * 2
PI_2 = math.pi / 2
PI_4 = math.pi / 4
SQRT2 = math.sqrt(2)
SQRT3 = math.sqrt(3)
SQRT05 = math.sqrt(0.5)
GOLD = 360 * (math.sqrt(5) - 1) / 2

int = math.floor
abs = math.abs
max = math.max
min = math.min
rnd = math.random
sqrt = math.sqrt

if not math.mod then
    math.mod = function(a, b)
        return a % b
    end
end
mod = math.mod

function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

function hypot(x, y)
    return sqrt(x * x + y * y)
end

function clamp(v, v_min, v_max)
    v_min, v_max = math.min(v_min, v_max), math.max(v_min, v_max)
    return math.max(v_min, math.min(v, v_max))
end

function wrap(v, v_min, v_max)
    local range = v_max - v_min + 1
    return ((v - v_min) % range) + min
end

---@param v number
---@param a number
---@param b number
---@param c number
---@param d number
---@return number
---@overload fun(v:number, a:number, b:number, c:number)
function normalize(v, a, b, c, d)
    if d then
        -- 梯形归一化
        if v < a or v > d then
            return 0.0
        elseif v > b and v < c then
            return 1.0
        elseif v <= b then
            return (v - a) / (b - a)
        else
            return 1.0 - ((v - c) / (d - c))
        end
    else
        -- 三角形归一化
        if v < a or v > c then
            return 0.0
        elseif v <= b then
            return (v - a) / (b - a)
        else
            return 1.0 - ((v - b) / (c - b))
        end
    end
end

function balance(v, a, b, speed, state)
    if state then
        v = min(v + speed, b)
    else
        v = max(a, v - speed)
    end
    return v
end

function lerp(v1, v2, k)
    return (1.0 - k) * v1 + (k) * v2
end

--- Easing

function Interpolate(a, b, x)
    return a + (b - a) * x
end

function EaseOutCubic(x)
    return 1 - (1 - x) ^ 3
end

function EaseInQuart(x)
    return x * x * x * x
end

function Interpolate_Element(arr, t, func)
    local src = arr[int(t)]
    local did
    if int(t + 1) > #arr then
        did = int(t + 1 - #arr)
    else
        did = int(t + 1)
    end
    local dest = arr[did]
    local _t = t - int(t)
    func = func or function(x) return x end
    return Interpolate(src, dest, func(_t))
end

function approach_step(v, b, k)
    return b + (v - b) * k
end

--- Vectors

---@class Vector
Vector = {}
Vector.__index = Vector

function Vector.__add(a, b)
    if type(a) == "number" then
        return Vector.new(b.x + a, b.y + a)
    elseif type(b) == "number" then
        return Vector.new(a.x + b, a.y + b)
    else
        return Vector.new(a.x + b.x, a.y + b.y)
    end
end

function Vector.__sub(a, b)
    if type(a) == "number" then
        return Vector.new(a - b.x, a - b.y)
    elseif type(b) == "number" then
        return Vector.new(a.x - b, a.y - b)
    else
        return Vector.new(a.x - b.x, a.y - b.y)
    end
end

function Vector.__mul(a, b)
    if type(a) == "number" then
        return Vector.new(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return Vector.new(a.x * b, a.y * b)
    else
        return Vector.new(a.x * b.x, a.y * b.y)
    end
end
function Vector.__pow(a,b)
    if type(a) == "number" then
        return Vector.new(b.x ^ a, b.y ^ a)
    elseif type(b) == "number" then
        return Vector.new(a.x ^ b, a.y ^ b)
    else
        return Vector.new(a.x ^ b.x, a.y ^ b.y)
    end
end

function Vector.__div(a, b)
    if type(a) == "number" then
        return Vector.new(a / b.x, a / b.y)
    elseif type(b) == "number" then
        return Vector.new(a.x / b, a.y / b)
    else
        return Vector.new(a.x / b.x, a.y / b.y)
    end
end

function Vector.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
    return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a, b)
    return a.x <= b.x and a.y <= b.y
end

function Vector.__tostring(a)
    return "(" .. a.x .. ", " .. a.y .. ")"
end

function Vector.new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

function Vector.fromAngle(angle)
    return Vector.new(cos(angle), sin(angle))
end

function Vector.fromPolar(func, t) --t should be between 0 and 1 (normalized)
    local rad = func(t)
    return Vector.new(rad * cos(t*360), rad * sin(t*360))
end

function Vector.getPointFromPolygon(sides,t)
    local edgesx = {}
    local edgesy = {}
    t = (t - int(t)) * sides + 1
    for i = 1, sides do
        edgesx[i] = cos((360/sides) * i)
        edgesy[i] = sin((360/sides) * i)
    end
    return Vector.new(Interpolate_Element(edgesx,t),Interpolate_Element(edgesy,t))
end

function Vector.distance(a, b)
    return (b - a):len()
end

function Vector:clone()
    return Vector.new(self.x, self.y)
end

function Vector:unpack()
    return self.x, self.y
end

function Vector:len()
    return sqrt(self.x * self.x + self.y * self.y)
end

function Vector:lenSq()
    return self.x * self.x + self.y * self.y
end

function Vector:normalize()
    local len = self:len()
    self.x = self.x / len
    self.y = self.y / len
    return self
end

function Vector:normalized()
    return self / self:len()
end

function Vector:rotate(phi)
    local a = Angle(0,0,self.x,self.y)
    local d = self:len()
    self.x = d * cos(a + phi)
    self.y = d * sin(a + phi)
    return self
end

function Vector:rotated(phi)
    return self:clone():rotate(phi)
end

function Vector:perpendicular()
    return Vector.new(-self.y, self.x)
end

function Vector:projectOn(other)
    return (self * other) * other / other:lenSq()
end

function Vector:cross(other)
    return self.x * other.y - self.y * other.x
end

function Vector:getAngle()
    return Angle(0,0,self.x,self.y)
end
function Vector:lerp(b,t,func)
    func = func or function(x) return x end
    return Vector.new(
            Interpolate(self.x,b.x,func(t)),
            Interpolate(self.y,b.y,func(t))
    )
end

function Vector:setPosition(object)
    object.x = self.x
    object.y = self.y
    return self
end
function Vector:setSpeed(object)
    object.vx = self.x
    object.vy = self.y
    return self
end

function Vector:addPosition(object)
    object.x = self.x + object.x
    object.y = self.y + object.y
    return self
end
function Vector:addSpeed(object)
    object.vx = self.x + object.vx
    object.vy = self.y + object.vy
    return self
end

setmetatable(Vector, { __call = function(_, ...) return Vector.new(...) end })
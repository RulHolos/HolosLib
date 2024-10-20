---@class Screen
Screen = {}
---@class Screen.World
Screen.World = {}

--- Update Screen Resources

lstg.CreateRenderTarget("rt:screen-white", 64, 64)

function UpdateScreenResources()
    lstg.PushRenderTarget("rt:screen-white")
    lstg.RenderClear(lstg.Color(255, 255, 255, 255))
    lstg.PopRenderTarget()
end

function ResetScreen()
    Screen.Width = 853
    Screen.Height = 480

    Screen.HorizontalScale = Settings.ResX / Screen.Width
    Screen.VerticalScale = Settings.ResY / Screen.Height
    Screen.ResolutionScale = Settings.ResX / Settings.ResY
    Screen.Scale = math.min(Screen.HorizontalScale, Screen.VerticalScale)

    if Screen.ResolutionScale >= (Screen.Width / Screen.Height) then
        Screen.DeltaX = (Settings.ResX - Screen.Scale * Screen.Width) * 0.5
        Screen.DeltaY = 0
    else
        Screen.DeltaX = 0
        Screen.DeltaY = (Settings.ResY - Screen.Scale * Screen.Height) * 0.5
    end

    Screen.World = DEFAULT_WORLD
    SetBound(Screen.World.BoundLeft, Screen.World.BoundRight, Screen.World.BoundBottom, Screen.World.BoundTop)
    --ResetWorldOffset()
end

DEFAULT_WORLD = {
    Left = -192, Right = 192, Bottom = -224, Top = 224,
    BoundLeft = -224, BoundRight = 224, BoundBottom = -256, BoundTop = 256,
    ScreenLeft = 6, ScreenRight = 390, ScreenBottom = 16, ScreenTop = 464,
    WorldMask = 1
}

--- Transforms

function SetViewMode(mode)
    lstg.viewmode = mode
    if mode == '3d' then
        SetViewport(Screen.World.ScreenLeft * Screen.Scale + Screen.DeltaX, Screen.World.ScreenRight * Screen.Scale + Screen.DeltaX,
                Screen.World.ScreenBottom * Screen.Scale + Screen.DeltaY, Screen.World.ScreenTop * Screen.Scale + Screen.DeltaY)
        SetPerspective(
                lstg.view3d.eye[1], lstg.view3d.eye[2], lstg.view3d.eye[3],
                lstg.view3d.at[1], lstg.view3d.at[2], lstg.view3d.at[3],
                lstg.view3d.up[1], lstg.view3d.up[2], lstg.view3d.up[3],
                lstg.view3d.fovy, (Screen.World.Right - Screen.World.Left) / (Screen.World.Top - Screen.World.Bottom),
                lstg.view3d.z[1], lstg.view3d.z[2]
        )
        SetFog(lstg.view3d.fog[1], lstg.view3d.fog[2], lstg.view3d.fog[3])
        SetImageScale(((((lstg.view3d.eye[1] - lstg.view3d.at[1]) ^ 2
                + (lstg.view3d.eye[2] - lstg.view3d.at[2]) ^ 2
                + (lstg.view3d.eye[3] - lstg.view3d.at[3]) ^ 2) ^ 0.5)
                * 2 * math.tan(lstg.view3d.fovy * 0.5)) / (Screen.World.ScreenRight - Screen.World.ScreenLeft))
    elseif mode == 'world' then
        --计算world宽高和偏移
        local w = Screen.World
        local world = {
            height = (w.Top - w.Bottom), --world高度
            width = (w.Right - w.Left), --world宽度
        }
        world.setheight = world.height--缩放后的高度
        world.setwidth = world.width--缩放后的宽度
        world.setdx = 0--水平整体偏移
        world.setdy = 0--垂直整体偏移
        --计算world最终参数
        world.Left = world.setwidth / 2
        world.Right = world.setwidth / 2
        world.Bottom = world.setheight / 2
        world.Top = world.setheight / 2
        --应用参数
        SetRenderRect(world.Left, world.Right, world.Bottom, world.Top, w.ScreenLeft, w.ScreenRight, w.ScreenBottom, w.ScreenTop)
    elseif mode == 'ui' then
        SetRenderRect(0, Screen.Width, 0, Screen.Height, 0, Screen.Width, 0, Screen.Height)
    else
        error('Invalid arguement.')
    end
end

local function drawRect(l, r, b, t, color)
    lstg.SetImageState("img:screen-white", "", color)
    lstg.RenderRect("img:screen-white", l, r, b, t)
end
function RenderClearViewMode(color)
    if lstg.viewmode == '3d' then
        SetViewMode('world')
        local w = Screen.World
        drawRect(w.Left, w.Right, w.Bottom, w.Top, color)
        SetViewMode('3d')
    elseif lstg.viewmode == 'world' then
        local w = Screen.World
        drawRect(w.Left, w.Right, w.Bottom, w.Top, color)
    elseif lstg.viewmode == 'ui' then
        drawRect(0, Screen.Width, 0, Screen.Height, color)
    else
        error('Unknown viewmode.')
    end
end

function WorldToUI(x, y)
    local w = Screen.World
    return w.ScreenLeft + (w.ScreenRight - w.ScreenLeft) * (x - w.Left) / (w.Right - w.Left), w.ScreenBottom + (w.ScreenTop - w.ScreenBottom) * (y - w.Bottom) / (w.Top - w.Bottom)
end

function WorldToScreen(x, y)
    local w = Screen.World
    return (Settings.ResX - Settings.ResY * Screen.Width / Screen.Height) / 2 / Screen.Scale + w.ScreenLeft + (w.ScreenRight - w.ScreenLeft) * (x - w.Left) / (w.Right - w.Left),
        w.ScreenBottom + (w.ScreenTop - w.ScreenBottom) * (y - w.Bottom) / (w.Top - w.Bottom)
end

function ScreenToWorld(x, y)
    local dx, dy = WorldToScreen(0, 0)
    return x - dx, y - dy
end

---@param l number @坐标系左边界
---@param r number @坐标系右边界
---@param b number @坐标系下边界
---@param t number @坐标系上边界
---@param scrl number @渲染系左边界
---@param scrr number @渲染系右边界
---@param scrb number @渲染系下边界
---@param scrt number @渲染系上边界
---@overload fun(info:table):nil @坐标系信息
function SetRenderRect(l, r, b, t, scrl, scrr, scrb, scrt)
    local function setViewportAndScissorRect(l, r, b, t)
        SetViewport(l, r, b, t)
        SetScissorRect(l, r, b, t)
    end
    if l and r and b and t and scrl and scrr and scrb and scrt then
        --设置坐标系
        SetOrtho(l, r, b, t)
        --设置视口
        setViewportAndScissorRect(
                scrl * Screen.Scale + Screen.DeltaX,
                scrr * Screen.Scale + Screen.DeltaX,
                scrb * Screen.Scale + Screen.DeltaY,
                scrt * Screen.Scale + Screen.DeltaY
        )
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    elseif type(l) == "table" then
        --设置坐标系
        SetOrtho(l.l, l.r, l.b, l.t)
        --设置视口
        setViewportAndScissorRect(
                l.scrl * Screen.Scale + Screen.DeltaX,
                l.scrr * Screen.Scale + Screen.DeltaX,
                l.scrb * Screen.Scale + Screen.DeltaY,
                l.scrt * Screen.Scale + Screen.DeltaY
        )
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    else
        error("Invalid argument.")
    end
end

--- 3D

lstg.View3D = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fov = PI_2,
    z = { 0, 2 },
    fog = { 0, 0, Color(0x00000000) },
}

function Set3D(key, ...)
    local args = { ... }

    lstg.View3D[key] = args
end

ResetScreen()
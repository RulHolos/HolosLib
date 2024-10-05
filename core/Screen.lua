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

--- 3D

lstg.View3D = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fov = math.pi / 2,
    z = { 0, 2 },
    fog = { 0, 0, Color(0x00000000) },
}

function Set3D(key, ...)
    local args = { ... }

    lstg.View3D[key] = args
end
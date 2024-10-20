---@class post_effect
local post_effect = {}

---@param rendertarget_name string
---@param mask_rendertarget_name string
function post_effect.DrawMaskEffect(rendertarget_name, mask_rendertarget_name)
    if not lstg.CheckRes(9, "$fx:alpha-mask") then
        lstg.LoadFX("$fx:alpha-mask", "lib/shaders/alpha_mask.hlsl")
    end
    lstg.PostEffect(
        "$fx:alpha-mask",
        rendertarget_name, 6,
        "mul+alpha",
        {},
        {
            { mask_rendertarget_name, 6 },
        }
    )
end

PostEffect = post_effect

return post_effect
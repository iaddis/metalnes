#include "common.fxh"

VS_OUTPUT VS(VS_INPUT v)
{
    VS_OUTPUT o;
    o.pos   = mul(xform_position, float4(v.pos.xyz,1));
    o.color = clamp(v.color, 0, 1);
    o.uv    = v.uv.xy;
    return o;
}

// error pixel shader
float4 PS(VS_OUTPUT v) : COLOR
{
    // texture * color
    float4 c = float4(1,0,0,1);
    return c;
}

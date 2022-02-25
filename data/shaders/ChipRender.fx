
#include "common.fxh"

sampler2D sampler1;
float4 color_scale;

VS_OUTPUT VS(VS_INPUT v)
{  
	VS_OUTPUT o;
	o.pos   = mul(xform_position, float4(v.pos.xyz,1));
    o.color = clamp(v.color, 0, 1);
    o.uv    = v.uv.xy;
    o.uv1   = v.uv1.xy;
    return o;
}

float4 PS(VS_OUTPUT v) : COLOR
{
	// vertex color
	float4 c = v.color;
 
    // state texture
    float4 state_color = tex2D(sampler0, v.uv);
    c *= state_color.a;

    // layer texture
    float4 layer_color = tex2D(sampler1, v.uv1);
    c *= layer_color;

    // constant
    c *= color_scale;
	return c;
}

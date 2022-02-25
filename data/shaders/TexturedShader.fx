
#include "common.fxh"

// fixed function vertex pipeline
VS_OUTPUT VS(VS_INPUT v)
{  
	VS_OUTPUT o;
	o.pos   = mul(xform_position, float4(v.pos.xyz,1));
    o.color = clamp(v.color, 0, 1);
    o.uv    = v.uv.xy;
    return o;
}

// fixed function pixel shader
float4 PS(VS_OUTPUT v) : COLOR
{
	// sample texture
	float4 tcolor = tex2D(sampler0, v.uv);

	// texture * color
	float4 c = tcolor * v.color;
	return c;
}


#include "common.fxh"



float3 yiq2rgb(float3 yiq)
{
	const float3x3 yiq2rgb_mat = 
    float3x3(
    1.0,  0.946882, 0.623557,
    1.0, -0.274788,-0.635691,
    1.0, -1.108545, 1.709007
    );


	return mul(yiq2rgb_mat, yiq);
}



float3 rgb2yiq(float3 col)
{
	const float3x3 yiq_mat = float3x3(
		0.2989, 0.5870, 0.1140,
		0.5959, -0.2744, -0.3216,
		0.2115, -0.5229, 0.3114
		);

	return mul(col, yiq_mat);
}




// Vertex Shader
VS_OUTPUT VS( VS_INPUT v )
{
    VS_OUTPUT o;
    o.pos   = mul(xform_position, float4(v.pos.xyz,1));
    o.color = clamp(v.color, 0, 1);
    o.uv    = v.uv.xy;
    return o;
}

// Pixel Shader
float4 PS( VS_OUTPUT input ) : COLOR
{
    float4 tex = tex2D(sampler0, input.uv.xy);

    float3 yiq = tex.xyz;
    
    yiq.x  = yiq.x * 2.0;
    yiq.yz = yiq.yz * 2.0 - 1.0;

    float3 rgb = yiq2rgb(yiq);
    rgb = clamp(rgb, 0.0, 1.0);
    rgb = pow(rgb, 2.2 / 2.0);

    float4 c;
//    c  = float4( lerp(tex.rgb, rgb.rgb, tex.a), 1.0);
    c  = float4( rgb, 1.0);
    return c.bgra;
}

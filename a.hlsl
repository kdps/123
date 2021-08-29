float4x4 world : WORLD;

texture tex;
float uv_left;
float uv_top;
float uv_width;
float uv_height;
float alpha;

float m_TU;
float m_TV;


sampler smpdef = sampler_state {
    texture = <tex>;
};


struct VS_IN {
    float3 pos : POSITION;
    float2 uv : TEXCOORD0;
};

struct VS_OUT {
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};


VS_OUT vs_main( VS_IN In ) {
   
    VS_OUT Out = (VS_OUT)0;

    Out.pos = mul( float4(In.pos, 1.0f), world );
    Out.pos = mul( Out.pos, proj );
    Out.uv = In.uv * float2(uv_width, uv_height) + float2(uv_left, uv_top);

    return Out;    
}

float4 ps_main(VS_OUT In) : COLOR0 {
    float4 color = tex2D( smpdef, In.uv );
    color.a *= alpha;
    return color;
}

sampler smpgauss = sampler_state {
    texture = <tex>;
     AddressU = Clamp;
     AddressV = Clamp;
};

float4 ps_main_gauss(VS_OUT In) : COLOR0 {
    float4 color = tex2D( smpgauss, In.uv );
    color.a *= alpha;
    
	float2 Texel0 = In.uv + float2( -m_TU, 0.0f );
	float2 Texel1 = In.uv + float2( +m_TU, 0.0f );
	float2 Texel2 = In.uv + float2(  0.0f, +m_TV );
	float2 Texel3 = In.uv + float2(  0.0f, -m_TV );

	float2 Texel4 = In.uv + float2( -m_TU, -m_TV );
	float2 Texel5 = In.uv + float2( +m_TU, -m_TV );
	float2 Texel6 = In.uv + float2( -m_TU, +m_TV );
	float2 Texel7 = In.uv + float2( +m_TU, +m_TV );

	float4 p0 = tex2D( smpgauss, In.uv ) * 0.2f;

	float4 p1 = tex2D( smpgauss, Texel0 ) * 0.1f;
	float4 p2 = tex2D( smpgauss, Texel1 ) * 0.1f;
	float4 p3 = tex2D( smpgauss, Texel2 ) * 0.1f;
	float4 p4 = tex2D( smpgauss, Texel3 ) * 0.1f;

	float4 p5 = tex2D( smpgauss, Texel4 ) * 0.1f;
	float4 p6 = tex2D( smpgauss, Texel5 ) * 0.1f;
	float4 p7 = tex2D( smpgauss, Texel6 ) * 0.1f;
	float4 p8 = tex2D( smpgauss, Texel7 ) * 0.1f;

	return p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8;
}

float4 ps_main_invert(VS_OUT In) : COLOR0 {
    float4 color = tex2D( smpdef, In.uv );
  float4 inverted_color = 1 - color;
  inverted_color.a = color.a;
  inverted_color.rgb *= inverted_color.a;

  return inverted_color;
}

VS_OUT vs_main_mosaic( VS_IN In ) {
    VS_OUT Out = (VS_OUT)0;

    Out.pos = mul( float4(In.pos, 1.0f), world );
    Out.pos = mul( Out.pos, proj );
    Out.uv = In.uv * float2(uv_width, uv_height) + float2(uv_left, uv_top);

    return Out;
}

float4 ps_main_mosaic(float2 uv : TEXCOORD) : COLOR0 {
  float size1 = 0.9 * 100;
  float2 uv1 = floor(uv * size1 + 0.5) / size1;

  return tex2D(smpdef, uv1);
}

float4 ps_main_grayscale(float2 uv : TEXCOORD) : COLOR0 {
  float4 color = tex2D(smpdef, uv);
  float4 gray = color.r * 0.299 + color.g * 0.587 + color.b * 0.114;
  gray.a = color.a;

  return gray;
}

technique Tech {
    pass p0 {
        VertexShader = compile vs_2_0 vs_main();
        PixelShader = compile ps_2_0 ps_main();

        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
    }
    pass p1
    {
        VertexShader = compile vs_2_0 vs_main();
        PixelShader  = compile ps_2_0 ps_main_grayscale();
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
	}
    pass p2
    {
        VertexShader = compile vs_2_0 vs_main();
        PixelShader  = compile ps_2_0 ps_main_invert();
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
	}
    pass p3
    {
        VertexShader = compile vs_2_0 vs_main();
        PixelShader  = compile ps_2_0 ps_main_mosaic();
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
	}
    pass p4
    {
        VertexShader = compile vs_2_0 vs_main();
        PixelShader  = compile ps_2_0 ps_main_gauss();
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
	}
}

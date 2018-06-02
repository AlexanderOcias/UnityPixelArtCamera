// Version 1.0
// By Alexander Ocias
// https://ocias.com

Shader "Ocias/Pixel Art Sprite Diffuse"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
	
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert nofog keepalpha

		sampler2D _MainTex;
		fixed4 _Color;

		uniform float PIXELS_PER_UNIT;

		struct Input
		{
			float2 uv_MainTex;
			fixed4 color;
		};
		
		inline float4 WorldSpacePixelSnap (float4 pos) {

			float ppu = PIXELS_PER_UNIT;

			pos = mul(unity_ObjectToWorld, pos);

			// World space Pixel Snapping
			pos = floor(pos * ppu + 1 / ppu) / ppu;

			// Odd resolution handling
			float2 odd = trunc(_ScreenParams.xy) % 2;
			pos.x += odd.x * 0.5 / ppu;
			pos.y += odd.y * 0.5 / ppu;

			pos = mul(unity_WorldToObject, pos);

			return pos;
		}

		void vert (inout appdata_full v, out Input o)
		{
			v.vertex = WorldSpacePixelSnap(v.vertex);

			float ppu = PIXELS_PER_UNIT;
			float3 snappedCameraPosition = floor(_WorldSpaceCameraPos * ppu + 1 / ppu) / ppu;
			float3 cameraSubpixelOffset = snappedCameraPosition - _WorldSpaceCameraPos;
			v.vertex.x -= cameraSubpixelOffset.x;
			v.vertex.y -= cameraSubpixelOffset.y;

			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color = v.color * _Color;
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * IN.color;
			o.Albedo = c.rgb * c.a;
			o.Alpha = c.a;
		}
		ENDCG
	}

Fallback "Transparent/VertexLit"
}

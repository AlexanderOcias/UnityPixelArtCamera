// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ocias/Pixel Art Font Outline" 
{
	Properties 
	{
		_MainTex ("Font Texture", 2D) = "white" {}
		_Color ("Text Color", Color) = (1,1,1,1)

		[PerRendererData] _Outline ("Outline", Float) = 0
		[PerRendererData] _OutlineColor("Outline Color", Color) = (0,0,0,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15
	}

	SubShader 
	{
		Tags 
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}
		
		Lighting Off 
		Cull Off 
		ZTest [unity_GUIZTestMode]
		ZWrite Off 
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass 
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed4 _Color;

			float _Outline;
			fixed4 _OutlineColor;
			float4 _MainTex_TexelSize;
			
			inline float4 ViewSpacePixelSnap (float4 pos) {

				float2 halfScreenRes = _ScreenParams.xy * 0.5f;

				// // View space Pixel Snapping
				float2 pixelPos = round(pos * halfScreenRes + 1 / halfScreenRes) / halfScreenRes; // put back in that half pixel offset when you're done
				pos.xy = pixelPos;
				
				// Odd resolution handling
				float2 odd = _ScreenParams.xy % 2;
				pos.x += odd.x * 0.5 / halfScreenRes.x;
				pos.y += odd.y * 0.5 / halfScreenRes.y;

				return pos;
			}

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color * _Color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef UNITY_HALF_TEXEL_OFFSET
				o.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
#endif
				o.vertex = ViewSpacePixelSnap(o.vertex);
				return o;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
				fixed4 col = IN.color;
				col.a *= tex2D(_MainTex, IN.texcoord).a;
				//clip (col.a - 0.01);

				//Outline
				fixed4 currentPixel = tex2D(_MainTex, IN.texcoord + fixed2(0, 0));
				fixed4 pixelUp = tex2D(_MainTex, IN.texcoord + fixed2(0, 1 * _MainTex_TexelSize.y));
				fixed4 pixelDown = tex2D(_MainTex, IN.texcoord - fixed2(0, 1 *  _MainTex_TexelSize.y));
				fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(1 * _MainTex_TexelSize.x, 0));
				fixed4 pixelLeft = tex2D(_MainTex, IN.texcoord - fixed2(1 * _MainTex_TexelSize.x, 0));
				//Diagonals
				fixed4 pixelUpLeft = tex2D(_MainTex, IN.texcoord - fixed2(1 * _MainTex_TexelSize.x, 1 * _MainTex_TexelSize.y));
				fixed4 pixelUpRight = tex2D(_MainTex, IN.texcoord - fixed2(-1 * _MainTex_TexelSize.x, 1 * _MainTex_TexelSize.y));
				fixed4 pixelDownRight = tex2D(_MainTex, IN.texcoord + fixed2(1 * _MainTex_TexelSize.x, 1 * _MainTex_TexelSize.y));
				fixed4 pixelDownLeft = tex2D(_MainTex, IN.texcoord + fixed2(-1 * _MainTex_TexelSize.x, 1 * _MainTex_TexelSize.y));

				float nearPixelA = max(max(max(max(max(max(max(pixelUp.a, pixelDown.a), pixelRight.a), pixelLeft.a),
					pixelUpLeft.a), pixelDownRight.a), pixelUpRight.a), pixelDownLeft.a);

				float currentA = (1 - currentPixel.a) * (nearPixelA) * _Outline;
				fixed4 resultColor = lerp(col.rgba, _OutlineColor, currentA);

				col.rgba = fixed4(1, 1, 1, 1) * resultColor;
				return col;
			}

		ENDCG
		}
	}
}

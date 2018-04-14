Shader "Hidden/BilinearSharp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DestinationResolution ("Destination Resolution", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		
		Cull Off
		Lighting Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 precalc_texel : TEXCOORD1;
				float2 precalc_scale : TEXCOORD2;
				float2 region_range : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _DestinationResolution;
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float2 inputResolution = _ScreenParams.xy;
				o.precalc_texel = o.uv * inputResolution;
				o.precalc_scale = max(floor(_DestinationResolution / inputResolution), float2(1.0, 1.0)) * 1.5; // multiply to match expected sharpness
				o.region_range = 0.5 - 0.5 / o.precalc_scale;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 s = frac(i.precalc_texel);
				

				float2 center_dist = s - 0.5;
				float2 f = (center_dist - clamp(center_dist, -i.region_range, i.region_range)) * i.precalc_scale + 0.5;

				float2 mod_texel = floor(i.precalc_texel) + f;

				fixed4 col = tex2D(_MainTex, mod_texel / _ScreenParams.xy);
				
				return col;
			}
			ENDCG
		}
	}
}

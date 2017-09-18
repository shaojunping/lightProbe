// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Probes" {
	Properties {
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_SHLightingScale("LightProbe influence scale",float) = 1
	}

	SubShader {
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		CGINCLUDE
		#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;

		float _SHLightingScale;

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			fixed3 spec : TEXCOORD1;
			fixed3 SHLighting: TEXCOORD2;
		};


		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			float3 worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
			float3 shl = ShadeSH9(float4(worldNormal,1));
			o.SHLighting	= shl * _SHLightingScale;
			return o;
		}
		ENDCG

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest	
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 c	= tex2D (_MainTex, i.uv);

				c.rgb *= i.SHLighting;

				return c;
			}
	         ENDCG
		}	
	}
}
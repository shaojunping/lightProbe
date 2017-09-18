Shader "Unlit/MySHLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
				float3 shNum : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldNormal = mul(unity_ObjectToWorld, v.normal).xyz;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.shNum = ShadeSH9(float4(o.worldNormal, 1.0));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 diffuse;
				diffuse.rgb = col * _LightColor0.rgb * max(0, dot(worldNormal, worldLightDir));
				//diffuse.a = col.a;
				fixed4 finalCol;
				finalCol.rgb = diffuse + col.rgb * i.shNum;
				finalCol.a = 1.0;
				finalCol.rgb = i.shNum * 3;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalCol);
				return col;
			}
			ENDCG
		}
	}
}

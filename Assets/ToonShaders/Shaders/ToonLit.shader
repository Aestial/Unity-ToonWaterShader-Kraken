Shader "Roystan/Toon/Lit"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"LightMode" = "ForwardBase"
            "PassFlags" = "OnlyDirectional"
		}

		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

             #pragma multi_compile_fog
             #pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF


            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
				float3 worldNormal : NORMAL;
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                o.uv2 = v.uv2;

                #ifdef LIGHTMAP_ON
                o.uv2 = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                UNITY_TRANSFER_FOG(o, o.vertex);

				o.worldNormal = normalize(mul((float3x3)UNITY_MATRIX_M, v.normal));
                return o;
            }

			float4 _Color;

            float4 frag (v2f i) : SV_Target
            {
				float NdotL = dot(i.worldNormal, _WorldSpaceLightPos0);
				float light = saturate(floor(NdotL * 3) / (2 - 0.5)) * _LightColor0;

                float4 col = tex2D(_MainTex, i.uv);
                
       /*         #ifdef LIGHTMAP_ON
                half4 lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2);
                col.rgb = col.rgb * DecodeLightmap(lm);
                col *= UNITY_LIGHTMODEL_AMBIENT * 10;
                #endif*/
                UNITY_APPLY_FOG(i.fogCoord, col);
                UNITY_OPAQUE_ALPHA(col.a);

                return (col * _Color) * (light + unity_AmbientSky);
            }
            ENDCG
        }
    }
}

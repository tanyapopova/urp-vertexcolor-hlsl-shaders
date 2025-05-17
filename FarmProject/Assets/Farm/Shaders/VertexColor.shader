Shader "TA/VertexColor"
{
    Properties
    {
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline" 
            "Queue" = "Geometry"
            "IgnoreProjector" = "True"
            "RenderType"="Opaque"
        }
        LOD 100


        Pass
        {
            Name "ForwardLit"
            Tags
            {
              "LightMode" = "UniversalForward"
            }
            Cull Back
            ZWrite On
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
                       
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

  
            struct MeshData
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                half4 color : COLOR;
               
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                half4 color : COLOR;
                half3 normalWS: TEXCOORD1;
                float3 positionWS: TEXCOORD0;
                float4 shadowCoord:TEXCOORD2;
            };

            v2f vert (MeshData v)
            {
                v2f o;
                o.positionWS = TransformObjectToWorld(v.positionOS.xyz); 
                o.positionCS = TransformWorldToHClip(o.positionWS);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.shadowCoord = TransformWorldToShadowCoord(o.positionWS);
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                Light light = GetMainLight();
                half NdotL = saturate(dot(i.normalWS, light.direction));
                half3  ambient = float3(0.9, 0.9, 0.9);

                half  shadow = MainLightRealtimeShadow(i.shadowCoord);             
                half  shadowStrength = 0.6;

                shadow = lerp(1.0, shadow, shadowStrength);

                half3  shadowTint = float3(0.5, 0.5, 0.6);
                half3  shadowFull = shadowTint * shadow;

                half3  litcolor = i.color.rgb * (ambient + light.color * NdotL * shadowFull);

                return half4(litcolor, 1); 
            }


            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            Cull Back
            ZWrite On

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct MeshData
            {
                float4 positionOS: POSITION;
            };

            struct v2f
            {
                float4 positionCS: SV_POSITION;
            };

            v2f vert (MeshData v)
            {
                v2f o;
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.positionCS  = TransformWorldToHClip(positionWS);
                return o;
            }

            half4 frag (v2f i): SV_Target
            {
                return 0;
            }

            ENDHLSL
        }

    }
}
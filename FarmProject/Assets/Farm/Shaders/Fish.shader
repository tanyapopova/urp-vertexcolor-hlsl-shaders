Shader "TA/Fish"
{
    Properties
    {
       _Amplitude ("_Amplitude", Float) = 0.1
    }
    SubShader
    {
        Tags 
        { 
        "RenderPipeline" = "UniversalRenderPipeline" 
        "Queue" = "Geometry+1"
        "RenderType"="Opaque"
        "IgnoreProjector" = "True"
         }
        LOD 100

        Pass
        {
           
            ZWrite Off 
            Cull Back
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half _Amplitude;
            CBUFFER_END

            struct MeshData
            {
                float4 positionOS: POSITION;
                half4 color: COLOR;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            { 
                float4 positionCS : SV_POSITION;
                half4 color: COLOR;
            };

            
            v2f vert (MeshData v)
            {
                v2f o;
                
                float wave = sin(_Time.y + v.uv.y * 3);
                float Ymask = saturate(1 - v.uv.y);
                
                float3 pos = v.positionOS.xyz;
                pos.x += wave * Ymask * _Amplitude;
           

                o.positionCS = TransformObjectToHClip(pos);
                o.color = v.color;

                return o;
            }

            half4 frag (v2f i): SV_Target
            {
                
                return i.color;

            }
 
            ENDHLSL
        }
    }
}

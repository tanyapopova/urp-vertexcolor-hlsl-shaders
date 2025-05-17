Shader "TA/CheckerAlphaTest"
{
    Properties
    {
        _Density ("_Density", Float) = 50 
    }
    SubShader
    {
        Tags 
        {
            "RenderPipeline" = "UniversalRenderPipeline" 
            "Queue" = "AlphaTest"
            "RenderType"="Transparent" 
            
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
            float _Density;
            CBUFFER_END


            struct Meshdata
            {
                float4 positionOS: POSITION;
                half4 color: COLOR;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 positionCS: SV_POSITION;
                half4 color: COLOR;
                float2 uv : TEXCOORD0; 
 
            };

            v2f vert (Meshdata v)
            {
                v2f o;
                
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.color = v.color;
                o.uv = v.uv;

                return o;
            }

            half4 frag (v2f i): SV_TARGET
            {
                float2 grid = floor(i.uv * _Density) % 2;
                float2 cheker = (grid.x + grid.y) % 2;
                
                clip (cheker - 0.5);
                               
                return i.color;
            };
            
            
            ENDHLSL
        }
    }
}

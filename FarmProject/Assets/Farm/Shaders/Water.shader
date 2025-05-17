Shader "TA/Water"
{
    Properties
    {
        _Color1 ("Color1", Color) = (1,1,1,1)
        _Color2 ("Color2", Color) = (1,1,1,1)
        _FoamColor ("Foam", Color) = (1,1,1,1)

        _FoamWidth ("FoamWidth", Float) = 1
        _Frequency ("Frequency", Range(0,5)) = 3
        _Amplitude ("Amplitude", Range(0,1)) = 1

    }
    SubShader
    {
        Tags 
        {          
         "RenderPipeline" = "UniversalRenderPipeline" 
         "Queue" = "Transparent"
         "RenderType"="Transparent" 
        }
        LOD 100

        Pass
        {
           
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off 
            Cull Back
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);


            CBUFFER_START(UnityPerMaterial)
            half4 _Color1, _Color2, _FoamColor;
            half _Frequency, _Amplitude, _FoamWidth;
            CBUFFER_END


            struct MeshData
            {
                float4 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS: SV_POSITION;
                half color: COLOR;
                float4 screenPos: TEXCOORD0;
            };


            v2f vert (MeshData v)
            {
                v2f o;

                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                half waveValue = sin(-_Time.y + (positionWS.x + positionWS.z) * _Frequency) * _Amplitude;
                positionWS.y += waveValue;

                o.positionCS = TransformWorldToHClip(positionWS);
                o.screenPos = ComputeScreenPos(o.positionCS);

                o.color = (waveValue * 0.5) + 0.5;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half factor = saturate((i.color - 0.5) * 2 + 0.5); 
                half4 col = lerp(_Color1, _Color2,  factor);

                float2  screenUV = i.screenPos.xy / i.screenPos.w;  

                float GrabTex = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV);       
                float SceneDepth = LinearEyeDepth(GrabTex, _ZBufferParams);      
                
                float WaterDepth = LinearEyeDepth(i.screenPos.z / i.screenPos.w, _ZBufferParams);

                float depthDifference = SceneDepth - WaterDepth;
                float foamMask = step(depthDifference * _FoamWidth, 1); 

                col = lerp(col, _FoamColor, foamMask);
                
                return col;
            }
            ENDHLSL
        }
    }
}

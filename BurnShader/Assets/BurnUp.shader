Shader "Unlit/BurnUp"
{
    Properties
    {
        _Colour ("Colour", Color) = (1,1,1,1)
        _FireColour ("Fire Colour", Color) = (1,0.4,0,3)

        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Float) = 0.01
        _Threshold ("Threshold", Range(0,1)) = 0.5
        _BurnEdge ("Burn Edge Width", Range(0,0.1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _NoiseScale;
            float _Threshold;
            float4 _Colour;
            float4 _FireColour;
            float _BurnEdge;

            float inverseLerp (float from, float to, float value)
            {
                return (value - from) / (to-from);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                float sqrtHalf = 0.7071;
                float2 centeredUV = i.uv - 0.5;
                float distance = length(centeredUV).rrr;
                distance = distance - tex2D(_NoiseTex,i.uv) * _NoiseScale;
                float threshold = lerp(-_NoiseScale,sqrtHalf,_Threshold);
                float clipValue  = 1 - step(threshold, distance);
                float burnEdgeInside  = step(threshold-_BurnEdge, distance);
                float unBurnt = 1-burnEdgeInside;
                float burnEdge = min(clipValue,burnEdgeInside) * inverseLerp(threshold-_BurnEdge, threshold,distance);
                float3 colour = _Colour.rgb * unBurnt + burnEdge * _FireColour.rgb;
                return float4(colour,clipValue);;
            }
            ENDCG
        }
    }
}

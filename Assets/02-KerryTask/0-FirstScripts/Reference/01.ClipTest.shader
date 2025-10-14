Shader "Mariana/ClipTest"
{
    Properties
    {
        _MainTex("tex", 2D) = "white" {}
        _MainCol("col", Color) = (1, 1, 1, 1)
        _NoiseMap("noiseMap", 2D) = "white" {}
        _CutOut("CutOut", Range(0.0, 1.1)) = 0.0
        _Speed("Speed", Vector) = (.34, .85, .91, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "DisableBatching"="True"
        }

        Pass
        {
            Name "FORWARD"
            Tags
            {
                "LightMode"="UniversalForward"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragment

            struct appdata
            {
                float4 vertex : POSITION;
                half2 texcoord0 : TEXCOORD0; // uv 数据
                half2 texcoord1 : TEXCOORD1; // 纹理坐标
                half2 texcoord2 : TEXCOORD2;
                half2 texcoord4 : TEXCOORD3;

                half4 color : COLOR;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half4 uv : TEXCOORD0;
                float3 pos_local : TEXCOORD1;
            };

            // 声明材质参数
            sampler2D _MainTex;
            float _CutOut;
            float4 _Speed;
            sampler2D _NoiseMap;
            float4 _MainCol;

            float4 _MainTex_ST;
            float4 _NoiseMap_ST;

            // 顶点 Shader
            v2f vert(appdata v)
            {
                v2f obj;
                float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
                float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
                obj.pos = pos_clip;
                obj.uv.xy = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;
                obj.uv.zw = v.texcoord0 * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
                obj.pos_local = v.vertex.xyz;
                return obj;
            }

            // 片元 Shader
            half4 fragment(v2f i) : SV_Target
            {
                half gradient = tex2D(_MainTex, i.uv.xy + _Time.y * 0.1f * _Speed.xy).r * (1.0 - i.uv.y);
                half noise = 1.0 - tex2D(_NoiseMap, i.uv.zw + _Time.y * 0.1f * _Speed.zw).r;
                clip(gradient - noise - _CutOut);
                return _MainCol;
            }
            ENDCG
        }
    }
}
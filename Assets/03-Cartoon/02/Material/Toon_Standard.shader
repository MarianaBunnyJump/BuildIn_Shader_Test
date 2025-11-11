Shader "Toon_Standard"
{
    Properties
    {
        _BaseMap ("_Base Map", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump" {}
        AOMap("AO Map",2D) = "white" {}
        _DiffuseRamp("Ramp",2D) = "white" {}
        _SpecMap("SpecMap",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float3 tangentDir : TEXCOORD2;
                float3 bitangentDir : TEXCOORD3;
                float4 posWorld : TEXCOORD4;
                float4 vertexColor : TEXCOORD5;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.vertexColor = v.color;
                o.uv = v.texcoord0;
                return o;
            }

            sampler2D _BaseMap;
            sampler2D _NormalMap;
            sampler2D _AOMap;
            sampler2D _DiffuseRamp;

            sampler2D _SpecMap;

            half4 frag(v2f i) : SV_Target
            {
                //向量
                half3 normalDir = normalize(i.normalDir);
                half3 tangentDir = normalize(i.tangentDir);
                half3 bitangentDir = normalize(i.bitangentDir);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(_WorldSpaceCameraPos - (i.posWorld.xyz));

                //贴图数据
                half3 base_color = tex2D(_BaseMap, i.uv).rgb;
                half ao_color = tex2D(_BaseMap, i.uv).r;
                half4 spec_map = tex2D(_SpecMap, i.uv);
                half spec_mask = spec_map.b;
                half spec_smoothness = spec_map.a;

                //法线贴图
                float4 normal_map = tex2D(_NormalMap, i.uv);
                half3 normal_data = UnpackNormal(normal_map);
                float3x3 TBN = float3x3(tangentDir, bitangentDir, normalDir);
                normalDir = normalize(mul(normal_data, TBN));

                //漫反射
                half NdotL = dot(normalDir , lightDir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half diffuse_term = half_lambert * ao_color;

                return float4(base_color, 1.0);
            }
            ENDCG
        }
    }
}
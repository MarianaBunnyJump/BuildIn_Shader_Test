Shader "Toon Eye"
{
    Properties
    {
        _BaseMap ("_Base Map", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump" {}
        _Parallax("Parallax",Float) = -0.1

        _DecalMap("_Decal Map",2D) = "white" {}
        _SpecColor("Spec Color",Color) = (0.5,0.5,0.5,1)
        _SpecIntensity("SpecIntensity",Float) = 1
        _SpecSmoothness("Spec Shininess",Float) = 0.5

        _EnvMap("Env Map",Cube) = "white" {}
        _EnvRotate("Env Rotate",Range(0,360)) = 0
        _Roughness("Roughness",Range(0,1)) = 0

        _EnvIntensity("EnvIntensity",Float) = 1

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
            float _Parallax;
            sampler2D _DecalMap;

            samplerCUBE _EnvMap;
            float _EnvRotate;

            float4 _EnvMap_HDR;
            float _Roughness;

            float _FresnelMax;
            float _FresnelMin;
            float _EnvIntensity;

            float3 RotateAround(float degree, float3 target)
            {
                float rad = degree * UNITY_PI / 180.0;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad), sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
            }

            float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
            }


            half4 frag(v2f i) : SV_Target
            {
                //向量
                half3 normalDir = normalize(i.normalDir);
                half3 tangentDir = normalize(i.tangentDir);
                half3 bitangentDir = normalize(i.bitangentDir);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(_WorldSpaceCameraPos - (i.posWorld.xyz));


                //法线贴图
                float4 normal_map = tex2D(_NormalMap, i.uv);
                half3 normal_data = UnpackNormal(normal_map);
                float3x3 TBN = float3x3(tangentDir, bitangentDir, normalDir);
                normalDir = normalize(mul(normal_data, TBN));
                normal_data.xy = -normal_data.xy;
                float3 normalDir_Iris = normalize(mul(normal_data, TBN));

                //视差偏移
                float2 parallax_depth = smoothstep(1.0, 0.5, (distance(i.uv, float2(0.5, 0.5)) / 0.2));
                float3 tanViewDir = normalize(mul(TBN, viewDir)); //切线空间的观察方向
                float2 parallax_offset = parallax_depth * (tanViewDir.xy / (tanViewDir.z + 0.42f)) * _Parallax;

                //贴图数据
                half3 base_color = tex2D(_BaseMap, i.uv + parallax_offset).rgb;
                half decal_color = tex2D(_DecalMap, i.uv).rgb;

                //漫反射
                half NdotL = max(0.0, dot(normalDir_Iris, lightDir));
                half half_lambert = (NdotL + 1.0) * 0.5;
                half3 final_diffuse = half_lambert * base_color * base_color;

                //环境反射 + 边缘光
                //反射是眼球最重要的质感来源

                half3 reflectDir = reflect(-viewDir, normalDir);
                reflectDir = RotateAround(_EnvRotate, reflectDir);
                float roughness = lerp(0.0, 0.95, saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_EnvMap, float4(reflectDir, mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR);
                half3 final_env = env_color * _EnvIntensity;
                half env_lumin = dot(final_env, float3(0.299f, 0.587f, 0.114)); //解码得到反射颜色
                final_env = env_lumin * final_env;

                half3 final_color = final_diffuse + final_diffuse * final_env * final_env + decal_color;
                half3 encode_color = sqrt(ACESFilm(final_color));

                return float4(encode_color, 1.0);
            }
            ENDCG
        }

    }

    Fallback "Standard"
}
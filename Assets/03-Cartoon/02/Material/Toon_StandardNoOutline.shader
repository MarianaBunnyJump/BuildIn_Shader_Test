Shader "Toon_StandardNoOutline"
{
    Properties
    {
        _BaseMap ("_Base Map", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump" {}
        AOMap("AO Map",2D) = "white" {}
        _DiffuseRamp("Ramp",2D) = "white" {}
        _TintLayer1("TintLayer1 Color",Color) = (0.5,0.5,0.5,1)
        _TintLayer1_Offset("TintLayer1 Offset",Range(-1,1)) = 0

        _TintLayer2("TintLayer2 Color",Color) = (0.5,0.5,0.5,0)
        _TintLayer2_Offset("TintLayer2 Offset",Range(-1,1)) = 0

        _TintLayer3("TintLayer3 Color",Color) = (0.5,0.5,0.5,0)
        _TintLayer3_Offset("TintLayer3 Offset",Range(-1,1)) = 0

        _SpecMap("SpecMap",2D) = "white" {}
        _SpecColor("Spec Color",Color) = (0.5,0.5,0.5,1)
        _SpecIntensity("SpecIntensity",Float) = 1
        _SpecSmoothness("Spec Shininess",Float) = 0.5

        _EnvMap("Env Map",Cube) = "white" {}
        _Roughness("Roughness",Range(0,1)) = 0
        _FresnelMin("Fresnel Min",Range(-1,2)) = 0.5
        _FresnelMax("Fresnel Max",Range(-1,2)) = 1
        _EnvIntensity("EnvIntensity",Float) = 1

        /*_Outline("Outline Width",Float) = 1
        _OutlineZbias("Outline Zbias",Float) = -10
        _OutlineColor("OutlineColor",Color) = (1,1,1,1)*/
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
            float4 _TintLayer1;
            float _TintLayer1_Offset;
            float4 _TintLayer2;
            float _TintLayer2_Offset;
            float4 _TintLayer3;
            float _TintLayer3_Offset;

            sampler2D _SpecMap;
            float4 _SpecColor;
            float _SpecIntensity;
            float _SpecSmoothness;

            samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
            float _Roughness;

            float _FresnelMax;
            float _FresnelMin;
            float _EnvIntensity;


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
                half ao = tex2D(_AOMap, i.uv).r;
                half4 spec_map = tex2D(_SpecMap, i.uv);
                half spec_mask = spec_map.b;
                half spec_smoothness = spec_map.a;

                //法线贴图
                float4 normal_map = tex2D(_NormalMap, i.uv);
                half3 normal_data = UnpackNormal(normal_map);
                float3x3 TBN = float3x3(tangentDir, bitangentDir, normalDir);
                normalDir = normalize(mul(normal_data, TBN));

                //漫反射
                half NdotL = dot(normalDir, lightDir);
                half half_lambert = (NdotL + 1.0) * 0.5;
                half diffuse_term = half_lambert * ao;


                half3 final_diffuse = half3(0.0, 0.0, 0.0);
                //第一层上色（一般都用不到三层，仅作学习测试使用）可以用顶点色来控制阴影软硬
                half2 uv_ramp1 = half2(diffuse_term + _TintLayer1_Offset, 0.5);
                half toon_diffuse1 = tex2D(_DiffuseRamp, uv_ramp1).r;
                half3 tint_color1 = lerp(half3(1, 1, 1), _TintLayer1.rgb,
                                         toon_diffuse1 * _TintLayer1.a * i.vertexColor.r);
                final_diffuse = base_color * tint_color1;
                //第二层上色
                half2 uv_ramp2 = half2(diffuse_term + _TintLayer2_Offset, 1.0 - i.vertexColor.g);
                half toon_diffuse2 = tex2D(_DiffuseRamp, uv_ramp2).g;
                half3 tint_color2 = lerp(half3(1, 1, 1), _TintLayer2.rgb, toon_diffuse2 * _TintLayer2.a);
                final_diffuse = final_diffuse * tint_color2;
                //第三层上色
                half2 uv_ramp3 = half2(diffuse_term + _TintLayer3_Offset, 1.0 - i.vertexColor.g);
                half toon_diffuse3 = tex2D(_DiffuseRamp, uv_ramp3).g;
                half3 tint_color3 = lerp(half3(1, 1, 1), _TintLayer3.rgb, toon_diffuse3 * _TintLayer3.a);
                final_diffuse = final_diffuse * tint_color3;

                //高光反射  bilin ndotH
                half3 H = normalize(lightDir + viewDir); //半角向量
                half NdotH = dot(normalDir, H);
                half spec_term = max(0.0001, pow(NdotH, _SpecSmoothness * spec_smoothness)) * ao;
                half3 final_spec = spec_term * _SpecColor * _SpecIntensity * spec_mask;

                //环境反射 + 边缘光
                half fresnel = 1.0 - dot(normalDir, viewDir);
                fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);
                half3 reflectDir = reflect(-viewDir, normalDir);
                float roughness = lerp(0.0, 0.95, saturate(_Roughness));
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_EnvMap, float4(reflectDir, mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR); //解码得到反射颜色
                half3 final_env = env_color * fresnel * _EnvIntensity * spec_mask;

                half3 final_color = final_diffuse + final_spec + final_env;


                return float4(final_color, 1.0);
            }
            ENDCG
        }

    }

    Fallback "Standard"
}
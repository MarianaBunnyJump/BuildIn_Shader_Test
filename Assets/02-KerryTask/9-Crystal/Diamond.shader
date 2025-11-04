// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Diamond"
{
    Properties
    {
        _Color("Color", Color) = (0.7735849,0.259078,0.259078,0)
        _RefractTex("RefractTex", CUBE) = "white" {}
        _ReflectTex("ReflectTex", CUBE) = "white" {}
        _RefractIntensity("RefractIntensity", Float) = 0
        _ReflectStrength("ReflectStrength", Float) = 0
        _RimPower("RimPower", Float) = 0
        _RimBase("RimBase", Float) = 0
        _RimScale("RimScale", Float) = 0
        _RimColor("RimColor", Color) = (0,0,0,0)

    }

    SubShader
    {


        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry"
        }
        LOD 100


        Pass
        {
            Name "Unlit"
            Blend Off
            ZWrite On
            ZTest LEqual
            Cull Front
            CGPROGRAM
            #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
            #endif
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #define ASE_NEEDS_FRAG_WORLD_POSITION


            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 ase_normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                float3 worldPos : TEXCOORD0;
                #endif
                float4 ase_texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _Color;
            uniform samplerCUBE _RefractTex;
            uniform samplerCUBE _ReflectTex;
            uniform float _RefractIntensity;


            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord1.xyz = ase_worldNormal;


                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                float3 vertexValue = float3(0, 0, 0);
                #if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
                #endif
                vertexValue = vertexValue;
                #if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
                #else
                v.vertex.xyz += vertexValue;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);

                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                #endif
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                float3 WorldPosition = i.worldPos;
                #endif
                float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = i.ase_texcoord1.xyz;
                float3 temp_output_13_0 = reflect(-ase_worldViewDir, ase_worldNormal);
                float4 texCUBENode12 = texCUBE(_ReflectTex, temp_output_13_0);
                float4 temp_output_17_0 = (_Color * texCUBE(_RefractTex, temp_output_13_0) * texCUBENode12 *
                    _RefractIntensity);


                finalColor = temp_output_17_0;
                return finalColor;
            }
            ENDCG
        }



        Pass
        {
            Name "Second"
            Blend One One
            ZWrite On
            ZTest LEqual
            Cull Back
            CGPROGRAM
            #ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
            #endif
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #define ASE_NEEDS_FRAG_WORLD_POSITION


            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float3 ase_normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                float3 worldPos : TEXCOORD0;
                #endif
                float4 ase_texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _Color;
            uniform samplerCUBE _RefractTex;
            uniform samplerCUBE _ReflectTex;
            uniform float _RefractIntensity;
            uniform float _ReflectStrength;
            uniform float _RimPower;
            uniform float _RimScale;
            uniform float _RimBase;
            uniform float4 _RimColor;


            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord1.xyz = ase_worldNormal;


                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                float3 vertexValue = float3(0, 0, 0);
                #if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
                #endif
                vertexValue = vertexValue;
                #if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
                #else
                v.vertex.xyz += vertexValue;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);

                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                #endif
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
                float3 WorldPosition = i.worldPos;
                #endif
                float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = i.ase_texcoord1.xyz;
                float3 temp_output_13_0 = reflect(-ase_worldViewDir, ase_worldNormal);
                float4 texCUBENode12 = texCUBE(_ReflectTex, temp_output_13_0);
                float4 temp_output_17_0 = (_Color * texCUBE(_RefractTex, temp_output_13_0) * texCUBENode12 *
                    _RefractIntensity);
                float dotResult23 = dot(ase_worldNormal, ase_worldViewDir);
                float clampResult25 = clamp(dotResult23, 0.0, 1.0);
                float temp_output_26_0 = (1.0 - clampResult25);
                float4 temp_output_20_0 = (temp_output_17_0 + (texCUBENode12 * _ReflectStrength * temp_output_26_0));


                finalColor = (temp_output_20_0 + (temp_output_20_0 * (((max(pow(temp_output_26_0, _RimPower), 0.0) *
                    _RimScale) + _RimBase) * _RimColor)));
                return finalColor;
            }
            ENDCG
        }



    }
    CustomEditor "ASEMaterialInspector"


}/*ASEBEGIN
Version=18500
512;1227;1245;1234;1823.65;406.7099;1.919404;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-1065.274,657.3109;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;22;-1068.712,468.6147;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;23;-796.2742,605.3109;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;25;-642.2742,559.3109;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-1437.115,-158.8222;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;29;-370.5317,717.0369;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-401.4155,607.6574;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-221.5317,620.0369;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;15;-1255.115,-122.8222;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;16;-1435.115,16.17792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;33;-85.98792,783.5638;Inherit;False;Property;_RimScale;RimScale;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;30;-57.98792,657.5638;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;13;-1052.116,-58.82202;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;8;-510.933,-472.6268;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;False;0.7735849,0.259078,0.259078,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-512.3615,-26.09146;Inherit;True;Property;_ReflectTex;ReflectTex;2;0;Create;True;0;0;False;0;False;-1;None;cc5ecfe6f5188534e804221bbbc3081f;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;21;-348.8705,265.818;Inherit;False;Property;_ReflectStrength;ReflectStrength;4;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-520.957,-258.6974;Inherit;True;Property;_RefractTex;RefractTex;1;0;Create;True;0;0;False;0;False;-1;None;d5e5d3f915cc3b24a935485264a86648;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-484.3076,179.3301;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;85.01208,689.5638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;79.01208,833.5638;Inherit;False;Property;_RimBase;RimBase;6;0;Create;True;0;0;False;0;False;0;0.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;249.0121,757.5638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;39.1208,-228.8176;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-60.45538,189.2766;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;39;282.9676,947.1389;Inherit;False;Property;_RimColor;RimColor;8;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;515.8142,798.2513;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;185.6155,86.58798;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;336.7733,247.2818;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;36;45.86373,996.5511;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;507.1403,90.9547;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldReflectionVector;18;-1231.759,-294.5933;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;405.5611,-228.7446;Float;False;True;-1;2;ASEMaterialInspector;100;10;Diamond;7b276a967c30e174da928091844f5fab;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;0;;0;0;Standard;0;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;740.5309,95.29842;Float;False;False;-1;2;ASEMaterialInspector;100;10;New Amplify Shader;7b276a967c30e174da928091844f5fab;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;0;;0;0;Standard;0;False;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;25;0;23;0
WireConnection;26;0;25;0
WireConnection;28;0;26;0
WireConnection;28;1;29;0
WireConnection;15;0;14;0
WireConnection;30;0;28;0
WireConnection;13;0;15;0
WireConnection;13;1;16;0
WireConnection;12;1;13;0
WireConnection;11;1;13;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;17;0;8;0
WireConnection;17;1;11;0
WireConnection;17;2;12;0
WireConnection;17;3;19;0
WireConnection;27;0;12;0
WireConnection;27;1;21;0
WireConnection;27;2;26;0
WireConnection;40;0;34;0
WireConnection;40;1;39;0
WireConnection;20;0;17;0
WireConnection;20;1;27;0
WireConnection;38;0;20;0
WireConnection;38;1;40;0
WireConnection;37;0;20;0
WireConnection;37;1;38;0
WireConnection;7;0;17;0
WireConnection;9;0;37;0
ASEEND*/
//CHKSM=35FDEE37C6D120FFD56B201AD581AEACAA88BC84
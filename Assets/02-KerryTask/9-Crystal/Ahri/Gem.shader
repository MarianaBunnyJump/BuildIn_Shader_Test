// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Gem"
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
        _RampTex("RampTex", 2D) = "white" {}

    }

    SubShader
    {
        

        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
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
                float4 ase_texcoord : TEXCOORD0;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
                #endif
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _Color;
            uniform sampler2D _RampTex;
            uniform samplerCUBE _RefractTex;
            uniform samplerCUBE _ReflectTex;
            uniform float _RefractIntensity;


            v2f vert(appdata v )
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord2.xyz = ase_worldNormal;
                float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
                o.ase_texcoord3.xyz = ase_worldTangent;
                float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
                float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
                o.ase_texcoord4.xyz = ase_worldBitangent;
                
                o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                o.ase_texcoord2.w = 0;
                o.ase_texcoord3.w = 0;
                o.ase_texcoord4.w = 0;
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

            fixed4 frag(v2f i ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
                #endif
                float2 texCoord46 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
                float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = i.ase_texcoord2.xyz;
                float3 ase_worldTangent = i.ase_texcoord3.xyz;
                float3 ase_worldBitangent = i.ase_texcoord4.xyz;
                float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
                float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
                float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
                float3 worldRefl41 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
                float3 temp_output_13_0 = reflect( -ase_worldViewDir , worldRefl41 );
                float4 texCUBENode11 = texCUBE( _RefractTex, temp_output_13_0 );
                float4 texCUBENode12 = texCUBE( _ReflectTex, temp_output_13_0 );
                float4 temp_output_44_0 = ( ( _Color * tex2D( _RampTex, texCoord46 ) ) * ( texCUBENode11 + ( texCUBENode11 * ( texCUBENode12 * _RefractIntensity ) ) ) );
                

                finalColor = temp_output_44_0;
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
                float4 ase_texcoord : TEXCOORD0;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
                #endif
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            uniform float4 _Color;
            uniform sampler2D _RampTex;
            uniform samplerCUBE _RefractTex;
            uniform samplerCUBE _ReflectTex;
            uniform float _RefractIntensity;
            uniform float _ReflectStrength;
            uniform float _RimPower;
            uniform float _RimScale;
            uniform float _RimBase;
            uniform float4 _RimColor;


            v2f vert(appdata v )
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord2.xyz = ase_worldNormal;
                float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
                o.ase_texcoord3.xyz = ase_worldTangent;
                float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
                float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
                o.ase_texcoord4.xyz = ase_worldBitangent;
                
                o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                o.ase_texcoord2.w = 0;
                o.ase_texcoord3.w = 0;
                o.ase_texcoord4.w = 0;
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

            fixed4 frag(v2f i ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                fixed4 finalColor;
                #ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
                #endif
                float2 texCoord46 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
                float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = i.ase_texcoord2.xyz;
                float3 ase_worldTangent = i.ase_texcoord3.xyz;
                float3 ase_worldBitangent = i.ase_texcoord4.xyz;
                float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
                float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
                float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
                float3 worldRefl41 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
                float3 temp_output_13_0 = reflect( -ase_worldViewDir , worldRefl41 );
                float4 texCUBENode11 = texCUBE( _RefractTex, temp_output_13_0 );
                float4 texCUBENode12 = texCUBE( _ReflectTex, temp_output_13_0 );
                float4 temp_output_44_0 = ( ( _Color * tex2D( _RampTex, texCoord46 ) ) * ( texCUBENode11 + ( texCUBENode11 * ( texCUBENode12 * _RefractIntensity ) ) ) );
                float dotResult23 = dot( ase_worldNormal , ase_worldViewDir );
                float clampResult25 = clamp( dotResult23 , 0.0 , 1.0 );
                float temp_output_26_0 = ( 1.0 - clampResult25 );
                float4 temp_output_20_0 = ( temp_output_44_0 + ( texCUBENode12 * _ReflectStrength * temp_output_26_0 ) );
                

                finalColor = ( temp_output_20_0 + ( temp_output_20_0 * ( ( ( max( pow( temp_output_26_0 , _RimPower ) , 0.0 ) * _RimScale ) + _RimBase ) * _RimColor ) ) );
                return finalColor;
            }
            ENDCG
        }

        

    }
    CustomEditor "ASEMaterialInspector"
	
	
}/*ASEBEGIN
Version=18500
910;1073;1245;1234;2696.273;1746.688;3.630644;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-1437.115,-158.8222;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;16;-1681.115,16.17792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-1044.608,471.3179;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;22;-1048.046,282.6216;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldReflectionVector;41;-1452.044,20.44489;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;15;-1255.115,-122.8222;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;23;-775.6083,419.3179;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;13;-1052.116,-58.82202;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;25;-621.6083,373.3179;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-673.3522,179.4393;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-380.7496,421.6644;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-349.8658,531.0439;Inherit;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-753.3615,-14.09146;Inherit;True;Property;_ReflectTex;ReflectTex;2;0;Create;True;0;0;False;0;False;-1;None;cc5ecfe6f5188534e804221bbbc3081f;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-345.6873,-386.7217;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-323.6299,-95.52127;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;11;-658.957,-281.6974;Inherit;True;Property;_RefractTex;RefractTex;1;0;Create;True;0;0;False;0;False;-1;None;d5e5d3f915cc3b24a935485264a86648;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;28;-200.8658,434.0439;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-65.32201,597.5707;Inherit;False;Property;_RimScale;RimScale;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;30;-37.32202,471.5707;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-68.07285,-484.5265;Inherit;True;Property;_RampTex;RampTex;9;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-74.34121,-165.1021;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;-327.6387,-572.9255;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;False;0.7735849,0.259078,0.259078,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;268.3803,-567.2498;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;142.3958,-228.9187;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-416.7727,206.7726;Inherit;False;Property;_ReflectStrength;ReflectStrength;4;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;99.67797,647.5707;Inherit;False;Property;_RimBase;RimBase;6;0;Create;True;0;0;False;0;False;0;0.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;105.678,503.5707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;269.678,571.5707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;303.6335,761.1459;Inherit;False;Property;_RimColor;RimColor;8;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;26.01879,122.4556;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;512.1165,-181.6781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;536.4802,612.2582;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;617.5262,77.07948;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;747.1772,203.3621;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldReflectionVector;18;-1231.759,-294.5933;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;37;898.1879,74.99409;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;36;66.52963,810.558;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;1030.495,72.8857;Float;False;False;-1;2;ASEMaterialInspector;100;10;New Amplify Shader;7b276a967c30e174da928091844f5fab;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;1020.193,-188.7972;Float;False;True;-1;2;ASEMaterialInspector;100;10;Gem;7b276a967c30e174da928091844f5fab;True;Unlit;0;0;Unlit;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;0;;0;0;Standard;0;0;2;True;True;False;;False;0
WireConnection;41;0;16;0
WireConnection;15;0;14;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;13;0;15;0
WireConnection;13;1;41;0
WireConnection;25;0;23;0
WireConnection;26;0;25;0
WireConnection;12;1;13;0
WireConnection;42;0;12;0
WireConnection;42;1;19;0
WireConnection;11;1;13;0
WireConnection;28;0;26;0
WireConnection;28;1;29;0
WireConnection;30;0;28;0
WireConnection;47;1;46;0
WireConnection;17;0;11;0
WireConnection;17;1;42;0
WireConnection;45;0;8;0
WireConnection;45;1;47;0
WireConnection;43;0;11;0
WireConnection;43;1;17;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;27;0;12;0
WireConnection;27;1;21;0
WireConnection;27;2;26;0
WireConnection;44;0;45;0
WireConnection;44;1;43;0
WireConnection;40;0;34;0
WireConnection;40;1;39;0
WireConnection;20;0;44;0
WireConnection;20;1;27;0
WireConnection;38;0;20;0
WireConnection;38;1;40;0
WireConnection;37;0;20;0
WireConnection;37;1;38;0
WireConnection;9;0;37;0
WireConnection;7;0;44;0
ASEEND*/
//CHKSM=D92AEF1DADE36A3F75F6A51BD81CA334DAEBA055
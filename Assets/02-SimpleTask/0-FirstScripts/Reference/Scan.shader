// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_RimMin("RimMin", Range( -1 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 2)) = 0
		_FlowEmiss("FlowEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0
		_Vector1("Vector 1", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _RimMin;
		uniform float _RimMax;
		uniform sampler2D _TextureSample0;
		SamplerState sampler_TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _TexPower;
		uniform float _InnerAlpha;
		uniform sampler2D _FlowEmiss;
		SamplerState sampler_FlowEmiss;
		uniform float2 _Vector1;
		uniform float2 _Speed;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult37 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult38 = clamp( dotResult37 , 0.0 , 1.0 );
			float smoothstepResult21 = smoothstep( _RimMin , _RimMax , ( 1.0 - clampResult38 ));
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float clampResult77 = clamp( ( smoothstepResult21 + pow( tex2D( _TextureSample0, uv_TextureSample0 ).r , _TexPower ) ) , 0.0 , 1.0 );
			float FinalRimAlpha93 = clampResult77;
			float2 appendResult59 = (float2(0.0 , ase_worldPos.y));
			float3 objToWorld61 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float2 appendResult64 = (float2(objToWorld61.x , objToWorld61.y));
			float4 tex2DNode48 = tex2D( _FlowEmiss, ( ( ( appendResult59 - appendResult64 ) * _Vector1 ) + ( _Speed * _Time.y ) ) );
			float FlowAlpha85 = ( 0.5 * tex2DNode48.a );
			float clampResult69 = clamp( ( FinalRimAlpha93 + _InnerAlpha + FlowAlpha85 ) , 0.0 , 1.0 );
			float3 temp_cast_0 = (clampResult69).xxx;
			o.Emission = temp_cast_0 + 1E-5;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noforwardadd 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1385;362;1045;911;-337.0501;-850.1844;1.3;False;False
Node;AmplifyShaderEditor.CommentaryNode;90;-1933.166,1941.706;Inherit;False;2186.844;712.7471;流光;18;63;56;61;64;59;55;52;82;60;53;79;50;71;48;72;85;70;83;;0.4009434,1,0.5168623,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;95;-1937.578,618.2614;Inherit;False;1785.311;1272.707;边缘光;20;39;21;74;40;41;38;35;36;37;76;77;73;75;46;43;42;47;44;93;91;;0.0235849,0.481529,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;63;-1883.166,2246.235;Inherit;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;56;-1696.253,2022.571;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;61;-1697.16,2247.495;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;35;-1863.3,1324.962;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;36;-1887.578,1151.127;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;64;-1454.287,2277.75;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1458.975,2050.723;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;37;-1638.161,1264.167;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;60;-1258.881,2159.025;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;38;-1476.419,1255.789;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;52;-1067.157,2380.915;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;False;0;False;0,0;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;55;-1061.532,2543.453;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;82;-1268.22,2333.564;Inherit;False;Property;_Vector1;Vector 1;11;0;Create;True;0;0;False;0;False;0,0;1,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-975.7339,2154.887;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-849.6673,2431.136;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;73;-1648.333,1534.061;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;066674048bbb1e64e8cdcc6c3b4abbeb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1369.82,1398.984;Inherit;False;Property;_RimMin;RimMin;2;0;Create;True;0;0;False;0;False;0;0.06;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1541.295,1774.968;Inherit;False;Property;_TexPower;TexPower;9;0;Create;True;0;0;False;0;False;0;1.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-1295.6,1255.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1328.896,1507.309;Inherit;False;Property;_RimMax;RimMax;3;0;Create;True;0;0;False;0;False;0;1.41;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-779.9572,2188.042;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-976.1744,1352.97;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;74;-932.2562,1726.828;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;-1509.557,847.143;Inherit;False;Property;_RimColor;Rim Color;5;0;Create;True;0;0;False;0;False;0,0,0,0;0.2687624,0.2028302,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-605.8604,2157.184;Inherit;True;Property;_FlowEmiss;FlowEmiss;7;0;Create;True;0;0;False;0;False;-1;None;7587de2e3bec8bf4d973109524ccc6b1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-457.0183,2062.673;Inherit;False;Constant;_FlowIntensity;FlowIntensity;13;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-784.9989,1354.141;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1480.187,1028.094;Inherit;False;Property;_RimIntensity;Rim Intensity;6;0;Create;True;0;0;False;0;False;0;4.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-200.7627,2290.171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;77;-629.7104,1350.135;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1155.094,855.2703;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;42;-1530.816,668.2614;Inherit;False;Property;_InnerColor;Inner Color;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.9058824,0.235294,0.312692,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-480.6969,1364.296;Inherit;False;FinalRimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-572.0984,860.523;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-216.8056,2053.02;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;29.67813,2331.41;Inherit;False;FlowAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;79.31458,1608.544;Inherit;False;85;FlowAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-376.2672,872.1104;Inherit;False;FinalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;68.1358,1434.276;Inherit;False;93;FinalRimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;75.84138,1515.271;Inherit;False;Property;_InnerAlpha;InnerAlpha;10;0;Create;True;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;29.65108,1991.706;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;184.1891,1194.868;Inherit;False;91;FinalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;135.5177,1300.095;Inherit;False;83;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;295.7274,1497.164;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;442.1788,1202.903;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;69;479.8516,1499.563;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;718.6223,1199.575;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;61;0;63;0
WireConnection;64;0;61;1
WireConnection;64;1;61;2
WireConnection;59;1;56;2
WireConnection;37;0;36;0
WireConnection;37;1;35;0
WireConnection;60;0;59;0
WireConnection;60;1;64;0
WireConnection;38;0;37;0
WireConnection;79;0;60;0
WireConnection;79;1;82;0
WireConnection;53;0;52;0
WireConnection;53;1;55;0
WireConnection;39;0;38;0
WireConnection;50;0;79;0
WireConnection;50;1;53;0
WireConnection;21;0;39;0
WireConnection;21;1;40;0
WireConnection;21;2;41;0
WireConnection;74;0;73;1
WireConnection;74;1;75;0
WireConnection;48;1;50;0
WireConnection;76;0;21;0
WireConnection;76;1;74;0
WireConnection;72;0;71;0
WireConnection;72;1;48;4
WireConnection;77;0;76;0
WireConnection;47;0;43;0
WireConnection;47;1;46;0
WireConnection;93;0;77;0
WireConnection;44;0;42;0
WireConnection;44;1;47;0
WireConnection;44;2;77;0
WireConnection;70;0;71;0
WireConnection;70;1;48;0
WireConnection;85;0;72;0
WireConnection;91;0;44;0
WireConnection;83;0;70;0
WireConnection;68;0;94;0
WireConnection;68;1;78;0
WireConnection;68;2;86;0
WireConnection;66;0;92;0
WireConnection;66;1;84;0
WireConnection;69;0;68;0
WireConnection;0;2;66;0
WireConnection;0;9;69;0
WireConnection;0;15;69;0
ASEEND*/
//CHKSM=04477EB869B4E795082A39FE0AEC15057EB8C2D5
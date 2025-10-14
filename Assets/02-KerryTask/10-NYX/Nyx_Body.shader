// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nyx_Body"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimPower("RimPower", Float) = 5
		_RimScale("RimScale", Float) = 0
		_RimBias("RimBias", Float) = 0
		[HDR]_RimColor("RimColor", Color) = (1,0.7215686,0.4823529,0)
		_EmissMap("EmissMap", 2D) = "white" {}
		_FlowTillingOffset("FlowTillingOffset", Vector) = (1,1,0,0)
		[HDR]_FlowLightColor("FlowLightColor", Color) = (0.9150943,0.6289666,0.08201315,0)
		_FlowRimScale("FlowRimScale", Float) = 2
		_FlowRimBias("FlowRimBias", Float) = 0
		_NebulaTex("NebulaTex", 2D) = "white" {}
		_NebulaTilling("NebulaTilling", Vector) = (1,1,0,0)
		_NebulaDistort("NebulaDistort", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
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
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _FlowLightColor;
		uniform sampler2D _EmissMap;
		SamplerState sampler_EmissMap;
		uniform float4 _FlowTillingOffset;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _FlowRimScale;
		uniform float _FlowRimBias;
		uniform float4 _RimColor;
		uniform float _RimPower;
		uniform float _RimScale;
		uniform float _RimBias;
		uniform sampler2D _NebulaTex;
		uniform float _NebulaDistort;
		uniform float2 _NebulaTilling;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 NormalWorld3 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult6 = dot( NormalWorld3 , ase_worldViewDir );
			float NdotV7 = dotResult6;
			float3 objToWorld29 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner35 = ( 1.0 * _Time.y * (_FlowTillingOffset).zw + ( ( (NdotV7*0.5 + 0.5) + float2( 0,0 ) + (( ase_worldPos - objToWorld29 )).xy ) * (_FlowTillingOffset).xy ));
			float FlowLight37 = tex2D( _EmissMap, panner35 ).r;
			float4 FlowLightColor47 = ( _FlowLightColor * ( FlowLight37 * ( ( ( 1.0 - NdotV7 ) * _FlowRimScale ) + _FlowRimBias ) ) );
			float clampResult13 = clamp( NdotV7 , 0.0 , 1.0 );
			float4 RimColor24 = ( _RimColor * ( ( pow( ( 1.0 - clampResult13 ) , _RimPower ) * _RimScale ) + _RimBias ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorld60 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToWorld62 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 objToWorldDir72 = normalize( mul( unity_ObjectToWorld, float4( NormalWorld3, 0 ) ).xyz );
			float4 NebulaColor68 = tex2D( _NebulaTex, ( ( (( objToWorld60 - objToWorld62 )).xy + ( (objToWorldDir72).xy * _NebulaDistort ) ) * _NebulaTilling ) );
			o.Emission = ( ( FlowLightColor47 + RimColor24 + ( NebulaColor68 * FlowLight37 ) ) + ( pow( NebulaColor68 , 5.0 ) * pow( FlowLight37 , 3.0 ) * 10.0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
1029;582;1245;843;579.2617;-1097.986;2.533484;True;False
Node;AmplifyShaderEditor.CommentaryNode;8;-1575.497,-416.4459;Inherit;False;853.2665;315.4894;NormalMap;3;3;2;1;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-1525.497,-366.4459;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;False;-1;None;dbd1b8437e537fd429dd0cb218660156;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;2;-1206.837,-331.6306;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;3;-978.6772,-327.1367;Inherit;False;NormalWorld;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;10;-1578.115,19.50935;Inherit;False;697.436;330.8893;NdotV;4;7;9;5;6;NdotV;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-1517.243,162.3986;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;9;-1528.115,69.50932;Inherit;False;3;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1581.177,1059.579;Inherit;False;1972.156;786.1101;FlowLight;14;34;33;40;37;36;35;31;42;30;28;29;27;41;43;FlowLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;6;-1280.52,93.75091;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;27;-1470.48,1284.965;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1104.678,90.03748;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;29;-1483.356,1475.052;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-1261.355,1405.052;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1316.132,1161.111;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;43;-1120.803,1153.177;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;30;-1127.355,1404.052;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;40;-1103.365,1589.721;Inherit;False;Property;_FlowTillingOffset;FlowTillingOffset;6;0;Create;True;0;0;False;0;False;1,1,0,0;0.5,0.5,0,0.3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;77;-1537.176,2713.029;Inherit;False;1691.333;746.9531;NebulaColor;15;59;60;62;61;63;72;73;74;75;70;76;66;64;67;68;NebulaColor;0.6987559,0.1530794,0.754717,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1458.535,3197.86;Inherit;False;3;NormalWorld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1580.309,480.6223;Inherit;False;1385.101;465.9999;RimColor;12;19;13;11;14;18;22;16;15;17;21;23;24;RimColor;1,0.6731483,0.06132078,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;33;-889.1786,1538.842;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;59;-1487.176,2763.918;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-882.4039,1352.06;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-1530.309,687.7646;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;62;-1284.385,2947.331;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;72;-1276.053,3192.988;Inherit;False;Object;World;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;56;-1564.94,1964.646;Inherit;False;1667.669;649.7383;FlowLightColor;11;47;55;46;45;44;53;51;54;50;52;49;FlowLightColor;0.07834575,0.8962264,0,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;60;-1290.231,2763.029;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-690.0205,1468.996;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;34;-888.3787,1664.143;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1066.563,3343.982;Inherit;False;Property;_NebulaDistort;NebulaDistort;12;0;Create;True;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-1032.208,2884.49;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-1514.94,2241.302;Inherit;False;7;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;35;-446.5326,1452.936;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;13;-1345.592,705.8491;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;73;-1047.985,3230.569;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;36;-261.6805,1425.102;Inherit;True;Property;_EmissMap;EmissMap;5;0;Create;True;0;0;False;0;False;-1;None;6e9e3841a0552a34cb7c38b3628da853;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-1362.025,2353.542;Inherit;False;Property;_FlowRimScale;FlowRimScale;8;0;Create;True;0;0;False;0;False;2;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1214.463,800.6221;Inherit;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;False;0;False;5;4.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;63;-894.3087,2886.257;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-894.9849,3275.569;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;50;-1341.941,2245.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;-1212.633,709.0764;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1144.855,2275.713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;18;-1068.463,715.6221;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;66;-713.076,3058.366;Inherit;False;Property;_NebulaTilling;NebulaTilling;11;0;Create;True;0;0;False;0;False;1,1;0.8,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;52.91947,1455.003;Inherit;False;FlowLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1172.472,2391.201;Inherit;False;Property;_FlowRimBias;FlowRimBias;9;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1061.463,830.6221;Inherit;False;Property;_RimScale;RimScale;2;0;Create;True;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-706.0529,2890.342;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-900.463,827.6221;Inherit;False;Property;_RimBias;RimBias;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-1056.341,2153.718;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-555.1079,2901.281;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-908.463,712.6221;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-986.6854,2295.796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-772.463,530.6223;Inherit;False;Property;_RimColor;RimColor;4;1;[HDR];Create;True;0;0;False;0;False;1,0.7215686,0.4823529,0;1,0.6777802,0.4009434,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-750.463,723.6221;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;67;-387.7371,2903.311;Inherit;True;Property;_NebulaTex;NebulaTex;10;0;Create;True;0;0;False;0;False;-1;None;bc01046a9047c8c4bb18d0dd8d8cd171;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-801.3093,2225.13;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-877.8168,2014.646;Inherit;False;Property;_FlowLightColor;FlowLightColor;7;1;[HDR];Create;True;0;0;False;0;False;0.9150943,0.6289666,0.08201315,0;0.764151,0.5012355,0.2054557,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-69.84241,2905.458;Inherit;False;NebulaColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-613.2127,2181.126;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;87;606.4843,1746.242;Inherit;False;602.9988;425.1013;Blinking;6;80;81;82;85;84;83;Blinking;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-559.6536,698.0779;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;656.4843,1796.242;Inherit;False;68;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-465.8102,2178.269;Inherit;False;FlowLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;680.3224,1929.065;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-419.2076,700.5626;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;671.2659,1604.275;Inherit;False;37;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;651.4278,1514.452;Inherit;False;68;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;84;874.4832,1941.343;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;840.5802,1370.977;Inherit;False;47;FlowLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;886.5767,1578.248;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;853.5402,1454.509;Inherit;False;24;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;85;878.4832,2055.343;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;82;885.4832,1807.343;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;1101.657,1436.985;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;1047.483,1914.343;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;1285.487,1532.575;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1470.199,1391.898;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Nyx_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;1;0
WireConnection;3;0;2;0
WireConnection;6;0;9;0
WireConnection;6;1;5;0
WireConnection;7;0;6;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;43;0;41;0
WireConnection;30;0;28;0
WireConnection;33;0;40;0
WireConnection;42;0;43;0
WireConnection;42;2;30;0
WireConnection;72;0;70;0
WireConnection;60;0;59;0
WireConnection;31;0;42;0
WireConnection;31;1;33;0
WireConnection;34;0;40;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;35;0;31;0
WireConnection;35;2;34;0
WireConnection;13;0;11;0
WireConnection;73;0;72;0
WireConnection;36;1;35;0
WireConnection;63;0;61;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;50;0;49;0
WireConnection;14;0;13;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;18;0;14;0
WireConnection;18;1;15;0
WireConnection;37;0;36;1
WireConnection;76;0;63;0
WireConnection;76;1;74;0
WireConnection;64;0;76;0
WireConnection;64;1;66;0
WireConnection;19;0;18;0
WireConnection;19;1;16;0
WireConnection;53;0;51;0
WireConnection;53;1;54;0
WireConnection;22;0;19;0
WireConnection;22;1;17;0
WireConnection;67;1;64;0
WireConnection;46;0;44;0
WireConnection;46;1;53;0
WireConnection;68;0;67;0
WireConnection;55;0;45;0
WireConnection;55;1;46;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;47;0;55;0
WireConnection;24;0;23;0
WireConnection;84;0;80;0
WireConnection;78;0;69;0
WireConnection;78;1;79;0
WireConnection;82;0;81;0
WireConnection;57;0;48;0
WireConnection;57;1;39;0
WireConnection;57;2;78;0
WireConnection;83;0;82;0
WireConnection;83;1;84;0
WireConnection;83;2;85;0
WireConnection;86;0;57;0
WireConnection;86;1;83;0
WireConnection;0;2;86;0
ASEEND*/
//CHKSM=0A983F2CA23497ED3F166E567A8AF815D9EB7CB3
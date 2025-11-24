// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Terrain"
{
	Properties
	{
		_FogColor("FogColor", Color) = (0,0,0,0)
		_FogStart("FogStart", Float) = 0
		_FogEnd("FogEnd", Float) = 700
		_FogHeightStart("Fog Height Start", Float) = 0
		_FogHeightEnd("Fog Height End", Float) = 100
		_BaseColor("BaseColor", Color) = (0.5566038,0.5566038,0.5566038,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_SunFogRange("Sun Fog Range", Float) = 10
		_SunFogintensity("Sun Fog intensity", Float) = 1
		_SunFogColor("SunFogColor", Color) = (0.9716981,0.7376654,0.1695888,0)
		_FogIntensity("Fog Intensity", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
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

		uniform float _Smoothness;
		uniform float4 _BaseColor;
		uniform float4 _FogColor;
		uniform float4 _SunFogColor;
		uniform float _SunFogRange;
		uniform float _SunFogintensity;
		uniform float _FogEnd;
		uniform float _FogStart;
		uniform float _FogHeightEnd;
		uniform float _FogHeightStart;
		uniform float _FogIntensity;


		float3 ACESToneMap43( float3 LinearColor )
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return
			saturate((LinearColor*(a*LinearColor+b))/ (LinearColor*(c*LinearColor+d)+e));
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldNormal = i.worldNormal;
			Unity_GlossyEnvironmentData g2 = UnityGlossyEnvironmentSetup( _Smoothness, data.worldViewDir, ase_worldNormal, float3(0,0,0));
			float3 indirectSpecular2 = UnityGI_IndirectSpecular( data, 1.0, ase_worldNormal, g2 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult46 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult50 = clamp( pow( (dotResult46*0.5 + 0.5) , _SunFogRange ) , 0.0 , 1.0 );
			float SunFog57 = ( clampResult50 * _SunFogintensity );
			float4 lerpResult59 = lerp( _FogColor , _SunFogColor , SunFog57);
			float temp_output_10_0_g7 = _FogEnd;
			float clampResult8_g7 = clamp( ( ( temp_output_10_0_g7 - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( temp_output_10_0_g7 - _FogStart ) ) , 0.0 , 1.0 );
			float FogDistance25 = ( 1.0 - clampResult8_g7 );
			float temp_output_10_0_g6 = _FogHeightEnd;
			float clampResult8_g6 = clamp( ( ( temp_output_10_0_g6 - ase_worldPos.y ) / ( temp_output_10_0_g6 - _FogHeightStart ) ) , 0.0 , 1.0 );
			float FogHeight37 = ( 1.0 - ( 1.0 - clampResult8_g6 ) );
			float clampResult42 = clamp( ( ( FogDistance25 * FogHeight37 ) * _FogIntensity ) , 0.0 , 1.0 );
			float4 lerpResult17 = lerp( ( float4( indirectSpecular2 , 0.0 ) * _BaseColor ) , lerpResult59 , clampResult42);
			float3 LinearColor43 = ( lerpResult17 * lerpResult17 ).rgb;
			float3 localACESToneMap43 = ACESToneMap43( LinearColor43 );
			c.rgb = sqrt( localACESToneMap43 );
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
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
1355;246;1168;2084;4819.191;1733.591;4.77166;True;False
Node;AmplifyShaderEditor.CommentaryNode;56;-3096.463,1015.197;Inherit;False;1714.466;547.4655;SunFog;11;53;44;51;52;50;48;49;47;46;45;57;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;44;-3046.463,1065.197;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;53;-2827.507,1098.872;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;45;-2946.061,1250.92;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;26;-2567.004,-304.894;Inherit;False;1101.068;623.9805;FogDistance_线性数值重映射;8;22;6;25;9;8;10;7;55;FogDistance;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;30;-3012.257,341.37;Inherit;False;1492.543;629.6133;FogDistance_高度雾;6;37;34;33;32;39;54;FogDistance;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;46;-2634.997,1134.662;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;32;-2702.037,443.3858;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;34;-2687.952,746.8;Inherit;False;Property;_FogHeightEnd;Fog Height End;4;0;Create;True;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;10;-2517.004,-91.26808;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;8;-2459.514,-254.894;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;33;-2684.185,646.3994;Inherit;False;Property;_FogHeightStart;Fog Height Start;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;54;-2438.309,550.4862;Inherit;False;FogLinear;10;;6;681391ee5319e434fa26eb030e6faeec;0;3;12;FLOAT;500;False;11;FLOAT;0;False;10;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;47;-2448.997,1133.662;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2454.997,1300.662;Inherit;False;Property;_SunFogRange;Sun Fog Range;7;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2200.587,-41.21079;Inherit;False;Property;_FogStart;FogStart;1;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2204.354,59.18972;Inherit;False;Property;_FogEnd;FogEnd;2;0;Create;True;0;0;False;0;False;700;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-2211.957,-162.5889;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;48;-2226.997,1217.662;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-2150.623,564.2386;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;55;-1693.455,-122.6078;Inherit;False;FogLinear;10;;7;681391ee5319e434fa26eb030e6faeec;0;3;12;FLOAT;500;False;11;FLOAT;0;False;10;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1963.059,555.7686;Inherit;False;FogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2099.997,1418.662;Inherit;False;Property;_SunFogintensity;Sun Fog intensity;8;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;50;-2039.996,1243.662;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1751.608,-61.33163;Inherit;False;FogDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-1363.686,284.8759;Inherit;False;896.4102;916.8116;FogCombine;11;17;42;59;58;41;60;18;27;40;63;64;FogCombine;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-1337.743,843.2932;Inherit;False;25;FogDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1345.202,933.0878;Inherit;False;37;FogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1824.996,1310.662;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1651.507,1304.35;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1249.408,-723.8709;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1342.614,1026.744;Inherit;False;Property;_FogIntensity;Fog Intensity;14;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1150.699,855.6667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1017.715,890.9432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;58;-1313.686,523.769;Inherit;False;Property;_SunFogColor;SunFogColor;9;0;Create;True;0;0;False;0;False;0.9716981,0.7376654,0.1695888,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;60;-1288.701,706.209;Inherit;False;57;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-938.9435,-568.8589;Inherit;False;Property;_BaseColor;BaseColor;5;0;Create;True;0;0;False;0;False;0.5566038,0.5566038,0.5566038,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IndirectSpecularLight;2;-961.9435,-739.8593;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;18;-1311.782,334.8759;Inherit;False;Property;_FogColor;FogColor;0;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;59;-1030.38,494.8873;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-698.3199,-624.0309;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;42;-892.4924,863.6427;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;17;-658.7014,664.9332;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-337.5918,723.3571;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;43;-178.4813,706.9357;Inherit;False;float a = 2.51f@$float b = 0.03f@$float c = 2.43f@$float d = 0.59f@$float e = 0.14f@$return$saturate((LinearColor*(a*LinearColor+b))/ (LinearColor*(c*LinearColor+d)+e))@;3;False;1;True;LinearColor;FLOAT3;0,0,0;In;;Inherit;False;ACESToneMap;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;65;59.57057,658.4459;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;22;-2507.411,89.36588;Inherit;False;Constant;_FogPosition;FogPosition;11;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;19;286.0696,1062.71;Inherit;True;Property;_FogGradient;FogGradient;13;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;20;115.0325,1059.616;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-101.4945,1067.851;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;427.0034,263.8463;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;53;0;44;0
WireConnection;46;0;53;0
WireConnection;46;1;45;0
WireConnection;54;12;32;2
WireConnection;54;11;33;0
WireConnection;54;10;34;0
WireConnection;47;0;46;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;39;0;54;0
WireConnection;55;12;9;0
WireConnection;55;11;7;0
WireConnection;55;10;6;0
WireConnection;37;0;39;0
WireConnection;50;0;48;0
WireConnection;25;0;55;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;57;0;51;0
WireConnection;41;0;27;0
WireConnection;41;1;40;0
WireConnection;64;0;41;0
WireConnection;64;1;63;0
WireConnection;2;1;5;0
WireConnection;59;0;18;0
WireConnection;59;1;58;0
WireConnection;59;2;60;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;42;0;64;0
WireConnection;17;0;3;0
WireConnection;17;1;59;0
WireConnection;17;2;42;0
WireConnection;61;0;17;0
WireConnection;61;1;17;0
WireConnection;43;0;61;0
WireConnection;65;0;43;0
WireConnection;19;1;20;0
WireConnection;20;1;21;0
WireConnection;0;13;65;0
ASEEND*/
//CHKSM=5C0B11DA4C77AE24B120FACA75F1714488B727C1
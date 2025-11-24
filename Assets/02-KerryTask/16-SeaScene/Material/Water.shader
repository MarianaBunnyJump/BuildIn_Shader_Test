// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_WorldNormal("WorldNormal", 2D) = "white" {}
		_NormalTilling("NormalTilling", Float) = 8
		_NormalIntensity("NormalIntensity", Float) = 1
		_BlinkSpeed("BlinkSpeed", Float) = 0.1
		_WaterSpeed("WaterSpeed", Float) = 0
		_WaterNoise("WaterNoise", Float) = 0.5
		_SpecSmoothness("SpecSmoothness", Range( 0.001 , 1)) = 0.1
		_SpecTint("SpecTint", Color) = (1,1,1,0)
		_SpecIntensity("SpecIntensity", Float) = 1
		_SpecStart("SpecStart", Float) = 0
		_SpecEnd("SpecEnd", Float) = 200
		_UnderWater("UnderWater", 2D) = "white" {}
		_UnderWaterTilling("UnderWaterTilling", Float) = 4
		_WaterDepth("WaterDepth", Float) = -1
		_BlinkNoise("BlinkNoise", Float) = 5
		_BlinkTilling("BlinkTilling", Float) = 8
		_BlinkThreshold("BlinkThreshold", Float) = 2
		_BilnkIntensity("BilnkIntensity", Float) = 5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
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

		uniform sampler2D _UnderWater;
		uniform float _UnderWaterTilling;
		uniform sampler2D _WorldNormal;
		uniform float _NormalTilling;
		uniform float _WaterSpeed;
		uniform float _NormalIntensity;
		uniform float _WaterDepth;
		uniform sampler2D _ReflectionTex;
		uniform float _WaterNoise;
		uniform float _BlinkTilling;
		uniform float _BlinkSpeed;
		uniform float _BlinkNoise;
		uniform float _BlinkThreshold;
		uniform float _BilnkIntensity;
		uniform float _SpecSmoothness;
		uniform float4 _SpecTint;
		uniform float _SpecIntensity;
		uniform float _SpecEnd;
		uniform float _SpecStart;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_5_0 = ( (ase_worldPos).xz / _NormalTilling );
			float temp_output_10_0 = ( _Time.y * 0.1 * _WaterSpeed );
			float2 temp_output_18_0 = ( (( tex2D( _WorldNormal, ( temp_output_5_0 + temp_output_10_0 ) ) + float4( UnpackScaleNormal( tex2D( _WorldNormal, ( ( temp_output_5_0 * 1.5 ) + ( temp_output_10_0 * -1.0 ) ) ), _NormalIntensity ) , 0.0 ) )).rg * 0.5 );
			float dotResult30 = dot( temp_output_18_0 , temp_output_18_0 );
			float3 appendResult34 = (float3(temp_output_18_0 , sqrt( ( 1.0 - dotResult30 ) )));
			float3 WorldNormal36 = (WorldNormalVector( i , appendResult34 ));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 paralaxOffset102 = ParallaxOffset( 0 , _WaterDepth , ase_worldViewDir );
			float4 UnderWaterColor88 = tex2D( _UnderWater, ( ( ( (ase_worldPos).xz / _UnderWaterTilling ) + ( (WorldNormal36).xy * 0.1 ) ) + paralaxOffset102 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos45 = UnityObjectToClipPos( ase_vertex3Pos );
			float2 temp_output_119_0 = ( (ase_worldPos).xz / _BlinkTilling );
			float temp_output_118_0 = ( _Time.y * 0.1 * _BlinkSpeed );
			float2 temp_output_131_0 = ( (( UnpackNormal( tex2D( _WorldNormal, ( temp_output_119_0 + temp_output_118_0 ) ) ) + UnpackNormal( tex2D( _WorldNormal, ( ( temp_output_119_0 * 1.5 ) + ( temp_output_118_0 * -1.0 ) ) ) ) )).xy * 0.5 );
			float dotResult132 = dot( temp_output_131_0 , temp_output_131_0 );
			float3 appendResult135 = (float3(temp_output_131_0 , sqrt( ( 1.0 - dotResult132 ) )));
			float3 WorldNormalBlink137 = (WorldNormalVector( i , appendResult135 ));
			float4 temp_cast_1 = (_BlinkThreshold).xxxx;
			float4 ReflectBlink152 = ( max( ( tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( (WorldNormalBlink137).xz * _BlinkNoise ) ) ) - temp_cast_1 ) , float4( 0,0,0,0 ) ) * _BilnkIntensity );
			float4 ReflectColor50 = ( tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( ( (WorldNormal36).xz / ( 1.0 + unityObjectToClipPos45.w ) ) * _WaterNoise ) ) ) + ReflectBlink152 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult91 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult93 = clamp( dotResult91 , 0.0 , 1.0 );
			float temp_output_94_0 = ( 1.0 - clampResult93 );
			float clampResult109 = clamp( ( temp_output_94_0 + 0.2 ) , 0.0 , 1.0 );
			float4 lerpResult96 = lerp( UnderWaterColor88 , ( ReflectColor50 * clampResult109 ) , temp_output_94_0);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult55 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult57 = dot( WorldNormal36 , normalizeResult55 );
			float clampResult80 = clamp( ( ( _SpecEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _SpecEnd - _SpecStart ) ) , 0.0 , 1.0 );
			float4 SpecColor68 = ( ( ( pow( max( dotResult57 , 0.0 ) , ( _SpecSmoothness * 256.0 ) ) * _SpecTint ) * _SpecIntensity ) * clampResult80 );
			c.rgb = ( lerpResult96 + SpecColor68 ).rgb;
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
				float4 screenPos : TEXCOORD1;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
1291;98;1168;1127;3595.189;-1680.789;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;110;-6640.731,-1293.568;Inherit;False;2823.515;842.6684;WorldNormalBlink;26;137;136;135;134;133;132;131;130;129;128;127;126;125;124;122;121;120;119;118;117;116;115;114;113;112;111;WorldNormalBlink;0,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;111;-6518.155,-1243.568;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;116;-6348.292,-1239.833;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-6580.383,-774.0515;Inherit;False;Constant;_Float7;Float 7;1;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;114;-6590.731,-881.9481;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-6577.4,-676.137;Inherit;False;Property;_BlinkSpeed;BlinkSpeed;4;0;Create;True;0;0;False;0;False;0.1;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-6383.876,-1081.31;Inherit;False;Property;_BlinkTilling;BlinkTilling;16;0;Create;True;0;0;False;0;False;8;5.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-6146.971,-839.8995;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;119;-6191.155,-1173.682;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-6170.971,-566.8994;Inherit;False;Constant;_Float9;Float 9;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-6365.853,-852.1005;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-5980.971,-703.8995;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-5969.971,-886.8995;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;37;-3728.545,-1383.963;Inherit;False;2823.515;842.6684;WorldNormal;27;25;22;28;26;18;16;30;32;33;34;2;10;9;8;11;5;6;4;3;24;23;21;20;35;36;31;42;WorldNormal;0.08962262,0.4815679,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-3605.969,-1333.963;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-5796.042,-810.1085;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-5939.804,-1171.022;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-3668.197,-864.4468;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-3471.69,-1171.705;Inherit;False;Property;_NormalTilling;NormalTilling;2;0;Create;True;0;0;False;0;False;8;7.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;8;-3678.545,-972.3434;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;-5604.395,-1182.641;Inherit;True;Property;_WaterNormal;WaterNormal;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;42;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-3665.214,-766.5322;Inherit;False;Property;_WaterSpeed;WaterSpeed;5;0;Create;True;0;0;False;0;False;0;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;4;-3436.106,-1330.228;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;127;-5606.088,-891.7328;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;False;42;None;None;True;0;False;white;Auto;True;Instance;42;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-5221.822,-1047.883;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3234.785,-930.2948;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;5;-3278.969,-1264.077;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3453.667,-942.4958;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-3258.785,-657.2947;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;130;-5081.031,-1036.19;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-3068.785,-794.2948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-5140.216,-879.4157;Inherit;False;Constant;_Float10;Float 10;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3057.785,-977.2948;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2;-3027.618,-1261.417;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-4921.031,-1006.19;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2965.692,-1093.201;Inherit;False;Property;_NormalIntensity;NormalIntensity;3;0;Create;True;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-2883.855,-900.5038;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;132;-4754.216,-950.4159;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-2683.333,-959.1281;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;42;None;None;True;0;False;white;Auto;True;Instance;42;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-2706.209,-1271.036;Inherit;True;Property;_WorldNormal;WorldNormal;1;0;Create;True;0;0;False;0;False;-1;1f030ebddc325f64283e1f27e297b79d;1f030ebddc325f64283e1f27e297b79d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2309.636,-1138.278;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;133;-4636.216,-927.4158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;16;-2168.845,-1126.585;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2228.03,-969.811;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;134;-4493.216,-926.4158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-4369.216,-1026.416;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2008.845,-1096.585;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;136;-4231.217,-1021.416;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;30;-1842.03,-1040.811;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;138;-6530.38,-267.3509;Inherit;False;1959.079;806.9978;ReflectBlink;14;157;156;152;155;153;154;151;146;149;147;143;142;148;150;ReflectBlink;0.28344,0.9056604,0.2264151,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-4041.216,-1021.416;Inherit;False;WorldNormalBlink;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1724.03,-1017.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-6519.077,22.52002;Inherit;False;137;WorldNormalBlink;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;33;-1581.03,-1016.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1457.03,-1116.811;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;146;-6306.312,-188.1575;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;147;-6269.137,171.416;Inherit;False;Property;_BlinkNoise;BlinkNoise;15;0;Create;True;0;0;False;0;False;5;1.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;143;-6271.515,61.82155;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-6070.123,94.58939;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;149;-6091.785,-163.5635;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;49;-3720.854,-417.1202;Inherit;False;1883.046;699.8799;ReflectColor;16;50;160;1;19;40;13;43;12;17;46;39;47;45;38;44;159;ReflectColor;0.28344,0.9056604,0.2264151,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;35;-1319.03,-1111.811;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-5895.053,-39.85357;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;69;-3711.367,398.8983;Inherit;False;1969.958;1188.266;SpecColor;18;68;82;65;63;66;59;64;61;58;60;62;57;81;56;55;54;52;53;SpecColor;0.772549,0.360157,0,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;44;-3670.854,64.95959;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1129.03,-1111.811;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;53;-3661.367,654.8983;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;52;-3614.521,479.5223;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;47;-3428.854,-43.04043;Inherit;False;Constant;_Float4;Float 4;6;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-5604.752,390.8512;Inherit;False;Property;_BlinkThreshold;BlinkThreshold;17;0;Create;True;0;0;False;0;False;2;1.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;45;-3486.854,64.95959;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;151;-5766.758,-77.84222;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-3502.013,-191.1411;Inherit;False;36;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;39;-3324.013,-193.1412;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;154;-5407.752,233.851;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-3411.367,564.8983;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;106;-3690.141,1712.796;Inherit;False;1513.062;971.9382;UnderWater;15;97;84;86;98;100;85;99;87;101;105;102;103;104;83;88;UnderWater;1,0.9347095,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-3255.854,0.9595828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-3647.92,2110.208;Inherit;False;36;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;12;-3097.81,-367.1202;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;43;-3097.854,-123.0405;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;84;-3613.526,1762.796;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-3104.635,9.453133;Inherit;False;Property;_WaterNoise;WaterNoise;6;0;Create;True;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-5387.149,407.987;Inherit;False;Property;_BilnkIntensity;BilnkIntensity;18;0;Create;True;0;0;False;0;False;5;4.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-3468.498,1063.164;Inherit;False;1234;398;线性雾效的计算，做高光的衰减渐隐处理;9;80;79;78;77;76;75;73;74;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-3292.367,448.8983;Inherit;False;36;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;55;-3267.367,559.8983;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;155;-5264.752,232.851;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-3499.247,1926.054;Inherit;False;Property;_UnderWaterTilling;UnderWaterTilling;13;0;Create;True;0;0;False;0;False;4;4.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;98;-3448.141,2103.981;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-3235.367,705.8983;Float;False;Property;_SpecSmoothness;SpecSmoothness;7;0;Create;True;0;0;False;0;False;0.1;0.3;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;13;-2883.283,-342.5262;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3109.367,809.8983;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-3448.442,2225.699;Inherit;False;Constant;_Float6;Float 6;13;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;57;-3078.367,488.8983;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;86;-3435.663,1763.531;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;73;-3418.498,1274.164;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;90;-1244.398,-235.3126;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-5141.148,248.9868;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;92;-1226.553,-64.07419;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;72;-3368.511,1116.225;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-2899.623,-50.37231;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-2686.551,-218.8163;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-4832.696,25.17194;Inherit;False;ReflectBlink;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2926.367,743.8983;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2927.498,1345.164;Inherit;False;Property;_SpecStart;SpecStart;10;0;Create;True;0;0;False;0;False;0;-0.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3247.141,2189.981;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;-3257.726,1837.482;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2933.498,1113.164;Inherit;False;Property;_SpecEnd;SpecEnd;11;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;74;-3149.498,1196.164;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-3434.329,2385.635;Inherit;False;Property;_WaterDepth;WaterDepth;14;0;Create;True;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;91;-992.5538,-167.0742;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;104;-3442.361,2496.735;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMaxOpNode;58;-2911.367,552.8983;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;59;-2743.367,628.8983;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-2726.498,1317.164;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-2546.657,-354.0705;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;102;-3213.329,2406.635;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;64;-2775.367,815.8983;Inherit;False;Property;_SpecTint;SpecTint;8;0;Create;True;0;0;False;0;False;1,1,1,0;1,0.3647059,0.1215686,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-3075.165,1994.896;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-2410.822,-77.81149;Inherit;False;152;ReflectBlink;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;93;-850.3334,-161.1032;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-2728.498,1154.164;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-2193.483,-202.8889;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-2544.498,1220.164;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-2893.809,2141.703;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2542.367,721.8983;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2551.367,881.8983;Inherit;False;Property;_SpecIntensity;SpecIntensity;9;0;Create;True;0;0;False;0;False;1;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;-697.0333,-147.7031;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;80;-2405.498,1234.164;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-541.7195,-252.1456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-2352.367,797.8983;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;83;-2728.217,2111.095;Inherit;True;Property;_UnderWater;UnderWater;12;0;Create;True;0;0;False;0;False;-1;96bde3f33d34f6a4eb2d6f2e0c3f6238;96bde3f33d34f6a4eb2d6f2e0c3f6238;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-2053.034,-202.4782;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-441.8018,-365.6177;Inherit;False;50;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;109;-405.2172,-242.7675;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2189.802,1034.639;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-2415.079,2126.403;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-442.7491,-467.3835;Inherit;False;88;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-2066.367,795.8983;Inherit;False;SpecColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-244.016,-240.3668;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;96;115.0954,-181.4346;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;85.72961,-25.09431;Inherit;False;68;SpecColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;315.7721,-131.8171;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;650.4809,-439.0192;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;116;0;111;0
WireConnection;119;0;116;0
WireConnection;119;1;115;0
WireConnection;118;0;114;0
WireConnection;118;1;113;0
WireConnection;118;2;112;0
WireConnection;122;0;118;0
WireConnection;122;1;120;0
WireConnection;121;0;119;0
WireConnection;121;1;117;0
WireConnection;125;0;121;0
WireConnection;125;1;122;0
WireConnection;124;0;119;0
WireConnection;124;1;118;0
WireConnection;126;1;124;0
WireConnection;4;0;3;0
WireConnection;127;1;125;0
WireConnection;128;0;126;0
WireConnection;128;1;127;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;10;2;11;0
WireConnection;130;0;128;0
WireConnection;20;0;10;0
WireConnection;20;1;21;0
WireConnection;23;0;5;0
WireConnection;23;1;24;0
WireConnection;2;0;5;0
WireConnection;2;1;10;0
WireConnection;131;0;130;0
WireConnection;131;1;129;0
WireConnection;22;0;23;0
WireConnection;22;1;20;0
WireConnection;132;0;131;0
WireConnection;132;1;131;0
WireConnection;28;1;22;0
WireConnection;28;5;25;0
WireConnection;42;1;2;0
WireConnection;26;0;42;0
WireConnection;26;1;28;0
WireConnection;133;0;132;0
WireConnection;16;0;26;0
WireConnection;134;0;133;0
WireConnection;135;0;131;0
WireConnection;135;2;134;0
WireConnection;18;0;16;0
WireConnection;18;1;31;0
WireConnection;136;0;135;0
WireConnection;30;0;18;0
WireConnection;30;1;18;0
WireConnection;137;0;136;0
WireConnection;32;0;30;0
WireConnection;33;0;32;0
WireConnection;34;0;18;0
WireConnection;34;2;33;0
WireConnection;143;0;142;0
WireConnection;148;0;143;0
WireConnection;148;1;147;0
WireConnection;149;0;146;0
WireConnection;35;0;34;0
WireConnection;150;0;149;0
WireConnection;150;1;148;0
WireConnection;36;0;35;0
WireConnection;45;0;44;0
WireConnection;151;1;150;0
WireConnection;39;0;38;0
WireConnection;154;0;151;0
WireConnection;154;1;153;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;46;0;47;0
WireConnection;46;1;45;4
WireConnection;43;0;39;0
WireConnection;43;1;46;0
WireConnection;55;0;54;0
WireConnection;155;0;154;0
WireConnection;98;0;97;0
WireConnection;13;0;12;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;86;0;84;0
WireConnection;157;0;155;0
WireConnection;157;1;156;0
WireConnection;40;0;43;0
WireConnection;40;1;17;0
WireConnection;19;0;13;0
WireConnection;19;1;40;0
WireConnection;152;0;157;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;99;0;98;0
WireConnection;99;1;100;0
WireConnection;87;0;86;0
WireConnection;87;1;85;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;58;0;57;0
WireConnection;59;0;58;0
WireConnection;59;1;61;0
WireConnection;78;0;75;0
WireConnection;78;1;76;0
WireConnection;1;1;19;0
WireConnection;102;1;103;0
WireConnection;102;2;104;0
WireConnection;101;0;87;0
WireConnection;101;1;99;0
WireConnection;93;0;91;0
WireConnection;77;0;75;0
WireConnection;77;1;74;0
WireConnection;160;0;1;0
WireConnection;160;1;159;0
WireConnection;79;0;77;0
WireConnection;79;1;78;0
WireConnection;105;0;101;0
WireConnection;105;1;102;0
WireConnection;63;0;59;0
WireConnection;63;1;64;0
WireConnection;94;0;93;0
WireConnection;80;0;79;0
WireConnection;108;0;94;0
WireConnection;65;0;63;0
WireConnection;65;1;66;0
WireConnection;83;1;105;0
WireConnection;50;0;160;0
WireConnection;109;0;108;0
WireConnection;82;0;65;0
WireConnection;82;1;80;0
WireConnection;88;0;83;0
WireConnection;68;0;82;0
WireConnection;107;0;51;0
WireConnection;107;1;109;0
WireConnection;96;0;89;0
WireConnection;96;1;107;0
WireConnection;96;2;94;0
WireConnection;71;0;96;0
WireConnection;71;1;70;0
WireConnection;0;13;71;0
ASEEND*/
//CHKSM=CF932968CD55DDCC0F9A4EF62432FBCE20A5B1E8
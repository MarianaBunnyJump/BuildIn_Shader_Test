// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_BeachWater"
{
	Properties
	{
		_WaveASpeedXYSteepnesswavelength("WaveA(SpeedXY,Steepness,wavelength)", Vector) = (1,1,2,50)
		_WaveB("WaveB", Vector) = (1,1,2,50)
		_WaveC("WaveC", Vector) = (1,1,2,50)
		_WaveColor("WaveColor", Color) = (0,0,0,0)
		_DeepRange("Deep Range", Float) = 5
		_ShadoColor("ShadoColor", Color) = (0.1479619,0.7755383,0.8962264,0.5607843)
		_DeepColor("Deep Color", Color) = (0.1409754,0.4616498,0.9056604,1)
		[HDR]_FresnelColor("Fresnel Color", Color) = (0.0509078,0.623758,0.9811321,1)
		_FresnelPower("FresnelPower", Float) = 12
		_NormalScale("NormalScale", Float) = 3
		_NormalSpeed("NormalSpeed", Vector) = (-4,0,0,0)
		_NormalMap("NormalMap", 2D) = "white" {}
		_ReflectDistort("Reflect Distort", Float) = 0
		_ReflectionTex("ReflectionTex", CUBE) = "white" {}
		_ReflectIntensity("Reflect Intensity", Float) = 0.5
		_ReflectPower("Reflect Power", Float) = 5
		_UnderWaterDistort("UnderWaterDistort", Float) = 1
		_CausticsScale("CausticsScale", Float) = 0
		_CausticsTex("CausticsTex", 2D) = "white" {}
		_CausticsSpeed("Caustics Speed", Vector) = (-8,0,0,0)
		_CausticsIntensity("Caustics Intensity", Float) = 1
		_CausticsRange("Caustics Range", Float) = 0
		_ShoreRange("Shore Range", Float) = 1
		_ShoreEdgeWidth("Shore Edge Width", Range( 0 , 1)) = 0.2
		_ShoreEdgeIntensity("Shore Edge Intensity", Float) = 0.2
		_ShoreColor("ShoreColor", Color) = (1,1,1,1)
		_FoamRange("Foam Range", Float) = 1
		_FoamBlendMin("FoamBlend Min", Range( 0 , 1)) = 0
		_FoamWidth("Foam Width", Float) = 0.08
		_FoamFrequency("Foam Frequency", Float) = 20
		_FoamSpeed("Foam Speed", Float) = -1
		_FoamDissolve("Foam Dissolve", Float) = 1.5
		_FoamColor("FoamColor", Color) = (0,0,0,0)
		_FoamNoiseSize("FoamNoiseSize", Vector) = (10,10,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float4 _WaveASpeedXYSteepnesswavelength;
		uniform float4 _WaveB;
		uniform float4 _WaveC;
		uniform float4 _DeepColor;
		uniform float4 _ShadoColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DeepRange;
		uniform float4 _FresnelColor;
		uniform float _FresnelPower;
		uniform samplerCUBE _ReflectionTex;
		uniform sampler2D _NormalMap;
		uniform float _NormalScale;
		uniform float2 _NormalSpeed;
		uniform float _ReflectDistort;
		uniform float _ReflectIntensity;
		uniform float _ReflectPower;
		uniform float4 _WaveColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _UnderWaterDistort;
		uniform sampler2D _CausticsTex;
		uniform float _CausticsScale;
		uniform float2 _CausticsSpeed;
		uniform float _CausticsIntensity;
		uniform float _CausticsRange;
		uniform float4 _ShoreColor;
		uniform float _ShoreRange;
		uniform float _FoamBlendMin;
		uniform float _FoamRange;
		uniform float _FoamWidth;
		uniform float _FoamFrequency;
		uniform float _FoamSpeed;
		uniform float2 _FoamNoiseSize;
		uniform float _FoamDissolve;
		uniform float4 _FoamColor;
		uniform float _ShoreEdgeWidth;
		uniform float _ShoreEdgeIntensity;


		float3 GerstnerWave4( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave6( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float3 GerstnerWave25( float3 position, inout float3 tangent, inout float3 binormal, float4 wave )
		{
			float steepness = wave.z * 0.01;
			float wavelength = wave.w;
			float k = 2 * UNITY_PI / wavelength;
			float c = sqrt(9.8 / k);
			float2 d = normalize(wave.xy);
			float f = k * (dot(d, position.xz) - c * _Time.y);
			float a = steepness / k;
						
			tangent += float3(
			-d.x * d.x * (steepness * sin(f)),
			d.x * (steepness * cos(f)),
			-d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			-d.x * d.y * (steepness * sin(f)),
			d.y * (steepness * cos(f)),
			-d.y * d.y * (steepness * sin(f))
			);
			return float3(
			d.x * (a * cos(f)),
			a * sin(f),
			d.y * (a * cos(f))
			);
		}


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 position4 = ase_worldPos;
			float3 tangent4 = float3( 1,0,0 );
			float3 binormal4 = float3( 0,0,1 );
			float4 wave4 = _WaveASpeedXYSteepnesswavelength;
			float3 localGerstnerWave4 = GerstnerWave4( position4 , tangent4 , binormal4 , wave4 );
			float3 position6 = ase_worldPos;
			float3 tangent6 = tangent4;
			float3 binormal6 = binormal4;
			float4 wave6 = _WaveB;
			float3 localGerstnerWave6 = GerstnerWave6( position6 , tangent6 , binormal6 , wave6 );
			float3 position25 = ase_worldPos;
			float3 tangent25 = tangent6;
			float3 binormal25 = binormal6;
			float4 wave25 = _WaveC;
			float3 localGerstnerWave25 = GerstnerWave25( position25 , tangent25 , binormal25 , wave25 );
			float3 temp_output_8_0 = ( ase_worldPos + localGerstnerWave4 + localGerstnerWave6 + localGerstnerWave25 );
			float3 worldToObj17 = mul( unity_WorldToObject, float4( temp_output_8_0, 1 ) ).xyz;
			float3 WaveVertexPos20 = worldToObj17;
			v.vertex.xyz += WaveVertexPos20;
			v.vertex.w = 1;
			float3 normalizeResult14 = normalize( cross( binormal25 , tangent25 ) );
			float3 worldToObjDir16 = mul( unity_WorldToObject, float4( normalizeResult14, 0 ) ).xyz;
			float3 WaveVertexNormal21 = worldToObjDir16;
			v.normal = WaveVertexNormal21;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 In72_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 PositionFormDepth28 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float WaterDepth32 = ( ase_worldPos.y - (PositionFormDepth28).y );
			float clampResult39 = clamp( exp( ( -WaterDepth32 / _DeepRange ) ) , 0.0 , 1.0 );
			float4 lerpResult40 = lerp( _DeepColor , _ShadoColor , clampResult39);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV46 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode46 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV46, _FresnelPower ) );
			float4 lerpResult43 = lerp( lerpResult40 , _FresnelColor , fresnelNode46);
			float4 WaterColor47 = lerpResult43;
			float2 temp_output_57_0 = ( ( (ase_worldPos).xz * -0.1 ) / _NormalScale );
			float2 temp_output_61_0 = ( _NormalSpeed * _Time.y * 0.01 );
			float3 surfaceNormal73 = BlendNormals( UnpackNormal( tex2D( _NormalMap, ( temp_output_57_0 + temp_output_61_0 ) ) ) , UnpackNormal( tex2D( _NormalMap, ( ( temp_output_57_0 * 2.0 ) + ( temp_output_61_0 * -0.5 ) ) ) ) );
			float fresnelNdotV88 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode88 = ( 0.0 + _ReflectIntensity * pow( 1.0 - fresnelNdotV88, _ReflectPower ) );
			float clampResult89 = clamp( fresnelNode88 , 0.0 , 1.0 );
			float4 ReflctionColor90 = ( texCUBE( _ReflectionTex, float3( ( (ase_screenPosNorm).xy + ( (surfaceNormal73).xy * ( _ReflectDistort * 0.01 ) ) ) ,  0.0 ) ) * clampResult89 );
			float3 position4 = ase_worldPos;
			float3 tangent4 = float3( 1,0,0 );
			float3 binormal4 = float3( 0,0,1 );
			float4 wave4 = _WaveASpeedXYSteepnesswavelength;
			float3 localGerstnerWave4 = GerstnerWave4( position4 , tangent4 , binormal4 , wave4 );
			float3 position6 = ase_worldPos;
			float3 tangent6 = tangent4;
			float3 binormal6 = binormal4;
			float4 wave6 = _WaveB;
			float3 localGerstnerWave6 = GerstnerWave6( position6 , tangent6 , binormal6 , wave6 );
			float3 position25 = ase_worldPos;
			float3 tangent25 = tangent6;
			float3 binormal25 = binormal6;
			float4 wave25 = _WaveC;
			float3 localGerstnerWave25 = GerstnerWave25( position25 , tangent25 , binormal25 , wave25 );
			float3 temp_output_8_0 = ( ase_worldPos + localGerstnerWave4 + localGerstnerWave6 + localGerstnerWave25 );
			float clampResult13 = clamp( (( temp_output_8_0 - ase_worldPos )).y , 0.0 , 1.0 );
			float4 WaveColor19 = ( clampResult13 * _WaveColor );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor98 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_grabScreenPosNorm + float4( ( surfaceNormal73 * _UnderWaterDistort * 0.01 ) , 0.0 ) ).xy);
			float4 SceneColor99 = screenColor98;
			float2 temp_output_109_0 = ( (PositionFormDepth28).xz / _CausticsScale );
			float2 temp_output_113_0 = ( _CausticsSpeed * _Time.y * 0.01 );
			float clampResult128 = clamp( exp( ( -WaterDepth32 / _CausticsRange ) ) , 0.0 , 1.0 );
			float4 CausticsColor129 = ( ( min( tex2D( _CausticsTex, ( temp_output_109_0 + temp_output_113_0 ) ) , tex2D( _CausticsTex, ( -temp_output_109_0 + temp_output_113_0 ) ) ) * _CausticsIntensity ) * clampResult128 );
			float4 UnderWaterColor102 = ( SceneColor99 + CausticsColor129 );
			float WaterOpcity51 = ( 1.0 - (lerpResult43).a );
			float4 lerpResult193 = lerp( ( WaterColor47 + ReflctionColor90 + WaveColor19 ) , UnderWaterColor102 , WaterOpcity51);
			float3 ShoreColor148 = (( SceneColor99 * _ShoreColor )).rgb;
			float clampResult136 = clamp( exp( ( -WaterDepth32 / _ShoreRange ) ) , 0.0 , 1.0 );
			float WaterShore137 = clampResult136;
			float4 lerpResult196 = lerp( lerpResult193 , float4( ShoreColor148 , 0.0 ) , WaterShore137);
			float clampResult154 = clamp( ( WaterDepth32 / _FoamRange ) , 0.0 , 1.0 );
			float smoothstepResult156 = smoothstep( _FoamBlendMin , 1.0 , ( clampResult154 + 0.4 ));
			float temp_output_161_0 = ( 1.0 - clampResult154 );
			float simplePerlin2D174 = snoise( ( i.uv_texcoord * _FoamNoiseSize ) );
			simplePerlin2D174 = simplePerlin2D174*0.5 + 0.5;
			float4 FoamColor186 = ( ( ( 1.0 - smoothstepResult156 ) * step( ( temp_output_161_0 - _FoamWidth ) , ( ( temp_output_161_0 + ( sin( ( ( temp_output_161_0 * _FoamFrequency ) + ( _FoamSpeed * _Time.y ) ) ) + simplePerlin2D174 ) ) - _FoamDissolve ) ) ) * _FoamColor );
			float4 lerpResult203 = lerp( lerpResult196 , ( lerpResult196 + float4( (FoamColor186).rgb , 0.0 ) ) , (FoamColor186).a);
			float smoothstepResult138 = smoothstep( ( 1.0 - _ShoreEdgeWidth ) , 1.0 , WaterShore137);
			float ShoreEdge143 = ( smoothstepResult138 * _ShoreEdgeIntensity );
			o.Emission = max( ( lerpResult203 + ShoreEdge143 ) , float4( 0,0,0,0 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.screenPos = IN.screenPos;
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
440;321;1119;941;4019.261;707.0579;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;33;-4655.3,-1905.972;Inherit;False;1336.988;372.4343;Water Depth;7;26;27;28;29;30;31;32;Water Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;26;-4605.3,-1644.538;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;27;-4217.184,-1659.757;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;74;-4632.48,-499.4189;Inherit;False;2008.535;766.9711;surfaceNormal;20;53;54;55;56;57;58;61;60;62;63;64;65;66;67;68;59;69;72;71;73;surfaceNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-4063.183,-1662.757;Inherit;False;PositionFormDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-4582.48,-442.774;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;56;-4366.528,-300.4189;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;False;-0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;29;-3843.312,-1661.972;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-3900.312,-1855.972;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;54;-4373.528,-449.4189;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-4187.528,-249.4189;Inherit;False;Property;_NormalScale;NormalScale;9;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;63;-4346.256,-77.24783;Inherit;False;Property;_NormalSpeed;NormalSpeed;10;0;Create;True;0;0;False;0;False;-4,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;60;-4342.36,52.75233;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-4320.259,151.5522;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-4178.528,-381.4189;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-3678.312,-1762.972;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-3960.271,146.7353;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;-4654.608,1872.879;Inherit;False;2053.105;783.2338;Caustics Color;24;106;107;109;108;110;112;113;114;115;117;111;116;119;118;120;121;122;123;124;125;126;127;128;129;Caustics Color;1,0.259434,0.9230206,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-3542.312,-1764.972;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;-3990.528,-346.4189;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-3952.649,-63.42287;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-4114.856,9.852406;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;187;-2514.934,1905.145;Inherit;False;2561.242;1525.658;FoamColor;28;186;185;167;165;166;161;154;150;152;168;169;170;171;173;175;174;172;177;180;179;164;162;163;160;183;151;159;188;FoamColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3765.359,-108.0678;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-2377.449,2351.896;Inherit;False;Property;_FoamRange;Foam Range;26;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3798.026,83.57888;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-2378.587,2252.635;Inherit;False;32;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-4604.608,1930.879;Inherit;False;28;PositionFormDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;107;-4366.608,1931.879;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-4393.608,2032.879;Inherit;False;Property;_CausticsScale;CausticsScale;17;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;152;-2167.186,2300.429;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1;-2516.923,1023.876;Inherit;False;2542.907;761.6924;Wave Vertex Animation ;21;25;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;5;4;3;2;Wave Vertex Animation ;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-3735.088,-315.0593;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-3600.934,3.000161;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;69;-3434.107,-327.2748;Inherit;True;Property;_NormalMap;NormalMap;11;0;Create;True;0;0;False;0;False;-1;4f4183a5d87db654397cc7fbb1dc7dc6;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-4542.841,2392.252;Inherit;False;Constant;_Float4;Float 4;20;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;-3414.161,-61.12457;Inherit;True;Property;_TextureSample1;Texture Sample 1;11;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;69;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;112;-4565.915,2159.966;Inherit;False;Property;_CausticsSpeed;Caustics Speed;19;0;Create;True;0;0;False;0;False;-8,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;154;-2033.267,2311.095;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;52;-4656.191,-1437.913;Inherit;False;1918.345;828.5538;Water Color;17;40;42;36;38;39;41;46;43;47;45;50;51;44;35;34;37;49;Water Color;0.3820755,0.8688527,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;109;-4171.608,1970.879;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;2;-2438.499,1403.602;Inherit;False;Property;_WaveASpeedXYSteepnesswavelength;WaveA(SpeedXY,Steepness,wavelength);0;0;Create;True;0;0;False;0;False;1,1,2,50;0,1,1.6,50;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-2396.499,1105.602;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;114;-4552.841,2307.252;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;5;-2025.271,1476.026;Inherit;False;Property;_WaveB;WaveB;1;0;Create;True;0;0;False;0;False;1,1,2,50;-0.5,-0.5,1.6,30;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;171;-1949.872,2917.6;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-3871,2419.154;Inherit;False;32;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-4278.841,2259.252;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;72;-3083.974,-147.8584;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-1939.872,2819.6;Inherit;False;Property;_FoamSpeed;Foam Speed;30;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;4;-2037.326,1302.329;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.NegateNode;117;-4107.842,2156.252;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-1914.872,2719.6;Inherit;False;Property;_FoamFrequency;Foam Frequency;29;0;Create;True;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;161;-1856.492,2432.788;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-4606.191,-1066.536;Inherit;False;32;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;124;-3675.722,2433.236;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-4465.294,-943.4559;Inherit;False;Property;_DeepRange;Deep Range;4;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;7;-1606.465,1492.815;Inherit;False;Property;_WaveC;WaveC;2;0;Create;True;0;0;False;0;False;1,1,2,50;1,0.5,1,20;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-3930.843,2225.252;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-2858.804,-152.9215;Inherit;False;surfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;91;-4616.001,350.0042;Inherit;False;1682.221;630.6282;ReflctionColor;16;86;81;82;80;78;79;83;84;87;88;89;75;76;85;77;90;ReflctionColor;0.004716992,0.06185501,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-3712.948,2540.113;Inherit;False;Property;_CausticsRange;Caustics Range;21;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-1686.294,2683.134;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;6;-1701.345,1302.417;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-3936.61,1952.879;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1708.872,2854.6;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;35;-4418.093,-1057.356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;173;-1907.872,3053.6;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;188;-1878.41,3208.704;Inherit;False;Property;_FoamNoiseSize;FoamNoiseSize;34;0;Create;True;0;0;False;0;False;10,10;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;103;-4635.09,1159.776;Inherit;False;1375.605;558.1823;UnderWaterColor;11;92;93;94;95;96;97;99;100;101;102;104;UnderWaterColor;0.8679245,0.6517185,0.1269135,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;125;-3517.948,2478.113;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-1664.872,3138.6;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-4585.09,1517.957;Inherit;False;Property;_UnderWaterDistort;UnderWaterDistort;16;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-4566.001,620.2638;Inherit;False;73;surfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;118;-3734.843,2189.252;Inherit;True;Property;_TextureSample0;Texture Sample 0;18;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;111;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-4276.694,-1011.956;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-4580.09,1415.959;Inherit;False;73;surfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-4539.701,757.2418;Inherit;False;Property;_ReflectDistort;Reflect Distort;12;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;-3727.61,1922.879;Inherit;True;Property;_CausticsTex;CausticsTex;18;0;Create;True;0;0;False;0;False;-1;b495734c9b233c144ab50dae61e7e152;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-4531.09,1601.956;Inherit;False;Constant;_Float5;Float5;16;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-4503.539,864.6324;Inherit;False;Constant;_Float;Float;12;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;167;-1526.872,2738.6;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;25;-1361.012,1277.607;Inherit;False;float steepness = wave.z * 0.01@$float wavelength = wave.w@$float k = 2 * UNITY_PI / wavelength@$float c = sqrt(9.8 / k)@$float2 d = normalize(wave.xy)@$float f = k * (dot(d, position.xz) - c * _Time.y)@$float a = steepness / k@$			$$tangent += float3($-d.x * d.x * (steepness * sin(f)),$d.x * (steepness * cos(f)),$-d.x * d.y * (steepness * sin(f))$)@$$binormal += float3($-d.x * d.y * (steepness * sin(f)),$d.y * (steepness * cos(f)),$-d.y * d.y * (steepness * sin(f))$)@$$return float3($d.x * (a * cos(f)),$a * sin(f),$d.y * (a * cos(f))$)@;3;False;4;True;position;FLOAT3;0,0,0;In;;Inherit;False;True;tangent;FLOAT3;1,0,0;InOut;;Inherit;False;True;binormal;FLOAT3;0,0,1;InOut;;Inherit;False;True;wave;FLOAT4;0,0,0,0;In;;Inherit;False;GerstnerWave;True;False;0;4;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT3;0,0,1;False;3;FLOAT4;0,0,0,0;False;3;FLOAT3;0;FLOAT3;2;FLOAT3;3
Node;AmplifyShaderEditor.SimpleMinOpNode;119;-3383.843,2138.252;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ExpOpNode;127;-3391.948,2485.113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;38;-4153.691,-1011.956;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-4327.112,783.5413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;92;-4503.181,1209.776;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;174;-1505.864,3128.589;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-4335.09,1489.958;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-1095.333,1376.344;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;168;-1380.872,2769.6;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;79;-4323.826,655.3303;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-3400.843,2280.252;Inherit;False;Property;_CausticsIntensity;Caustics Intensity;20;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1106.126,1094.836;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;75;-4374.163,408.9397;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-3156.843,2155.252;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;104;-4096.091,1256.958;Inherit;False;246;262;做优化，这个地方耗费性能，URP会优化;1;98;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;159;-1835.26,2050.998;Inherit;False;720;299;Foam Mask;4;156;158;157;155;Foam Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;42;-4185.046,-1387.913;Inherit;False;Property;_DeepColor;Deep Color;6;0;Create;True;0;0;False;0;False;0.1409754,0.4616498,0.9056604,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;149;-4617.56,2725.425;Inherit;False;1773.135;729.1665;Water Shore;18;131;146;144;145;143;142;132;141;147;134;133;135;137;136;139;140;138;148;Water Shore;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3963.775,788.8223;Inherit;False;Property;_ReflectPower;Reflect Power;15;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;76;-4140.981,425.7982;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;39;-4032.689,-1004.956;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-4176.73,-1193.241;Inherit;False;Property;_ShadoColor;ShadoColor;5;0;Create;True;0;0;False;0;False;0.1479619,0.7755383,0.8962264,0.5607843;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-858.3333,1306.344;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-3947.775,678.8223;Inherit;False;Property;_ReflectIntensity;Reflect Intensity;14;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-3920.646,-725.3588;Inherit;False;Property;_FresnelPower;FresnelPower;8;0;Create;True;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;128;-3263.948,2486.113;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;-1215.872,2905.6;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-4155.069,709.0255;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-4177.881,1314.176;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FresnelNode;46;-3707.732,-826.1588;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-1250.311,2545.829;Inherit;False;Property;_FoamWidth;Foam Width;28;0;Create;True;0;0;False;0;False;0.08;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-1071.178,2989.433;Inherit;False;Property;_FoamDissolve;Foam Dissolve;32;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;-3829.338,-1163.832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;98;-4046.089,1306.958;Inherit;False;Global;_GrabScreen0;Grab Screen 0;17;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-1071.252,2818.8;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;-1672.206,2108.253;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1780.215,2239.041;Inherit;False;Property;_FoamBlendMin;FoamBlend Min;27;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-3747.178,-1034.725;Inherit;False;Property;_FresnelColor;Fresnel Color;7;1;[HDR];Create;True;0;0;False;0;False;0.0509078,0.623758,0.9811321,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;88;-3733.773,640.8223;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-2962.843,2263.252;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;-4567.56,2775.425;Inherit;False;32;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-3876.89,425.7983;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;11;-686.3328,1314.344;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;-3443.499,-1152.314;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;15;-624.2712,1384.458;Inherit;False;Property;_WaveColor;WaveColor;3;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;133;-4375.078,2915.436;Inherit;False;Property;_ShoreRange;Shore Range;22;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;162;-1043.353,2458.903;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-3860.214,1267.613;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;156;-1465.215,2106.041;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;13;-508.0411,1255.79;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;-3720.029,400.0042;Inherit;True;Property;_ReflectionTex;ReflectionTex;13;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2825.505,2258.76;Inherit;False;CausticsColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;-886.1786,2882.433;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;132;-4352.188,2809.708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;89;-3487.773,648.8223;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;49;-3240.759,-1063.833;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-3835.686,1468.428;Inherit;False;129;CausticsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;134;-4183.242,2843.497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;145;-4110.568,3242.592;Inherit;False;Property;_ShoreColor;ShoreColor;25;0;Create;True;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;144;-4091.566,3153.191;Inherit;False;99;SceneColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;158;-1289.215,2140.041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;164;-780.2869,2581.94;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-3313.138,468.8074;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-304.0409,1324.79;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;185;-648.8641,2714.059;Inherit;False;Property;_FoamColor;FoamColor;33;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-3622.48,1362.382;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ExpOpNode;135;-4044.412,2852.274;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-3233.858,-1207.707;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-633.1701,2509.655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-143.041,1319.79;Inherit;False;WaveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;50;-3101.894,-1062.56;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-3157.781,469.239;Inherit;False;ReflctionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-3870.416,3188.194;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-2167.538,-50.3202;Inherit;False;47;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-419.1751,2628.435;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-3497.48,1350.382;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;147;-3733.416,3183.194;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-4061.951,3017.695;Inherit;False;Property;_ShoreEdgeWidth;Shore Edge Width;23;0;Create;True;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-2164.663,137.8183;Inherit;False;19;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;136;-3915.412,2860.274;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-2173.663,49.81827;Inherit;False;90;ReflctionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-2961.842,-1062.547;Inherit;False;WaterOpcity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-2021.663,313.8183;Inherit;False;51;WaterOpcity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-3564.416,3179.194;Inherit;False;ShoreColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;140;-3750.951,3021.695;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-1939.663,29.81827;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-3767.412,2856.274;Inherit;False;WaterShore;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-2032.663,222.8183;Inherit;False;102;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;-263.0507,2636.845;Inherit;False;FoamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;193;-1747.663,144.8183;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-1693.663,395.8183;Inherit;False;137;WaterShore;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-3500.425,3061.365;Inherit;False;Property;_ShoreEdgeIntensity;Shore Edge Intensity;24;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1548.164,503.2222;Inherit;False;186;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-1702.663,303.8183;Inherit;False;148;ShoreColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;138;-3461.951,2909.695;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;196;-1468.663,229.8183;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;200;-1353.869,429.0767;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;12;-1025.803,1550.209;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-3238.425,2952.365;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;14;-826.803,1584.209;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;-3068.425,2949.365;Inherit;False;ShoreEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;202;-1349.164,557.2222;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;199;-1134.983,347.7973;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;17;-873.449,1095.129;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;203;-980.7642,284.1237;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-989.7642,413.1237;Inherit;False;143;ShoreEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;16;-626.803,1562.208;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;204;-756.7642,294.1237;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-376.8031,1579.209;Inherit;False;WaveVertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-569.9695,1105.207;Inherit;False;WaveVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-600.5143,512.6932;Inherit;False;21;WaveVertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-586.8077,404.5069;Inherit;False;20;WaveVertexPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;206;-560.7642,261.1237;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-822.5963,129.6224;Inherit;False;19;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-346.8654,138.5193;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Toon_BeachWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;29;0;28;0
WireConnection;54;0;53;0
WireConnection;55;0;54;0
WireConnection;55;1;56;0
WireConnection;31;0;30;2
WireConnection;31;1;29;0
WireConnection;32;0;31;0
WireConnection;57;0;55;0
WireConnection;57;1;58;0
WireConnection;61;0;63;0
WireConnection;61;1;60;0
WireConnection;61;2;62;0
WireConnection;64;0;57;0
WireConnection;64;1;65;0
WireConnection;67;0;61;0
WireConnection;67;1;68;0
WireConnection;107;0;106;0
WireConnection;152;0;150;0
WireConnection;152;1;151;0
WireConnection;59;0;57;0
WireConnection;59;1;61;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;69;1;59;0
WireConnection;71;1;66;0
WireConnection;154;0;152;0
WireConnection;109;0;107;0
WireConnection;109;1;108;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;113;2;115;0
WireConnection;72;0;69;0
WireConnection;72;1;71;0
WireConnection;4;0;3;0
WireConnection;4;3;2;0
WireConnection;117;0;109;0
WireConnection;161;0;154;0
WireConnection;124;0;123;0
WireConnection;116;0;117;0
WireConnection;116;1;113;0
WireConnection;73;0;72;0
WireConnection;165;0;161;0
WireConnection;165;1;166;0
WireConnection;6;0;3;0
WireConnection;6;1;4;2
WireConnection;6;2;4;3
WireConnection;6;3;5;0
WireConnection;110;0;109;0
WireConnection;110;1;113;0
WireConnection;170;0;169;0
WireConnection;170;1;171;0
WireConnection;35;0;34;0
WireConnection;125;0;124;0
WireConnection;125;1;126;0
WireConnection;175;0;173;0
WireConnection;175;1;188;0
WireConnection;118;1;116;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;111;1;110;0
WireConnection;167;0;165;0
WireConnection;167;1;170;0
WireConnection;25;0;3;0
WireConnection;25;1;6;2
WireConnection;25;2;6;3
WireConnection;25;3;7;0
WireConnection;119;0;111;0
WireConnection;119;1;118;0
WireConnection;127;0;125;0
WireConnection;38;0;36;0
WireConnection;80;0;81;0
WireConnection;80;1;82;0
WireConnection;174;0;175;0
WireConnection;95;0;94;0
WireConnection;95;1;96;0
WireConnection;95;2;97;0
WireConnection;168;0;167;0
WireConnection;79;0;78;0
WireConnection;8;0;3;0
WireConnection;8;1;4;0
WireConnection;8;2;6;0
WireConnection;8;3;25;0
WireConnection;120;0;119;0
WireConnection;120;1;121;0
WireConnection;76;0;75;0
WireConnection;39;0;38;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;128;0;127;0
WireConnection;172;0;168;0
WireConnection;172;1;174;0
WireConnection;83;0;79;0
WireConnection;83;1;80;0
WireConnection;93;0;92;0
WireConnection;93;1;95;0
WireConnection;46;3;45;0
WireConnection;40;0;42;0
WireConnection;40;1;41;0
WireConnection;40;2;39;0
WireConnection;98;0;93;0
WireConnection;177;0;161;0
WireConnection;177;1;172;0
WireConnection;155;0;154;0
WireConnection;88;2;86;0
WireConnection;88;3;87;0
WireConnection;122;0;120;0
WireConnection;122;1;128;0
WireConnection;77;0;76;0
WireConnection;77;1;83;0
WireConnection;11;0;10;0
WireConnection;43;0;40;0
WireConnection;43;1;44;0
WireConnection;43;2;46;0
WireConnection;162;0;161;0
WireConnection;162;1;163;0
WireConnection;99;0;98;0
WireConnection;156;0;155;0
WireConnection;156;1;157;0
WireConnection;13;0;11;0
WireConnection;84;1;77;0
WireConnection;129;0;122;0
WireConnection;180;0;177;0
WireConnection;180;1;179;0
WireConnection;132;0;131;0
WireConnection;89;0;88;0
WireConnection;49;0;43;0
WireConnection;134;0;132;0
WireConnection;134;1;133;0
WireConnection;158;0;156;0
WireConnection;164;0;162;0
WireConnection;164;1;180;0
WireConnection;85;0;84;0
WireConnection;85;1;89;0
WireConnection;18;0;13;0
WireConnection;18;1;15;0
WireConnection;101;0;99;0
WireConnection;101;1;100;0
WireConnection;135;0;134;0
WireConnection;47;0;43;0
WireConnection;160;0;158;0
WireConnection;160;1;164;0
WireConnection;19;0;18;0
WireConnection;50;0;49;0
WireConnection;90;0;85;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;183;0;160;0
WireConnection;183;1;185;0
WireConnection;102;0;101;0
WireConnection;147;0;146;0
WireConnection;136;0;135;0
WireConnection;51;0;50;0
WireConnection;148;0;147;0
WireConnection;140;0;139;0
WireConnection;192;0;189;0
WireConnection;192;1;190;0
WireConnection;192;2;191;0
WireConnection;137;0;136;0
WireConnection;186;0;183;0
WireConnection;193;0;192;0
WireConnection;193;1;194;0
WireConnection;193;2;195;0
WireConnection;138;0;137;0
WireConnection;138;1;140;0
WireConnection;196;0;193;0
WireConnection;196;1;197;0
WireConnection;196;2;198;0
WireConnection;200;0;201;0
WireConnection;12;0;25;3
WireConnection;12;1;25;2
WireConnection;141;0;138;0
WireConnection;141;1;142;0
WireConnection;14;0;12;0
WireConnection;143;0;141;0
WireConnection;202;0;201;0
WireConnection;199;0;196;0
WireConnection;199;1;200;0
WireConnection;17;0;8;0
WireConnection;203;0;196;0
WireConnection;203;1;199;0
WireConnection;203;2;202;0
WireConnection;16;0;14;0
WireConnection;204;0;203;0
WireConnection;204;1;205;0
WireConnection;21;0;16;0
WireConnection;20;0;17;0
WireConnection;206;0;204;0
WireConnection;0;2;206;0
WireConnection;0;11;24;0
WireConnection;0;12;23;0
ASEEND*/
//CHKSM=943A37844F885C99D9B0134FE3C9B82694434B60
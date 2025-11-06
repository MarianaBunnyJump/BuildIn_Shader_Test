// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hexagon"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		[HDR]_EmissColor("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 1
		_HitRampTex1("HitRampTex", 2D) = "white" {}
		_RimBias("RimBias", Float) = 0
		_HitSpread1("HitSpread", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_HitNoise1("HitNoise", 2D) = "white" {}
		_LineHexagon("LineHexagon", 2D) = "white" {}
		_HitNoiseTilling1("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoiseIntensity("HitNoiseIntensity", Float) = 0
		_HitFadePower1("HitFadePower", Float) = 1
		_HitFadeDistance1("HitFadeDistance", Float) = 6
		_LineMaskSpeed("LineMaskSpeed", Vector) = (0.1,0.1,0,0)
		_HexagonLineIntensity("HexagonLineIntensity", Float) = 2
		_LineEmissMask("LineEmissMask", 2D) = "white" {}
		_AuraTex("AuraTex", 2D) = "white" {}
		_DissolvePoint1("DissolvePoint", Vector) = (4,2.5,-10,0)
		_LineEmissIntensity("LineEmissIntensity", Float) = 1
		_DissolveAmount1("DissolveAmount", Float) = 1
		_DissolveSpread1("DissolveSpread", Float) = 5
		_AuraIntensity("AuraIntensity", Float) = 1
		_HitWaveIntensity("HitWaveIntensity", Float) = 0.5
		_DepthFade("DepthFade", Float) = 3
		_AuraTexMask("AuraTexMask", 2D) = "white" {}
		_AuraSpeed("AuraSpeed", Vector) = (0.02,0.035,0,0)
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord3( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 5.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float2 uv_texcoord;
			float2 uv3_texcoord3;
			float2 uv4_texcoord4;
			float4 screenPos;
		};

		uniform float AffectorAmount;
		uniform float HitSize[20];
		uniform float4 HitPosition[20];
		uniform sampler2D _HitRampTex1;
		uniform float _HitNoiseIntensity;
		uniform float _HitSpread1;
		uniform float _HitFadeDistance1;
		uniform float _HitFadePower1;
		uniform float4 _EmissColor;
		uniform float _EmissIntensity;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _LineHexagon;
		SamplerState sampler_LineHexagon;
		uniform float _HexagonLineIntensity;
		uniform sampler2D _LineEmissMask;
		SamplerState sampler_LineEmissMask;
		uniform float2 _LineMaskSpeed;
		uniform float4 _LineEmissMask_ST;
		uniform float _LineEmissIntensity;
		uniform sampler2D _AuraTex;
		SamplerState sampler_AuraTex;
		uniform float2 _AuraSpeed;
		uniform float _AuraIntensity;
		uniform sampler2D _AuraTexMask;
		SamplerState sampler_AuraTexMask;
		uniform float4 _AuraTexMask_ST;
		uniform float _HitWaveIntensity;
		uniform sampler2D _HitNoise1;
		uniform float3 _HitNoiseTilling1;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFade;
		uniform float3 _DissolvePoint1;
		uniform float _DissolveAmount1;
		uniform float _DissolveSpread1;
		uniform float _EdgeLength;


		float HitWaveFunction_vs115( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
		{
			float hit_result;
			for(int j = 0;j < AffectorAmount;j++)
			{
			float distance_mask = distance(HitPosition[j].xyz,WorldPos);
			float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0);
			float2 ramp_uv = float2(hit_range,0.5);
			float hit_wave = tex2D(RampTex,ramp_uv).r; 
			float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower);
			hit_result = hit_result + hit_fade * hit_wave;
			}
			return saturate(hit_result);
		}


		inline float4 TriplanarSampling82( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float HitWaveFunction91( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
		{
			float hit_result;
			for(int j = 0;j < AffectorAmount;j++)
			{
			float distance_mask = distance(HitPosition[j].xyz,WorldPos);
			float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0);
			float2 ramp_uv = float2(hit_range,0.5);
			float hit_wave = tex2D(RampTex,ramp_uv).r; 
			float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower);
			hit_result = hit_result + hit_fade * hit_wave;
			}
			return saturate(hit_result);
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			sampler2D RampTex115 = _HitRampTex1;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld104 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_3_0_g1 = ( ase_worldPos - objToWorld104 );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 temp_output_6_0_g2 = ase_worldNormal;
			float dotResult1_g2 = dot( temp_output_3_0_g1 , temp_output_6_0_g2 );
			float dotResult2_g2 = dot( temp_output_6_0_g2 , temp_output_6_0_g2 );
			float3 PointToCenterDir108 = -( temp_output_3_0_g1 - ( ( dotResult1_g2 / dotResult2_g2 ) * temp_output_6_0_g2 ) );
			float3 HexagonCenter112 = ( ase_worldPos + PointToCenterDir108 );
			float3 WorldPos115 = HexagonCenter112;
			float HitNoise115 = ( v.texcoord1.xy.x * _HitNoiseIntensity );
			float HitSpread115 = _HitSpread1;
			float HitFadeDistance115 = _HitFadeDistance1;
			float HitFadePower115 = _HitFadePower1;
			float localHitWaveFunction_vs115 = HitWaveFunction_vs115( RampTex115 , WorldPos115 , HitNoise115 , HitSpread115 , HitFadeDistance115 , HitFadePower115 );
			float HitWave_vs117 = localHitWaveFunction_vs115;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( HitWave_vs117 * ase_vertexNormal * 0.01 ) * 0.0 );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 switchResult3 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV7 = dot( switchResult3, ase_worldViewDir );
			float fresnelNode7 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV7, _RimPower ) );
			float RimFactor9 = fresnelNode7;
			float4 tex2DNode36 = tex2D( _LineHexagon, i.uv_texcoord );
			float HexagonLine38 = tex2DNode36.r;
			float2 uv3_LineEmissMask = i.uv3_texcoord3 * _LineEmissMask_ST.xy + _LineEmissMask_ST.zw;
			float2 panner46 = ( 1.0 * _Time.y * _LineMaskSpeed + uv3_LineEmissMask);
			float LineEmiss51 = ( ( tex2DNode36.r * tex2D( _LineEmissMask, panner46 ).r ) * _LineEmissIntensity );
			float2 panner63 = ( 1.0 * _Time.y * ( _AuraSpeed * float2( 2,2 ) ) + ( i.uv3_texcoord3 * float2( 0.5,0.5 ) ));
			float2 panner57 = ( 1.0 * _Time.y * _AuraSpeed + ( i.uv3_texcoord3 + ( (tex2D( _AuraTex, panner63 )).rg * 0.5 ) ));
			float4 tex2DNode54 = tex2D( _AuraTex, panner57 );
			float2 uv4_AuraTexMask = i.uv4_texcoord4 * _AuraTexMask_ST.xy + _AuraTexMask_ST.zw;
			float2 panner69 = ( 1.0 * _Time.y * float2( 0,0.02 ) + uv4_AuraTexMask);
			float AuraColor58 = ( ( tex2DNode54.r * _AuraIntensity ) + ( tex2DNode54.r * tex2D( _AuraTexMask, panner69 ).r * 2.0 ) );
			float temp_output_40_0 = ( RimFactor9 + ( HexagonLine38 * _HexagonLineIntensity ) + LineEmiss51 + AuraColor58 + LineEmiss51 );
			sampler2D RampTex91 = _HitRampTex1;
			float3 WorldPos91 = ase_worldPos;
			float4 triplanar82 = TriplanarSampling82( _HitNoise1, ( ase_worldPos * _HitNoiseTilling1 ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise84 = triplanar82.x;
			float HitNoise91 = ( WaveNoise84 * _HitNoiseIntensity );
			float HitSpread91 = _HitSpread1;
			float HitFadeDistance91 = _HitFadeDistance1;
			float HitFadePower91 = _HitFadePower1;
			float localHitWaveFunction91 = HitWaveFunction91( RampTex91 , WorldPos91 , HitNoise91 , HitSpread91 , HitFadeDistance91 , HitFadePower91 );
			float HitWave92 = localHitWaveFunction91;
			o.Emission = ( _EmissColor * _EmissIntensity * ( temp_output_40_0 + ( ( temp_output_40_0 + _HitWaveIntensity ) * HitWave92 ) ) ).rgb;
			float clampResult16 = clamp( temp_output_40_0 , 0.0 , 1.0 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth161 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth161 = abs( ( screenDepth161 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			float clampResult162 = clamp( distanceDepth161 , 0.0 , 1.0 );
			float3 objToWorld104 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_3_0_g1 = ( ase_worldPos - objToWorld104 );
			float3 temp_output_6_0_g2 = ase_worldNormal;
			float dotResult1_g2 = dot( temp_output_3_0_g1 , temp_output_6_0_g2 );
			float dotResult2_g2 = dot( temp_output_6_0_g2 , temp_output_6_0_g2 );
			float3 PointToCenterDir108 = -( temp_output_3_0_g1 - ( ( dotResult1_g2 / dotResult2_g2 ) * temp_output_6_0_g2 ) );
			float3 HexagonCenter112 = ( ase_worldPos + PointToCenterDir108 );
			float3 objToWorld131 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult143 = clamp( ( ( distance( ( HexagonCenter112 - objToWorld131 ) , _DissolvePoint1 ) - _DissolveAmount1 ) / _DissolveSpread1 ) , 0.0 , 1.0 );
			float temp_output_155_0 = step( 0.05 , clampResult143 );
			float DissolveAlpha153 = temp_output_155_0;
			o.Alpha = ( clampResult16 * clampResult162 * DissolveAlpha153 );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
742;309;1181;910;3806.489;-92.96423;3.013594;True;False
Node;AmplifyShaderEditor.CommentaryNode;76;-2702.327,1932.729;Inherit;False;2901.739;832.0199;AuraColor;21;55;56;65;64;66;68;57;69;54;70;63;62;67;74;75;72;71;60;59;73;58;AuraColor;0.8962264,0.4918656,0.1056871,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;113;-2735.021,2970.179;Inherit;False;1518.166;525;HexagonCenter;10;110;109;108;106;105;102;104;101;111;112;HexagonCenter;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;56;-2394.893,2151.782;Inherit;False;Property;_AuraSpeed;AuraSpeed;38;0;Create;True;0;0;False;0;False;0.02,0.035;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-2652.327,2038.315;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;101;-2674.341,3035.325;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;104;-2685.021,3239.432;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-2382.452,2383.457;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-2139.798,2295.772;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;106;-2432.856,3312.179;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;102;-2435.021,3162.432;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;63;-1981.521,2404.786;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;105;-2222.856,3214.179;Inherit;False;Rejection;-1;;1;ea6ca936e02c9e74fae837451ff893c3;0;2;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;62;-1799.256,2384.608;Inherit;True;Property;_AuraTex1;AuraTex;28;0;Create;True;0;0;False;0;False;-1;57451d90cad4e93448f1dbe1a84a7c70;57451d90cad4e93448f1dbe1a84a7c70;True;0;False;white;Auto;False;Instance;54;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;67;-1509.94,2393.036;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1589.807,2592.544;Inherit;False;Constant;_Float1;Float 1;19;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;109;-2038.529,3210.009;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;110;-1904.855,3020.179;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-1883.383,3214.47;Inherit;False;PointToCenterDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;53;296.5295,2046.658;Inherit;False;1429.533;562.8289;LineColor;11;45;43;46;37;47;36;48;50;38;49;51;LineColor;0.1932627,0.8815983,0.9528302,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1377.684,2502.331;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;77;-2696.042,-1525.635;Inherit;False;2291.384;1279.597;HitWave;24;95;94;93;92;91;90;89;88;87;86;85;84;83;82;81;80;79;78;114;115;116;117;118;119;HitWave;0.489655,1,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-1160.078,2433.25;Inherit;False;3;70;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;8;-2686.222,-80.174;Inherit;False;1492.762;728.0958;RimFactor;8;6;9;7;5;4;3;2;1; RimFactor;0.2311321,0.9557796,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-1621.855,3113.179;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;45;381.7516,2444.786;Inherit;False;Property;_LineMaskSpeed;LineMaskSpeed;25;0;Create;True;0;0;False;0;False;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-1383.618,2172.489;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;43;346.5295,2296.242;Inherit;False;2;47;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;78;-2613.403,-700.4694;Inherit;False;Property;_HitNoiseTilling1;HitNoiseTilling;14;0;Create;True;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1;-2636.222,-9.078781;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;129;-987.9023,2936.823;Inherit;False;2492.737;972.074;Dissolve;23;143;142;155;168;159;158;156;153;138;141;134;137;133;132;152;131;169;170;171;172;173;176;177;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;69;-885.7777,2443.65;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;57;-1228.941,2018.486;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;46;629.6902,2367.926;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;347.687,2123.534;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-2640.403,-868.4693;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-1445.855,3109.179;Inherit;False;HexagonCenter;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;54;-1036.672,1982.729;Inherit;True;Property;_AuraTex;AuraTex;28;0;Create;True;0;0;False;0;False;-1;57451d90cad4e93448f1dbe1a84a7c70;57451d90cad4e93448f1dbe1a84a7c70;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;47;820.9114,2335.202;Inherit;True;Property;_LineEmissMask;LineEmissMask;27;0;Create;True;0;0;False;0;False;-1;b2ebe4a36fc94024d91fe15b52fe5772;b2ebe4a36fc94024d91fe15b52fe5772;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-918.5851,2178.224;Inherit;False;Property;_AuraIntensity;AuraIntensity;33;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;131;-960.0025,3150.322;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;152;-969.2049,3001.827;Inherit;False;112;HexagonCenter;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;81;-2639.403,-1102.469;Inherit;True;Property;_HitNoise1;HitNoise;12;0;Create;True;0;0;False;0;False;3c506748d17579d4a85691a58877ff1e;3c4ea3a033cf4ed09936c7bd439486a4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2365.404,-875.4693;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-556.1776,2648.749;Inherit;False;Constant;_Float3;Float 3;19;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-675.1776,2411.148;Inherit;True;Property;_AuraTexMask;AuraTexMask;37;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;591.9395,2096.657;Inherit;True;Property;_LineHexagon;LineHexagon;13;0;Create;True;0;0;False;0;False;-1;373bb7a955475ea4a82cd75a31359196;373bb7a955475ea4a82cd75a31359196;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;2;-2421.822,108.42;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2097.921,203.8953;Inherit;False;Property;_RimScale;RimScale;10;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;1108.411,2493.485;Inherit;False;Property;_LineEmissIntensity;LineEmissIntensity;30;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;3;-2275.223,-4.779982;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2108.908,102.8228;Inherit;False;Property;_RimBias;RimBias;8;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-301.0775,2357.649;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;1149.911,2313.202;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2056.115,318.7239;Inherit;False;Property;_RimPower;RimPower;11;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-718.0026,3073.322;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;133;-853.2026,3366.423;Inherit;False;Property;_DissolvePoint1;DissolvePoint;29;0;Create;True;0;0;False;0;False;4,2.5,-10;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TriplanarNode;82;-2201.164,-904.9401;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-509.2006,2022.941;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;7;-1831.248,-30.17399;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;965.7297,2126.603;Inherit;False;HexagonLine;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-556.8779,3276.547;Inherit;False;Property;_DissolveAmount1;DissolveAmount;31;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2023.886,-631.2755;Inherit;False;Property;_HitNoiseIntensity;HitNoiseIntensity;15;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1324.367,2389.397;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;137;-542.9025,3109.823;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-168.7457,2111.913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1788.758,-865.9126;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-1435.885,-426.9181;Inherit;False;Property;_HitFadePower1;HitFadePower;17;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;87;-1519.221,-1317.458;Inherit;True;Property;_HitRampTex1;HitRampTex;7;0;Create;True;0;0;False;0;False;None;bfb5d11eb2154099bda5558461f45026;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;42;-610.0839,253.1161;Inherit;False;Property;_HexagonLineIntensity;HexagonLineIntensity;26;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1578.22,-752.4645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-1965.976,-1134.777;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;1502.062,2374.271;Inherit;False;LineEmiss;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1478.885,-576.9188;Inherit;False;Property;_HitFadeDistance1;HitFadeDistance;20;0;Create;True;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-291.7401,3286.758;Inherit;False;Property;_DissolveSpread1;DissolveSpread;32;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-1600.67,-31.03838;Inherit;False;RimFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-602.5026,150.8811;Inherit;False;38;HexagonLine;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;90;-1573.839,-913.3931;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;88;-1440.751,-687.2012;Inherit;False;Property;_HitSpread1;HitSpread;9;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-24.58763,2110.4;Inherit;False;AuraColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;138;-329.7707,3154.265;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-339.2466,204.3413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-368.3227,325.8349;Inherit;False;51;LineEmiss;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;142;-80.80932,3154.318;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;91;-1117.266,-881.3986;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1713.137,-1084.03;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-371.0378,70.08628;Inherit;False;9;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-355.1198,472.5937;Inherit;False;58;AuraColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1510.003,-1073.318;Inherit;False;112;HexagonCenter;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-578.7878,597.0048;Inherit;False;51;LineEmiss;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;115;-1126.048,-1267.488;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction_vs;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;143;169.7582,3532.932;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-118.8452,103.4056;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-114.5225,273.8203;Inherit;False;Property;_HitWaveIntensity;HitWaveIntensity;35;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-762.4233,-1072.292;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;89.00534,122.4825;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;109.3652,289.0923;Inherit;False;92;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-645.2246,-1261.448;Inherit;False;HitWave_vs;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-43.19086,466.3231;Inherit;False;Property;_DepthFade;DepthFade;36;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;155;377.8556,3675.411;Inherit;False;2;0;FLOAT;0.05;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;609.7095,3670.521;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-27.41175,603.4701;Inherit;False;117;HitWave_vs;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;161;167.0092,442.823;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;287.9236,136.2552;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;121;-60.9199,690.3207;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;123;-21.91991,848.3207;Inherit;False;Constant;_Float0;Float 0;27;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;147.3442,892.9528;Inherit;False;Constant;_HitVertexOffset;HitVertexOffset;35;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;331.2737,-99.56875;Inherit;False;Property;_EmissIntensity;EmissIntensity;6;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;203.0802,678.3207;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;390.8952,604.1235;Inherit;False;153;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;18;-2703.402,824.8146;Inherit;False;2054.211;898.0541;FlowLightColor;17;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;FlowLightColor;0.9056604,0.4827341,0.4827341,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;432.7384,31.34327;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;16;486.3937,116.1106;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;162;441.8091,436.3231;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;293.2737,-312.569;Inherit;False;Property;_EmissColor;EmissColor;5;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexToFragmentNode;116;-868.8922,-1231.512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;838.0161,3414.458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2666.045,1223.088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;22;-2087.166,1190.027;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;176;282.1166,3413.03;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;185.0132,1109.877;Inherit;False;173;DissolveVertexPostion;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-1516.692,1494.297;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;171;686.2971,3107.548;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;169;453.6621,3019.727;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;177;267.1479,3189.82;Inherit;False;108;PointToCenterDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-873.189,1072.781;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;29;-1729.114,1450.976;Inherit;False;Property;_FlowStrength;FlowStrength;19;0;Create;True;0;0;False;0;False;-0.5,0.3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;-2091.409,1297.725;Inherit;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;622.1911,-123.441;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-1934.209,1219.525;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;1017.55,3364.942;Inherit;False;DissolveEmiss;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1736.718,1220.716;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1926.804,1072.914;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;630.4296,3424.958;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1373.409,1300.934;Inherit;False;9;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;172;824.9075,3102.652;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GlobalArrayNode;94;-1682.386,-1475.635;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1923.49,1348.892;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;641.2784,328.8653;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;1052.907,3087.25;Inherit;False;DissolveVertexPostion;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GlobalArrayNode;95;-1940.604,-1474.571;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;33;-1528.129,1101.719;Inherit;False;Flow;22;;3;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;375.0802,783.3207;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;20;-2419.648,1196.078;Inherit;True;Property;_FlowMap;FlowMap;18;0;Create;True;0;0;False;0;False;-1;f4a4b1c04c15a784ca546dc6c403e249;f4a4b1c04c15a784ca546dc6c403e249;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;93;-1454.818,-1466.378;Inherit;False;Global;AffectorAmount;AffectorAmount;6;0;Create;False;0;0;True;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1714.209,1610.941;Inherit;False;Property;_FlowSpeed;FlowSpeed;21;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;32;-1271.692,1512.297;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;602.016,3562.458;Inherit;False;Property;_DissolveEdgeIntensity;DissolveEdgeIntensity;34;0;Create;True;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;493.9281,3185.1;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;34;-1087.151,1121.447;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;480.1345,1112.103;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-1923.501,874.8146;Inherit;True;Property;_FlowLisht;FlowLisht;16;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;865.7449,-43.1889;Float;False;True;-1;7;ASEMaterialInspector;0;0;Unlit;Hexagon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;64;0;55;0
WireConnection;65;0;56;0
WireConnection;102;0;101;0
WireConnection;102;1;104;0
WireConnection;63;0;64;0
WireConnection;63;2;65;0
WireConnection;105;3;102;0
WireConnection;105;4;106;0
WireConnection;62;1;63;0
WireConnection;67;0;62;0
WireConnection;109;0;105;0
WireConnection;108;0;109;0
WireConnection;74;0;67;0
WireConnection;74;1;75;0
WireConnection;111;0;110;0
WireConnection;111;1;108;0
WireConnection;66;0;55;0
WireConnection;66;1;74;0
WireConnection;69;0;68;0
WireConnection;57;0;66;0
WireConnection;57;2;56;0
WireConnection;46;0;43;0
WireConnection;46;2;45;0
WireConnection;112;0;111;0
WireConnection;54;1;57;0
WireConnection;47;1;46;0
WireConnection;80;0;79;0
WireConnection;80;1;78;0
WireConnection;70;1;69;0
WireConnection;36;1;37;0
WireConnection;2;0;1;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;71;0;54;1
WireConnection;71;1;70;1
WireConnection;71;2;72;0
WireConnection;48;0;36;1
WireConnection;48;1;47;1
WireConnection;132;0;152;0
WireConnection;132;1;131;0
WireConnection;82;0;81;0
WireConnection;82;9;80;0
WireConnection;59;0;54;1
WireConnection;59;1;60;0
WireConnection;7;0;3;0
WireConnection;7;1;6;0
WireConnection;7;2;5;0
WireConnection;7;3;4;0
WireConnection;38;0;36;1
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;137;0;132;0
WireConnection;137;1;133;0
WireConnection;73;0;59;0
WireConnection;73;1;71;0
WireConnection;84;0;82;1
WireConnection;89;0;84;0
WireConnection;89;1;83;0
WireConnection;51;0;49;0
WireConnection;9;0;7;0
WireConnection;58;0;73;0
WireConnection;138;0;137;0
WireConnection;138;1;134;0
WireConnection;41;0;39;0
WireConnection;41;1;42;0
WireConnection;142;0;138;0
WireConnection;142;1;141;0
WireConnection;91;0;87;0
WireConnection;91;1;90;0
WireConnection;91;2;89;0
WireConnection;91;3;88;0
WireConnection;91;4;85;0
WireConnection;91;5;86;0
WireConnection;119;0;118;1
WireConnection;119;1;83;0
WireConnection;115;0;87;0
WireConnection;115;1;114;0
WireConnection;115;2;119;0
WireConnection;115;3;88;0
WireConnection;115;4;85;0
WireConnection;115;5;86;0
WireConnection;143;0;142;0
WireConnection;40;0;12;0
WireConnection;40;1;41;0
WireConnection;40;2;52;0
WireConnection;40;3;61;0
WireConnection;40;4;164;0
WireConnection;92;0;91;0
WireConnection;97;0;40;0
WireConnection;97;1;98;0
WireConnection;117;0;115;0
WireConnection;155;1;143;0
WireConnection;153;0;155;0
WireConnection;161;0;160;0
WireConnection;99;0;97;0
WireConnection;99;1;96;0
WireConnection;122;0;120;0
WireConnection;122;1;121;0
WireConnection;122;2;123;0
WireConnection;100;0;40;0
WireConnection;100;1;99;0
WireConnection;16;0;40;0
WireConnection;162;0;161;0
WireConnection;116;0;115;0
WireConnection;158;0;168;0
WireConnection;158;1;159;0
WireConnection;22;0;20;0
WireConnection;176;0;143;0
WireConnection;171;0;169;0
WireConnection;171;1;170;0
WireConnection;35;0;34;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;15;2;100;0
WireConnection;24;0;22;0
WireConnection;24;1;21;0
WireConnection;156;0;158;0
WireConnection;27;0;24;0
WireConnection;27;1;23;0
WireConnection;168;0;176;0
WireConnection;168;1;155;0
WireConnection;172;0;171;0
WireConnection;163;0;16;0
WireConnection;163;1;162;0
WireConnection;163;2;154;0
WireConnection;173;0;172;0
WireConnection;33;5;28;0
WireConnection;33;2;26;0
WireConnection;33;18;27;0
WireConnection;33;17;29;0
WireConnection;33;24;25;0
WireConnection;124;0;122;0
WireConnection;124;1;125;0
WireConnection;20;1;19;0
WireConnection;32;0;30;2
WireConnection;170;0;177;0
WireConnection;34;0;33;0
WireConnection;34;1;31;0
WireConnection;34;2;32;0
WireConnection;0;2;15;0
WireConnection;0;9;163;0
WireConnection;0;11;124;0
ASEEND*/
//CHKSM=546BB314D60253B4E7B40C3540243AFF18CAE177
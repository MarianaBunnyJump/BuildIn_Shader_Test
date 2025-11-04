// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceField"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_HitRampTex("HitRampTex", 2D) = "white" {}
		_HitSpread("HitSpread", Float) = 0
		_HitWaveIntensity("HitWaveIntensity", Float) = 0.5
		_HitNoise("HitNoise", 2D) = "white" {}
		_HitNoiseTilling("HitNoiseTilling", Vector) = (1,1,1,0)
		_HitNoiseIntensity("HitNoiseIntensity", Float) = 0
		_HitFadePower("HitFadePower", Float) = 1
		_HitFadeDistance("HitFadeDistance", Float) = 6
		[HDR]_EmissColor("EmissColor", Color) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 0
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 0
		_RimPower("RimPower", Float) = 0
		_FlowLisht("FlowLisht", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_DepthFadeDistance("DepthFadeDistance", Float) = 1.5
		_DepthFadePower("DepthFadePower", Float) = 5
		_FlowStrength("FlowStrength", Vector) = (-0.5,0.3,0,0)
		_FlowSpeed("FlowSpeed", Float) = 0.2
		_Size("Size", Range( 0 , 10)) = 1
		_DissolvePoint("DissolvePoint", Vector) = (0,0,0,0)
		_DissolveAmount("DissolveAmount", Float) = 1
		_DissolveSpread("DissolveSpread", Float) = 5
		_DissolveNoise("DissolveNoise", Float) = 1
		_DissolveRampTex("DissolveRampTex", 2D) = "white" {}
		_DissolveEdgeIntensity("DissolveEdgeIntensity", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float4 screenPos;
			float2 uv_texcoord;
		};

		uniform float AffectorAmount;
		uniform float _CullMode;
		uniform float4 HitPosition[20];
		uniform float HitSize[20];
		uniform float4 _EmissColor;
		uniform float _EmissIntensity;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthFadeDistance;
		uniform float _DepthFadePower;
		uniform sampler2D _FlowLisht;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform sampler2D _HitRampTex;
		uniform sampler2D _HitNoise;
		uniform float3 _HitNoiseTilling;
		uniform float _HitNoiseIntensity;
		uniform float _HitSpread;
		uniform float _HitFadeDistance;
		uniform float _HitFadePower;
		uniform float2 _FlowStrength;
		uniform float _FlowSpeed;
		uniform float _HitWaveIntensity;
		uniform sampler2D _DissolveRampTex;
		SamplerState sampler_DissolveRampTex;
		uniform float3 _DissolvePoint;
		uniform float _DissolveAmount;
		uniform float _DissolveNoise;
		uniform float _DissolveSpread;
		uniform float _DissolveEdgeIntensity;


		inline float4 TriplanarSampling42( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
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


		float HitWaveFunction35( sampler2D RampTex, float3 WorldPos, float HitNoise, float HitSpread, float HitFadeDistance, float HitFadePower )
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
			float3 switchResult215 = (((i.ASEVFace>0)?(ase_worldNormal):(-ase_worldNormal)));
			float fresnelNdotV132 = dot( switchResult215, ase_worldViewDir );
			float fresnelNode132 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV132, _RimPower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth170 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth170 = abs( ( screenDepth170 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFadeDistance ) );
			float clampResult175 = clamp( ( 1.0 - distanceDepth170 ) , 0.0 , 1.0 );
			float RimFactor136 = ( fresnelNode132 + pow( clampResult175 , _DepthFadePower ) );
			float2 temp_output_4_0_g1 = (( i.uv_texcoord / _Size )).xy;
			float2 temp_cast_0 = (0.5).xx;
			sampler2D RampTex35 = _HitRampTex;
			float3 WorldPos35 = ase_worldPos;
			float4 triplanar42 = TriplanarSampling42( _HitNoise, ( ase_worldPos * _HitNoiseTilling ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float WaveNoise123 = triplanar42.x;
			float HitNoise35 = ( WaveNoise123 * _HitNoiseIntensity );
			float HitSpread35 = _HitSpread;
			float HitFadeDistance35 = _HitFadeDistance;
			float HitFadePower35 = _HitFadePower;
			float localHitWaveFunction35 = HitWaveFunction35( RampTex35 , WorldPos35 , HitNoise35 , HitSpread35 , HitFadeDistance35 , HitFadePower35 );
			float HitWave47 = localHitWaveFunction35;
			float2 temp_output_41_0_g1 = ( ( ( (tex2D( _FlowMap, i.uv_texcoord )).rg - temp_cast_0 ) + HitWave47 ) + 0.5 );
			float2 temp_output_17_0_g1 = _FlowStrength;
			float mulTime22_g1 = _Time.y * _FlowSpeed;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _FlowLisht, temp_output_11_0_g1 ) , tex2D( _FlowLisht, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float4 temp_cast_1 = (RimFactor136).xxxx;
			float smoothstepResult162 = smoothstep( 0.9 , 1.0 , i.uv_texcoord.y);
			float4 lerpResult160 = lerp( lerpResult9_g1 , temp_cast_1 , smoothstepResult162);
			float4 FlowColor155 = lerpResult160;
			float4 temp_output_166_0 = ( RimFactor136 * FlowColor155 );
			float3 objToWorld191 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult197 = clamp( ( ( ( distance( _DissolvePoint , ( ase_worldPos - objToWorld191 ) ) - _DissolveAmount ) - ( WaveNoise123 * _DissolveNoise ) ) / _DissolveSpread ) , 0.0 , 1.0 );
			float temp_output_200_0 = ( 1.0 - clampResult197 );
			float2 appendResult199 = (float2(temp_output_200_0 , 0.5));
			float DissolveEdge192 = ( tex2D( _DissolveRampTex, appendResult199 ).r * _DissolveEdgeIntensity );
			float4 temp_output_180_0 = ( temp_output_166_0 + ( ( temp_output_166_0 + _HitWaveIntensity ) * HitWave47 ) + DissolveEdge192 );
			o.Emission = ( ( _EmissColor * _EmissIntensity ) * temp_output_180_0 ).rgb;
			float grayscale168 = Luminance(temp_output_180_0.rgb);
			float smoothstepResult201 = smoothstep( 0.0 , 0.1 , temp_output_200_0);
			float DissolveAlpha203 = smoothstepResult201;
			float clampResult169 = clamp( ( grayscale168 * DissolveAlpha203 ) , 0.0 , 1.0 );
			o.Alpha = clampResult169;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1200;324;1264;996;3940.129;-1606.736;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;41;-3048.303,-414.9418;Inherit;False;2291.384;1279.597;HitWave;18;37;35;40;39;28;13;30;36;16;5;17;42;43;46;44;45;47;123;HitWave;0.489655,1,0,1;0;0
Node;AmplifyShaderEditor.Vector3Node;45;-2965.664,410.2242;Inherit;False;Property;_HitNoiseTilling;HitNoiseTilling;5;0;Create;True;0;0;False;0;False;1,1,1;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;44;-2992.664,242.2243;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2717.665,235.2242;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;43;-2991.664,8.224134;Inherit;True;Property;_HitNoise;HitNoise;4;0;Create;True;0;0;False;0;False;3c506748d17579d4a85691a58877ff1e;3c4ea3a033cf4ed09936c7bd439486a4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;137;-3058.948,2026.935;Inherit;False;1871.73;696.5719;RimFactor;15;216;214;215;136;177;179;132;135;175;134;133;174;178;170;172;RimFactor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;213;-3071.999,2815.35;Inherit;False;2623.155;679.1934;Dissolve;22;189;191;190;187;188;194;193;195;196;197;200;199;198;212;211;192;201;203;209;210;208;207;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.TriplanarNode;42;-2553.425,205.7535;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;172;-2613.948,2423.633;Inherit;False;Property;_DepthFadeDistance;DepthFadeDistance;16;0;Create;True;0;0;False;0;False;1.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;214;-2982.179,2102.899;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;189;-3007.999,3089.349;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-2213.313,445.72;Inherit;False;Property;_HitNoiseIntensity;HitNoiseIntensity;6;0;Create;True;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-2141.019,244.7809;Inherit;False;WaveNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;170;-2382.64,2390.88;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;191;-3021.999,3282.349;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;164;-3001.576,1032.607;Inherit;False;2054.211;898.0541;FlowLightColor;17;151;155;160;162;163;144;185;150;146;149;145;161;186;157;158;154;152;FlowLightColor;0.9056604,0.4827341,0.4827341,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;178;-2153.914,2402.609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1930.481,358.2292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;36;-1841.581,-126.1644;Inherit;True;Property;_HitRampTex;HitRampTex;1;0;Create;True;0;0;False;0;False;None;bfb5d11eb2154099bda5558461f45026;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;30;-1788.146,683.7749;Inherit;False;Property;_HitFadePower;HitFadePower;7;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;216;-2767.78,2220.398;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-1862.319,99.15642;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;13;-1793.012,423.4924;Inherit;False;Property;_HitSpread;HitSpread;2;0;Create;True;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;151;-2964.219,1430.88;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-2779.999,3205.349;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;187;-2883.999,2865.35;Inherit;False;Property;_DissolvePoint;DissolvePoint;23;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;28;-1831.146,533.7745;Inherit;False;Property;_HitFadeDistance;HitFadeDistance;8;0;Create;True;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;35;-1486.427,52.79552;Inherit;False;float hit_result@$$for(int j = 0@j < AffectorAmount@j++)${$$float distance_mask = distance(HitPosition[j].xyz,WorldPos)@$$float hit_range = -clamp((distance_mask - HitSize[j] + HitNoise) / HitSpread,-1,0)@$$float2 ramp_uv = float2(hit_range,0.5)@$$float hit_wave = tex2D(RampTex,ramp_uv).r@ $$float hit_fade = saturate((1.0 - distance_mask / HitFadeDistance) * HitFadePower)@$$hit_result = hit_result + hit_fade * hit_wave@$}$$return saturate(hit_result)@;1;False;6;True;RampTex;SAMPLER2D;;In;;Inherit;False;True;WorldPos;FLOAT3;0,0,0;In;;Inherit;False;True;HitNoise;FLOAT;0;In;;Inherit;False;True;HitSpread;FLOAT;0;In;;Inherit;False;True;HitFadeDistance;FLOAT;0;In;;Inherit;False;True;HitFadePower;FLOAT;0;In;;Inherit;False;HitWaveFunction;True;False;0;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;215;-2621.18,2107.198;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;152;-2717.822,1403.87;Inherit;True;Property;_FlowMap;FlowMap;15;0;Create;True;0;0;False;0;False;-1;f4a4b1c04c15a784ca546dc6c403e249;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;194;-2609.926,3168.873;Inherit;False;Property;_DissolveAmount;DissolveAmount;24;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2408.951,2277.669;Inherit;False;Property;_RimPower;RimPower;13;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;188;-2626.999,2988.35;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2467.951,2200.669;Inherit;False;Property;_RimScale;RimScale;12;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-2539.859,3378.543;Inherit;False;Property;_DissolveNoise;DissolveNoise;26;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-2429.951,2116.669;Inherit;False;Property;_RimBias;RimBias;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-2072.844,2540.783;Inherit;False;Property;_DepthFadePower;DepthFadePower;17;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;175;-2013.286,2398.138;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-2541.859,3271.543;Inherit;False;123;WaveNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-2389.583,1505.517;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;132;-2177.207,2081.804;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;154;-2385.34,1397.819;Inherit;False;FLOAT2;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;179;-1858.821,2399.138;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-2319.859,3324.543;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;193;-2381.094,3062.115;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1114.684,38.40121;Inherit;False;HitWave;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-2221.664,1556.684;Inherit;False;47;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-1657.336,2289.063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-2136.637,3208.186;Inherit;False;Property;_DissolveSpread;DissolveSpread;25;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;157;-2232.383,1427.317;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;207;-2160.161,3066.292;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-2012.383,1818.733;Inherit;False;Property;_FlowSpeed;FlowSpeed;19;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;146;-2224.978,1280.706;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;185;-2034.893,1428.508;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-1489.687,2288.797;Inherit;False;RimFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;145;-2221.675,1082.607;Inherit;True;Property;_FlowLisht;FlowLisht;14;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;149;-2027.289,1658.768;Inherit;False;Property;_FlowStrength;FlowStrength;18;0;Create;True;0;0;False;0;False;-0.5,0.3;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;161;-1814.866,1702.089;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;196;-1894.554,3064.255;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-1671.584,1508.726;Inherit;False;136;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;162;-1569.867,1720.089;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;197;-1734.537,3060.247;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;144;-1826.303,1309.511;Inherit;False;Flow;20;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;200;-1585.683,3057.971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;160;-1385.326,1329.239;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;199;-1321.429,3127.971;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-1171.364,1280.573;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-603.7793,547.3562;Inherit;False;136;RimFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-619.0655,641.4795;Inherit;False;155;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-1085.042,3313.835;Inherit;False;Property;_DissolveEdgeIntensity;DissolveEdgeIntensity;28;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;198;-1138.162,3104.076;Inherit;True;Property;_DissolveRampTex;DissolveRampTex;27;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;-807.917,3214.323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-361.9858,577.8157;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-327.8068,731.0809;Inherit;False;Property;_HitWaveIntensity;HitWaveIntensity;3;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-672.8438,3120.01;Inherit;False;DissolveEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-91.84916,759.306;Inherit;False;47;HitWave;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-103.4545,659.345;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;91.82409,816.5255;Inherit;False;192;DissolveEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;201;-1320.761,2936.978;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;95.53955,679.9041;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;319.9096,587.6119;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-1121.491,2924.433;Inherit;False;DissolveAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;514.4842,785.8221;Inherit;False;203;DissolveAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;168;517.1963,668.782;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;139;15.88813,259.3074;Inherit;False;Property;_EmissColor;EmissColor;9;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;141;53.88819,472.3074;Inherit;False;Property;_EmissIntensity;EmissIntensity;10;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;131;-3021.53,-745.1635;Inherit;False;228;165;Properties;1;130;Properties;1,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;303.8883,389.3075;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;729.9656,701.6808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;169;888.1829,702.3243;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1807.079,-355.684;Inherit;False;Global;AffectorAmount;AffectorAmount;6;0;Create;False;0;0;True;0;False;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-2971.53,-695.1635;Inherit;False;Property;_CullMode;CullMode;0;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;39;-2034.647,-364.9418;Inherit;False;HitSize;0;20;0;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;524.1171,462.9328;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GlobalArrayNode;37;-2292.865,-363.8778;Inherit;False;HitPosition;0;20;2;False;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1055.757,413.2566;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ForceField;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;True;130;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;42;0;43;0
WireConnection;42;9;46;0
WireConnection;123;0;42;1
WireConnection;170;0;172;0
WireConnection;178;0;170;0
WireConnection;16;0;123;0
WireConnection;16;1;17;0
WireConnection;216;0;214;0
WireConnection;190;0;189;0
WireConnection;190;1;191;0
WireConnection;35;0;36;0
WireConnection;35;1;5;0
WireConnection;35;2;16;0
WireConnection;35;3;13;0
WireConnection;35;4;28;0
WireConnection;35;5;30;0
WireConnection;215;0;214;0
WireConnection;215;1;216;0
WireConnection;152;1;151;0
WireConnection;188;0;187;0
WireConnection;188;1;190;0
WireConnection;175;0;178;0
WireConnection;132;0;215;0
WireConnection;132;1;133;0
WireConnection;132;2;134;0
WireConnection;132;3;135;0
WireConnection;154;0;152;0
WireConnection;179;0;175;0
WireConnection;179;1;174;0
WireConnection;209;0;208;0
WireConnection;209;1;210;0
WireConnection;193;0;188;0
WireConnection;193;1;194;0
WireConnection;47;0;35;0
WireConnection;177;0;132;0
WireConnection;177;1;179;0
WireConnection;157;0;154;0
WireConnection;157;1;158;0
WireConnection;207;0;193;0
WireConnection;207;1;209;0
WireConnection;185;0;157;0
WireConnection;185;1;186;0
WireConnection;136;0;177;0
WireConnection;196;0;207;0
WireConnection;196;1;195;0
WireConnection;162;0;161;2
WireConnection;197;0;196;0
WireConnection;144;5;145;0
WireConnection;144;2;146;0
WireConnection;144;18;185;0
WireConnection;144;17;149;0
WireConnection;144;24;150;0
WireConnection;200;0;197;0
WireConnection;160;0;144;0
WireConnection;160;1;163;0
WireConnection;160;2;162;0
WireConnection;199;0;200;0
WireConnection;155;0;160;0
WireConnection;198;1;199;0
WireConnection;211;0;198;1
WireConnection;211;1;212;0
WireConnection;166;0;138;0
WireConnection;166;1;165;0
WireConnection;192;0;211;0
WireConnection;183;0;166;0
WireConnection;183;1;184;0
WireConnection;201;0;200;0
WireConnection;182;0;183;0
WireConnection;182;1;181;0
WireConnection;180;0;166;0
WireConnection;180;1;182;0
WireConnection;180;2;206;0
WireConnection;203;0;201;0
WireConnection;168;0;180;0
WireConnection;140;0;139;0
WireConnection;140;1;141;0
WireConnection;205;0;168;0
WireConnection;205;1;204;0
WireConnection;169;0;205;0
WireConnection;142;0;140;0
WireConnection;142;1;180;0
WireConnection;0;2;142;0
WireConnection;0;9;169;0
ASEEND*/
//CHKSM=199B65FAFB8B373661BCC47C2929C5B55EB28374
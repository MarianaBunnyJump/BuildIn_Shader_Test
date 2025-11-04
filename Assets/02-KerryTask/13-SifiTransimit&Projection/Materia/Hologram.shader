// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram"
{
	Properties
	{
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Tilling("Tilling", Float) = 200
		_TimeScale("TimeScale", Float) = 1
		[Toggle]_ZWrite("ZWrite", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_WireFrame("WireFrame", 2D) = "white" {}
		_WireFrameIntensity("WireFrameIntensity", Float) = 1
		_FlickControl("FlickControl", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0.3
		[HDR]_ScanlineColor("ScanlineColor", Color) = (0,0,0,0)
		_Scanline1("Scanline1", 2D) = "white" {}
		_Line1Alpha("Line 1 Alpha", Float) = 0
		_Line1Freq("Line 1 Freq", Float) = 2
		_Scan1Speed("Scan 1 Speed", Float) = 0
		_Line1Width("Line 1 Width", Float) = 0
		_Line1Hardness("Line 1 Hardness", Float) = 0
		_Scanline2("Scanline2", 2D) = "white" {}
		_Line2Alpha("Line 2 Alpha", Float) = 0
		_Line2Freq("Line 2 Freq", Float) = 2
		_Scan2Speed("Scan 2 Speed", Float) = 0
		_Line2Width("Line 2 Width", Float) = 0
		_Line2Hardness("Line 2 Hardness", Float) = 0
		_RandomVertexOffset("RandomVertexOffset", Vector) = (5,0,0,0)
		_GlicthTilling("Glicth Tilling", Float) = 3
		_GlicthOffset("GlicthOffset", Vector) = (-2.5,0,0,0)
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlitchFreq("GlitchFreq", Float) = 1
		_GlitchWidth("GlitchWidth", Float) = 0.25
		_GlitchSpreed("GlitchSpreed", Float) = -1
		_GlitchHardness("GlitchHardness", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
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
			float3 worldPos;
			float vertexToFrag159;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float _ZWrite;
		uniform float3 _RandomVertexOffset;
		uniform float _GlicthTilling;
		uniform float3 _GlicthOffset;
		uniform sampler2D _GlicthTex;
		uniform float _GlitchFreq;
		uniform float _GlitchSpreed;
		uniform float _GlitchWidth;
		uniform float _GlitchHardness;
		uniform float _Tilling;
		uniform float _TimeScale;
		uniform float _FlickControl;
		uniform float4 _Color0;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _Scanline1;
		uniform float _Line1Freq;
		uniform float _Scan1Speed;
		uniform float _Line1Width;
		uniform float _Line1Hardness;
		uniform sampler2D _Scanline2;
		uniform float _Line2Freq;
		uniform float _Scan2Speed;
		uniform float _Line2Width;
		uniform float _Line2Hardness;
		uniform float4 _ScanlineColor;
		uniform float _Line1Alpha;
		uniform float _Line2Alpha;
		uniform sampler2D _WireFrame;
		SamplerState sampler_WireFrame;
		uniform float4 _WireFrame_ST;
		uniform float _WireFrameIntensity;
		uniform float _Alpha;


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
			float3 viewToObjDir117 = mul( UNITY_MATRIX_T_MV, float4( _RandomVertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime106 = _Time.y * -2.5;
			float mulTime109 = _Time.y * -2.0;
			float2 appendResult107 = (float2((ase_worldPos.y*_GlicthTilling + mulTime106) , mulTime109));
			float simplePerlin2D108 = snoise( appendResult107 );
			simplePerlin2D108 = simplePerlin2D108*0.5 + 0.5;
			float3 objToWorld119 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime120 = _Time.y * -5.0;
			float mulTime123 = _Time.y * -1.0;
			float2 appendResult125 = (float2((( objToWorld119.x + objToWorld119.y + objToWorld119.z )*200.0 + mulTime120) , mulTime123));
			float simplePerlin2D126 = snoise( appendResult125 );
			simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
			float clampResult132 = clamp( (simplePerlin2D126*2.0 + -1.0) , 0.0 , 1.0 );
			float temp_output_133_0 = ( (simplePerlin2D108*2.0 + -1.0) * clampResult132 );
			float2 break134 = appendResult107;
			float2 appendResult137 = (float2(( 20.0 * break134.x ) , break134.y));
			float simplePerlin2D138 = snoise( appendResult137 );
			simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
			float clampResult140 = clamp( (simplePerlin2D138*2.0 + -1.0) , 0.0 , 1.0 );
			float3 GlitchVertexOffset115 = ( ( viewToObjDir117 * 0.01 ) * ( temp_output_133_0 + ( temp_output_133_0 * clampResult140 ) ) );
			float3 viewToObjDir152 = mul( UNITY_MATRIX_T_MV, float4( _GlicthOffset, 0 ) ).xyz;
			float3 objToWorld2_g6 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g6 = _Time.y * _GlitchSpreed;
			float2 appendResult9_g6 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g6.y )*_GlitchFreq + mulTime7_g6)));
			float clampResult23_g6 = clamp( ( ( tex2Dlod( _GlicthTex, float4( appendResult9_g6, 0, 0.0) ).r - _GlitchWidth ) * _GlitchHardness ) , 0.0 , 1.0 );
			float3 ScanlineOffset155 = ( ( viewToObjDir152 * 0.01 ) * clampResult23_g6 );
			v.vertex.xyz += ( GlitchVertexOffset115 + ScanlineOffset155 );
			v.vertex.w = 1;
			float3 objToWorld7 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime11 = _Time.y * _TimeScale;
			float2 appendResult12 = (float2((( objToWorld7.x + objToWorld7.y + objToWorld7.z )*_Tilling + mulTime11) , _Time.y));
			float simplePerlin2D13 = snoise( appendResult12 );
			simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
			float clampResult19 = clamp( (-0.5 + (simplePerlin2D13 - 0.0) * (2.0 - -0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult46 = lerp( 1.0 , clampResult19 , _FlickControl);
			o.vertexToFrag159 = lerpResult46;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float Flicking16 = i.vertexToFrag159;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV23 = dot( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )), ase_worldViewDir );
			float fresnelNode23 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV23, _RimPower ) );
			float FresnelFactor30 = max( fresnelNode23 , 0.0 );
			float3 objToWorld2_g4 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g4 = _Time.y * _Scan1Speed;
			float2 appendResult9_g4 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g4.y )*_Line1Freq + mulTime7_g4)));
			float clampResult23_g4 = clamp( ( ( tex2D( _Scanline1, appendResult9_g4 ).r - _Line1Width ) * _Line1Hardness ) , 0.0 , 1.0 );
			float temp_output_71_0 = clampResult23_g4;
			float3 objToWorld2_g5 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g5 = _Time.y * _Scan2Speed;
			float2 appendResult9_g5 = (float2(0.5 , (( ase_worldPos.y - objToWorld2_g5.y )*_Line2Freq + mulTime7_g5)));
			float clampResult23_g5 = clamp( ( ( tex2D( _Scanline2, appendResult9_g5 ).r - _Line2Width ) * _Line2Hardness ) , 0.0 , 1.0 );
			float temp_output_92_0 = clampResult23_g5;
			float4 ScanlineColor80 = ( ( temp_output_71_0 * temp_output_92_0 ) * _ScanlineColor );
			o.Emission = ( Flicking16 * ( _Color0 + ( _Color0 * FresnelFactor30 ) + max( ScanlineColor80 , float4( 0,0,0,0 ) ) ) ).rgb;
			float temp_output_93_0 = ( temp_output_92_0 * _Line2Alpha );
			float ScanlineAlpha83 = ( ( ( temp_output_71_0 * _Line1Alpha ) * temp_output_93_0 ) + temp_output_93_0 );
			float clampResult43 = clamp( ( _Color0.a + FresnelFactor30 + ScanlineAlpha83 ) , 0.0 , 1.0 );
			float2 uv_WireFrame = i.uv_texcoord * _WireFrame_ST.xy + _WireFrame_ST.zw;
			float Wireframe35 = ( tex2D( _WireFrame, uv_WireFrame ).r * _WireFrameIntensity );
			o.Alpha = ( clampResult43 * Wireframe35 * _Alpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.x = customInputData.vertexToFrag159;
				o.customPack1.yz = customInputData.uv_texcoord;
				o.customPack1.yz = v.texcoord;
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
				surfIN.vertexToFrag159 = IN.customPack1.x;
				surfIN.uv_texcoord = IN.customPack1.yz;
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
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1631;570;961;841;789.2144;-2200.872;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;143;-1664.728,1755.797;Inherit;False;2649.064;1429.219;RandomGlitchVertexOffset;35;106;103;105;109;104;119;121;122;120;107;123;124;136;134;125;135;126;137;138;131;108;132;139;110;112;140;133;117;141;114;113;142;111;115;160;RandomGlitchVertexOffset;1,0.4481132,0.9258888,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;103;-1405.359,2034.529;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;106;-1390.236,2279.858;Inherit;False;1;0;FLOAT;-2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1392.647,2183.858;Inherit;False;Property;_GlicthTilling;Glicth Tilling;32;0;Create;True;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;119;-1614.728,2407.434;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-1137.19,2113.158;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;109;-1131.795,2257.885;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-1389.182,2443.051;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1417.18,2579.572;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;120;-1428.394,2667.802;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;124;-1215.684,2510.542;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;123;-1194.48,2656.279;Inherit;False;1;0;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-894.9712,2127.474;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;20;-3322.261,-521.5502;Inherit;False;1900.856;488.6389;Flicking;15;47;16;46;19;18;13;12;14;9;11;10;8;7;15;159;Flicking;0,0.7429106,0.9811321,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;-999.7585,2529.644;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-789.8369,2849.464;Inherit;False;Constant;_Float2;Float 2;34;0;Create;True;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;7;-3272.261,-471.5502;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;15;-3244.734,-224.5934;Inherit;False;Property;_TimeScale;TimeScale;3;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;134;-862.8673,2939.389;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;126;-863.5386,2527.073;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-3046.715,-435.9338;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3052.896,-309.2303;Inherit;False;Property;_Tilling;Tilling;2;0;Create;True;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-3360.618,1523.078;Inherit;False;1609.248;1235.431;Scanline2;23;89;73;75;74;87;76;90;88;91;77;82;71;94;92;93;81;101;79;97;78;98;83;80;Scanline2;0.8396226,0.8336148,0.2415895,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-3082.655,-211.182;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-607.8369,2892.464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-3299.114,2478.358;Inherit;False;Property;_Scan2Speed;Scan 2 Speed;28;0;Create;True;0;0;False;0;False;0;-3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;9;-2873.217,-368.4427;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-3303.737,2398.772;Inherit;False;Property;_Line2Freq;Line 2 Freq;27;0;Create;True;0;0;False;0;False;2;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;73;-3299.558,1573.078;Inherit;True;Property;_Scanline1;Scanline1;19;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;91;-3285.706,2560.07;Inherit;False;Property;_Line2Width;Line 2 Width;29;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-3274.646,1932.493;Inherit;False;Property;_Line1Width;Line 1 Width;23;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;14;-2852.013,-222.7054;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;89;-3310.618,2200.656;Inherit;True;Property;_Scanline2;Scanline2;25;0;Create;True;0;0;False;0;False;None;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.CommentaryNode;31;-3304.108,108.9425;Inherit;False;1262.4;520;Fresnel;8;23;24;25;26;27;28;29;30;Fresnel;0.1902368,0.7335116,0.8962264,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;131;-597.4302,2537.109;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3262.675,2014.932;Inherit;False;Property;_Line1Hardness;Line 1 Hardness;24;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3288.055,1850.781;Inherit;False;Property;_Scan1Speed;Scan 1 Speed;22;0;Create;True;0;0;False;0;False;0;-1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-3292.678,1771.194;Inherit;False;Property;_Line1Freq;Line 1 Freq;21;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;-452.8366,2916.464;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-3273.735,2642.51;Inherit;False;Property;_Line2Hardness;Line 2 Hardness;30;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;108;-738.0397,2136.563;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;92;-2986.694,2304.933;Inherit;False;Scanline;-1;;5;1ee095baa6d6295439cb7708c3badf60;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-3254.108,158.9425;Inherit;True;Property;_NormalMap;NormalMap;5;0;Create;True;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-2671.958,2191.732;Inherit;False;Property;_Line1Alpha;Line 1 Alpha;20;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;71;-2975.634,1677.355;Inherit;False;Scanline;-1;;4;1ee095baa6d6295439cb7708c3badf60;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2820.691,2506.821;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;26;0;Create;True;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-2657.29,-349.3406;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;132;-329.4998,2571.191;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;138;-296.8732,2909.93;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2884.108,512.9425;Inherit;False;Property;_RimPower;RimPower;8;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-2521.07,-351.9118;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-2627.291,2381.821;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;139;-44.59948,2918.018;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2472.474,2136.667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;24;-2893.949,186.8752;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;156;-1375.923,784.8254;Inherit;False;1296.032;727.1219;ScanlineVertexOffset;12;147;149;145;146;148;144;153;150;152;151;154;155;ScanlineVertexOffset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2886.108,424.9425;Inherit;False;Property;_RimScale;RimScale;7;0;Create;True;0;0;False;0;False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;110;-439.4127,2161.752;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;160;-203.8181,2702.757;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2881.108,341.9425;Inherit;False;Property;_RimBias;RimBias;6;0;Create;True;0;0;False;0;False;0;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;150;-1067.928,834.8254;Inherit;False;Property;_GlicthOffset;GlicthOffset;33;0;Create;True;0;0;False;0;False;-2.5,0,0;-2.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;79;-2511.131,1761.287;Inherit;False;Property;_ScanlineColor;ScanlineColor;15;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.3778523,1.124889,5.340313,0.5372549;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;18;-2272.468,-322.2892;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;140;152.3916,2931.017;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;112;-617.953,1805.797;Inherit;False;Property;_RandomVertexOffset;RandomVertexOffset;31;0;Create;True;0;0;False;0;False;5,0,0;5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-2299,2193.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-2587.747,1676.93;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;23;-2654.629,255.7615;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-34.46246,2372.625;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1322.477,1252.602;Inherit;False;Property;_GlitchSpreed;GlitchSpreed;37;0;Create;True;0;0;False;0;False;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-1322.477,1395.947;Inherit;False;Property;_GlitchHardness;GlitchHardness;38;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2206.338,-148.974;Inherit;False;Property;_FlickControl;FlickControl;11;0;Create;True;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;152;-888.8975,856.4024;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;19;-2089.072,-311.0596;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;145;-1325.923,966.4001;Inherit;True;Property;_GlicthTex;GlicthTex;34;0;Create;True;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TransformDirectionNode;117;-438.9219,1827.374;Inherit;False;View;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;146;-1314.576,1175.85;Inherit;False;Property;_GlitchFreq;GlitchFreq;35;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-455.8409,2003.645;Inherit;False;Constant;_Float0;Float 0;33;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-853.8165,1015.674;Inherit;False;Constant;_Float3;Float 0;33;0;Create;True;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-2144.231,2287.883;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;29;-2402.286,310.862;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-1313.448,1327.096;Inherit;False;Property;_GlitchWidth;GlitchWidth;36;0;Create;True;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;36;-1953.694,120.4774;Inherit;False;759.3981;369.8234;WireFrame;4;32;33;34;35;WireFrame;0.1279681,0.9716981,0.05958529,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;197.1886,2509.969;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-2278.059,1677.993;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1809.205,374.301;Inherit;False;Property;_WireFrameIntensity;WireFrameIntensity;10;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-1975.37,2219.469;Inherit;False;ScanlineAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-625.3225,977.6693;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-2265.707,306.2387;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1903.694,170.4774;Inherit;True;Property;_WireFrame;WireFrame;9;0;Create;True;0;0;False;0;False;-1;None;92f284b27dea88e41885444624ec2963;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;46;-1929.1,-296.7994;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;457.4359,2463.077;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-229.3466,1952.641;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2011.914,1669.691;Inherit;False;ScanlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;144;-1020.725,1136.781;Inherit;True;Scanline;-1;;6;1ee095baa6d6295439cb7708c3badf60;0;6;20;SAMPLER2D;0;False;16;FLOAT;0;False;18;FLOAT;2;False;19;FLOAT;1;False;21;FLOAT;0;False;22;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-884.7166,152.5347;Inherit;False;80;ScanlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1570.378,269.6688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-880.5867,59.75761;Inherit;False;30;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-1162.69,-60.93655;Inherit;False;Property;_Color0;Color 0;0;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.1323111,0.4884376,1.605559,0.1215686;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;84;-1070.996,395.6376;Inherit;False;83;ScanlineAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;559.7421,2183.834;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-445.4662,1125.611;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-1069.25,294.3333;Inherit;False;30;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;159;-1822.065,-397.5825;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-836.1591,270.6875;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-303.8907,1136.329;Inherit;False;ScanlineOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1418.296,264.1107;Inherit;False;Wireframe;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;86;-687.716,138.0802;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;739.3367,2219.493;Inherit;True;GlitchVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1625,-310.6065;Inherit;False;Flicking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-696.7165,-1.092877;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;68;-3348.056,758.7621;Inherit;False;1755.906;563.5271;Scanline;17;51;49;50;56;53;55;52;54;57;64;58;66;63;67;59;61;62;Scanline;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-498.5695,583.5178;Inherit;False;115;GlitchVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-769.0649,433.0251;Inherit;False;35;Wireframe;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-591.3311,-140.5121;Inherit;False;16;Flicking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-481.113,655.3408;Inherit;False;155;ScanlineOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2527.85,-776.7056;Inherit;False;214;166;Properties;1;21;Properties;0.9245283,0.2311321,0.2311321,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;43;-696.1655,293.1833;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-535.0621,-54.51454;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-782.7039,525.7366;Inherit;False;Property;_Alpha;Alpha;12;0;Create;True;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;61;-2411.686,860.3613;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-2108.485,1089.845;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-383.2729,-106.7228;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;49;-3286.949,808.7621;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;157;-227.274,577.509;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2477.85,-726.7056;Inherit;False;Property;_ZWrite;ZWrite;4;1;[Toggle];Create;True;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1947.783,1119.786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-2922.544,1144.518;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2123.025,1206.288;Inherit;False;Property;_ScanlinePower;ScanlinePower;18;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-3136.129,1151.247;Inherit;False;Property;_ScanlineSpeed;ScanlineSpeed;16;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3079.346,1052.381;Inherit;False;Property;_ScanlineTilling;ScanlineTilling;14;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-1816.149,1067.751;Inherit;False;scanline;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-477.1262,350.6083;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-2425.955,973.1915;Inherit;True;Property;_ScanlineTex;ScanlineTex;13;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;62;-2548.852,1208.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;-3056.765,906.6414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2889.346,977.3821;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2415.101,1190.579;Inherit;False;Property;_ScanlineInvert;ScanlineInvert;17;0;Create;True;0;0;False;0;False;0.35;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;51;-3298.056,970.8986;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-2702.844,1022.319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-2567.697,1005.338;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-107.3566,3.578553;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Hologram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;104;0;103;2
WireConnection;104;1;105;0
WireConnection;104;2;106;0
WireConnection;122;0;119;1
WireConnection;122;1;119;2
WireConnection;122;2;119;3
WireConnection;124;0;122;0
WireConnection;124;1;121;0
WireConnection;124;2;120;0
WireConnection;107;0;104;0
WireConnection;107;1;109;0
WireConnection;125;0;124;0
WireConnection;125;1;123;0
WireConnection;134;0;107;0
WireConnection;126;0;125;0
WireConnection;8;0;7;1
WireConnection;8;1;7;2
WireConnection;8;2;7;3
WireConnection;11;0;15;0
WireConnection;135;0;136;0
WireConnection;135;1;134;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;9;2;11;0
WireConnection;131;0;126;0
WireConnection;137;0;135;0
WireConnection;137;1;134;1
WireConnection;108;0;107;0
WireConnection;92;20;89;0
WireConnection;92;18;90;0
WireConnection;92;19;88;0
WireConnection;92;21;91;0
WireConnection;92;22;87;0
WireConnection;71;20;73;0
WireConnection;71;18;74;0
WireConnection;71;19;75;0
WireConnection;71;21;76;0
WireConnection;71;22;77;0
WireConnection;12;0;9;0
WireConnection;12;1;14;0
WireConnection;132;0;131;0
WireConnection;138;0;137;0
WireConnection;13;0;12;0
WireConnection;93;0;92;0
WireConnection;93;1;94;0
WireConnection;139;0;138;0
WireConnection;81;0;71;0
WireConnection;81;1;82;0
WireConnection;24;0;25;0
WireConnection;110;0;108;0
WireConnection;160;0;132;0
WireConnection;18;0;13;0
WireConnection;140;0;139;0
WireConnection;97;0;81;0
WireConnection;97;1;93;0
WireConnection;101;0;71;0
WireConnection;101;1;92;0
WireConnection;23;0;24;0
WireConnection;23;1;26;0
WireConnection;23;2;27;0
WireConnection;23;3;28;0
WireConnection;133;0;110;0
WireConnection;133;1;160;0
WireConnection;152;0;150;0
WireConnection;19;0;18;0
WireConnection;117;0;112;0
WireConnection;98;0;97;0
WireConnection;98;1;93;0
WireConnection;29;0;23;0
WireConnection;141;0;133;0
WireConnection;141;1;140;0
WireConnection;78;0;101;0
WireConnection;78;1;79;0
WireConnection;83;0;98;0
WireConnection;153;0;152;0
WireConnection;153;1;151;0
WireConnection;30;0;29;0
WireConnection;46;1;19;0
WireConnection;46;2;47;0
WireConnection;142;0;133;0
WireConnection;142;1;141;0
WireConnection;113;0;117;0
WireConnection;113;1;114;0
WireConnection;80;0;78;0
WireConnection;144;20;145;0
WireConnection;144;18;146;0
WireConnection;144;19;147;0
WireConnection;144;21;148;0
WireConnection;144;22;149;0
WireConnection;33;0;32;1
WireConnection;33;1;34;0
WireConnection;111;0;113;0
WireConnection;111;1;142;0
WireConnection;154;0;153;0
WireConnection;154;1;144;0
WireConnection;159;0;46;0
WireConnection;41;0;1;4
WireConnection;41;1;42;0
WireConnection;41;2;84;0
WireConnection;155;0;154;0
WireConnection;35;0;33;0
WireConnection;86;0;85;0
WireConnection;115;0;111;0
WireConnection;16;0;159;0
WireConnection;38;0;1;0
WireConnection;38;1;37;0
WireConnection;43;0;41;0
WireConnection;39;0;1;0
WireConnection;39;1;38;0
WireConnection;39;2;86;0
WireConnection;63;0;58;1
WireConnection;63;1;64;0
WireConnection;4;0;17;0
WireConnection;4;1;39;0
WireConnection;157;0;116;0
WireConnection;157;1;158;0
WireConnection;67;0;63;0
WireConnection;67;1;66;0
WireConnection;55;0;56;0
WireConnection;59;0;67;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;44;2;48;0
WireConnection;58;1;57;0
WireConnection;50;0;49;2
WireConnection;50;1;51;2
WireConnection;52;0;50;0
WireConnection;52;1;53;0
WireConnection;54;0;52;0
WireConnection;54;1;55;0
WireConnection;57;1;54;0
WireConnection;0;2;4;0
WireConnection;0;9;44;0
WireConnection;0;11;157;0
ASEEND*/
//CHKSM=B401197E86037ED43144F4ED123C95A2E7F2A3F9
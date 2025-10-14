// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "5_Disslove_Double_Ramp"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.3293458
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 2
		_EdgeIntensity("EdgeIntensity", Float) = 2
		[Toggle(_KEYWORD0_ON)] _Keyword0("Keyword 0", Float) = 0
		_Stread("Stread", Range( 0 , 1)) = 0.06411535
		_TimeSpeed("TimeSpeed", Float) = 0.03
		_Softness("Softness", Range( 0 , 0.5)) = 0.4914269
		_Noise("Noise", 2D) = "white" {}
		_RampTex("RampTex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _KEYWORD0_ON
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _RampTex;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _TimeSpeed;
		uniform float _ChangeAmount;
		uniform float _Stread;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float _Softness;
		uniform float _EdgeWidth;
		uniform float _EdgeIntensity;
		SamplerState sampler_MainTex;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode23 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime3 = _Time.y * _TimeSpeed;
			#ifdef _KEYWORD0_ON
				float staticSwitch8 = _ChangeAmount;
			#else
				float staticSwitch8 = frac( mulTime3 );
			#endif
			float Gradient13 = ( ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Stread + (staticSwitch8 - 0.0) * (1.0 - -_Stread) / (1.0 - 0.0)) ) / _Stread ) * 2.0 );
			float2 temp_cast_0 = (0.0).xx;
			float2 panner35 = ( 1.0 * _Time.y * temp_cast_0 + i.uv_texcoord);
			float Noise38 = tex2D( _Noise, panner35 ).r;
			float temp_output_40_0 = ( Gradient13 - Noise38 );
			float clampResult21 = clamp( ( 1.0 - ( distance( temp_output_40_0 , _Softness ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float2 appendResult44 = (float2(( 1.0 - clampResult21 ) , 0.0));
			float4 RampColor46 = tex2D( _RampTex, appendResult44 );
			float4 lerpResult29 = lerp( tex2DNode23 , ( RampColor46 * tex2DNode23 * _EdgeIntensity ) , clampResult21);
			o.Emission = lerpResult29.rgb;
			o.Alpha = ( tex2DNode23.a * step( tex2DNode23.a , temp_output_40_0 ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
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
1193;676;1353;888;470.6642;51.76642;1.83667;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-2380.767,-490.823;Inherit;False;1920.228;919.8607;Gradient;14;13;12;11;10;9;8;7;4;5;6;3;2;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2328.911,-213.3605;Inherit;False;Property;_TimeSpeed;TimeSpeed;8;0;Create;True;0;0;False;0;False;0.03;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-2071.616,-185.6271;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2314.997,76.79713;Inherit;False;Property;_ChangeAmount;ChangeAmount;2;0;Create;True;0;0;False;0;False;0.3293458;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2009.063,240.0543;Inherit;False;Property;_Stread;Stread;7;0;Create;True;0;0;False;0;False;0.06411535;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;4;-1898.852,-212.7113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;7;-1608.523,274.0937;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;8;-1673.933,-74.89;Inherit;False;Property;_Keyword0;Keyword 0;6;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;10;-1392.174,-147.1154;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1681.891,-407.4464;Inherit;True;Property;_Gradient;Gradient;1;0;Create;True;0;0;False;0;False;-1;89a4bd307b8d8fc41b86ee482feaf974;63fefab669d898c4b8f7a92523ad7bd3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1740.554,861.9938;Inherit;False;Constant;_NoiseSpeed;NoiseSpeed;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-1800.874,685.787;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1241.591,-369.6567;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-1076.861,-37.65046;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;35;-1518.605,730.6126;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1022.524,271.942;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-1274.232,704.4114;Inherit;True;Property;_Noise;Noise;10;0;Create;True;0;0;False;0;False;-1;63fefab669d898c4b8f7a92523ad7bd3;63fefab669d898c4b8f7a92523ad7bd3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-825.6733,60.3929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-658.8254,31.51641;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-930.5198,729.2552;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-450.4409,-411.8444;Inherit;True;13;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-208.1229,292.4952;Inherit;False;2343.652;712.329;EdgeColor;10;44;21;20;19;18;17;31;45;46;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-445.293,-201.6981;Inherit;True;38;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-158.4675,-320.1895;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-157.9317,435.021;Inherit;False;Property;_Softness;Softness;9;0;Create;True;0;0;False;0;False;0.4914269;0.26;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;18;160.9793,430.5373;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;95.1004,674.9533;Inherit;False;Property;_EdgeWidth;EdgeWidth;3;0;Create;True;0;0;False;0;False;2;0.04;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;19;456.9788,483.1996;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;640.835,479.9425;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;21;832.2349,481.0425;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;48;1079.184,540.7283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;1247.273,547.5421;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;45;1436.637,545.7652;Inherit;True;Property;_RampTex;RampTex;11;0;Create;True;0;0;False;0;False;-1;8b1a5cf33680b3b4f9b3255b3c781c5b;8b1a5cf33680b3b4f9b3255b3c781c5b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;1803.61,571.7881;Inherit;False;RampColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;217.571,-484.2783;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;4;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;343.0554,-642.9507;Inherit;False;46;RampColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;23;-267.9733,-788.6672;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;False;-1;818324896388d98438058d56f7e522f3;818324896388d98438058d56f7e522f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;552.3489,-513.3517;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;49;153.0486,-239.0786;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;335.9802,-313.4809;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;766.7875,-711.157;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;25;311.7195,-982.1656;Inherit;False;Property;_Color0;Color 0;5;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1105.144,-602.7968;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;5_Disslove_Double_Ramp;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;0
WireConnection;4;0;3;0
WireConnection;7;0;5;0
WireConnection;8;1;4;0
WireConnection;8;0;6;0
WireConnection;10;0;8;0
WireConnection;10;3;7;0
WireConnection;11;0;9;1
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;12;1;5;0
WireConnection;35;0;34;0
WireConnection;35;2;36;0
WireConnection;33;1;35;0
WireConnection;41;0;12;0
WireConnection;41;1;42;0
WireConnection;13;0;41;0
WireConnection;38;0;33;1
WireConnection;40;0;15;0
WireConnection;40;1;39;0
WireConnection;18;0;40;0
WireConnection;18;1;31;0
WireConnection;19;0;18;0
WireConnection;19;1;17;0
WireConnection;20;0;19;0
WireConnection;21;0;20;0
WireConnection;48;0;21;0
WireConnection;44;0;48;0
WireConnection;45;1;44;0
WireConnection;46;0;45;0
WireConnection;26;0;47;0
WireConnection;26;1;23;0
WireConnection;26;2;22;0
WireConnection;49;0;23;4
WireConnection;49;1;40;0
WireConnection;30;0;23;4
WireConnection;30;1;49;0
WireConnection;29;0;23;0
WireConnection;29;1;26;0
WireConnection;29;2;21;0
WireConnection;0;2;29;0
WireConnection;0;9;30;0
ASEEND*/
//CHKSM=DFABA5790276C8CB0A2F18531B42F8F89DA8CB18
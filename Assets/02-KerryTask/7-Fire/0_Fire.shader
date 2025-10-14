// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "0_Fire"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_TintColor("TintColor", Color) = (0,0,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 1)) = 0
		_GradientEndControl("GradientEndControl", Float) = 2
		_EmissiIntensity("EmissiIntensity", Float) = 3
		_EndMiss("EndMiss", Range( 0 , 1)) = 0.47
		_FireShape("FireShape", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0.1
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
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _TintColor;
		uniform float _EmissiIntensity;
		uniform float _EndMiss;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _GradientEndControl;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float _Softness;
		uniform sampler2D _FireShape;
		SamplerState sampler_FireShape;
		uniform float _NoiseIntensity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break68 = ( _TintColor * _EmissiIntensity );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float4 tex2DNode53 = tex2D( _Gradient, uv_Gradient );
			float GradientEndControl65 = ( ( 1.0 - tex2DNode53.r ) * _GradientEndControl );
			float4 appendResult69 = (float4(break68.r , ( break68.g + ( _EndMiss * GradientEndControl65 ) ) , break68.b , 0.0));
			o.Emission = appendResult69.xyz;
			float2 panner43 = ( 1.0 * _Time.y * _NoiseSpeed + i.uv_texcoord);
			float Noise57 = tex2D( _Noise, panner43 ).r;
			float clampResult55 = clamp( ( Noise57 - _Softness ) , 0.0 , 1.0 );
			float Gradient56 = tex2DNode53.r;
			float smoothstepResult36 = smoothstep( clampResult55 , Noise57 , Gradient56);
			float2 appendResult88 = (float2(( i.uv_texcoord.x + ( (Noise57*2.0 + -1.0) * _NoiseIntensity * GradientEndControl65 ) ) , i.uv_texcoord.y));
			float4 tex2DNode76 = tex2D( _FireShape, appendResult88 );
			float clampResult94 = clamp( ( ( tex2DNode76.r * tex2DNode76.r ) * 3.0 ) , 0.0 , 1.0 );
			float FireShape96 = clampResult94;
			o.Alpha = ( smoothstepResult36 * FireShape96 );
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
977;487;1353;1115;1533.588;301.9139;1.813477;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;-3002.216,-135.8458;Inherit;False;1356.874;659.345;GradientAndNoise;12;65;64;62;63;56;54;57;53;44;43;45;46;;0.4669811,0.9179161,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;45;-2952.216,172.3589;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;46;-2951.11,332.517;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;1;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-2889.052,-61.79225;Inherit;False;0;53;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;43;-2715.953,251.5222;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;53;-2620.312,-85.84578;Inherit;True;Property;_Gradient;Gradient;3;0;Create;True;0;0;False;0;False;-1;559aa92a3d5226b4ba36263a95073075;fdb7bb09d8edcf642b01b32a58ce044d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-2522.743,199.8372;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;c75f2bae5d9fca94da9f4b2be19dfcf9;c75f2bae5d9fca94da9f4b2be19dfcf9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;62;-2308.989,7.696646;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2564.17,114.4883;Inherit;False;Property;_GradientEndControl;GradientEndControl;5;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2138.365,31.17723;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-2208.38,228.2512;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-2998.562,591.8256;Inherit;False;2041.341;691.9329;shape;14;96;94;91;90;92;76;88;80;81;77;89;82;83;79;;1,0.6179246,0.6179246,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1915.422,58.1772;Inherit;True;GradientEndControl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-2948.562,883.1415;Inherit;True;57;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;89;-2713.68,889.5519;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-2638.408,1185.958;Inherit;False;65;GradientEndControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-2609.151,1073.385;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;9;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-2756.821,644.7476;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2407.686,1032.058;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-2469.294,649.5264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;88;-2291.628,683.4338;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;76;-2104.479,642.2706;Inherit;True;Property;_FireShape;FireShape;8;0;Create;True;0;0;False;0;False;-1;b374c76622a7fb94597be826891ab0e1;b374c76622a7fb94597be826891ab0e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-1772.059,641.8256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1679.222,890.4077;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-677.6353,-45.90426;Inherit;False;Property;_EmissiIntensity;EmissiIntensity;6;0;Create;True;0;0;False;0;False;3;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1528.222,681.4078;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-686.754,-256.8844;Inherit;False;Property;_TintColor;TintColor;2;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;58;-785.8976,472.0803;Inherit;False;57;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-866.9373,610.3578;Inherit;False;Property;_Softness;Softness;4;0;Create;True;0;0;False;0;False;0;0.6878625;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;94;-1349.221,701.4078;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-457.4442,47.34669;Inherit;False;Property;_EndMiss;EndMiss;7;0;Create;True;0;0;False;0;False;0.47;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-376.7196,-156.2001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-2247.94,-101.357;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-433.9822,141.7515;Inherit;False;65;GradientEndControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;-590.4222,574.2367;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-1181.723,741.4594;Inherit;False;FireShape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;55;-449.1824,575.7228;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-112.3439,81.03791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;68;-208.9682,-154.6685;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;60;-540.1459,422.877;Inherit;False;56;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-166.9989,756.3305;Inherit;False;96;FireShape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-204.6613,490.2668;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;29.57015,6.110938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-400.6892,244.4251;Inherit;False;57;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;111.6705,-167.1376;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;204.4154,677.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;699.4915,452.4023;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;0_Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;0;45;0
WireConnection;43;2;46;0
WireConnection;53;1;54;0
WireConnection;44;1;43;0
WireConnection;62;0;53;1
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;57;0;44;1
WireConnection;65;0;63;0
WireConnection;89;0;79;0
WireConnection;81;0;89;0
WireConnection;81;1;82;0
WireConnection;81;2;83;0
WireConnection;80;0;77;1
WireConnection;80;1;81;0
WireConnection;88;0;80;0
WireConnection;88;1;77;2
WireConnection;76;1;88;0
WireConnection;90;0;76;1
WireConnection;90;1;76;1
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;94;0;91;0
WireConnection;67;0;11;0
WireConnection;67;1;66;0
WireConnection;56;0;53;1
WireConnection;48;0;58;0
WireConnection;48;1;47;0
WireConnection;96;0;94;0
WireConnection;55;0;48;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;68;0;67;0
WireConnection;36;0;60;0
WireConnection;36;1;55;0
WireConnection;36;2;58;0
WireConnection;70;0;68;1
WireConnection;70;1;73;0
WireConnection;69;0;68;0
WireConnection;69;1;70;0
WireConnection;69;2;68;2
WireConnection;78;0;36;0
WireConnection;78;1;97;0
WireConnection;0;2;69;0
WireConnection;0;9;78;0
ASEEND*/
//CHKSM=E7FDEF37ED117C6E276814F1B6C4C0B65011A632
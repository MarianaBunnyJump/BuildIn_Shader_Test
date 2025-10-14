// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "6_Disslove_Double_Vertical"
{
	Properties
	{
		_MainTex1("MainTex", 2D) = "white" {}
		_ChangeAmount1("ChangeAmount", Range( 0 , 1)) = 0.5559191
		_EdgeWidth1("EdgeWidth", Range( 0 , 2)) = 0.1779765
		_EdgeIntensity1("EdgeIntensity", Float) = 2
		[Toggle(_KEYWORD1_ON)] _Keyword1("Keyword 0", Float) = 1
		_Stread1("Stread", Range( 0 , 1)) = 1
		_TimeSpeed1("TimeSpeed", Float) = 0.03
		_Softness1("Softness", Range( 0 , 0.5)) = 0.3373984
		_Noise1("Noise", 2D) = "white" {}
		_ObjectScale("ObjectScale", Float) = 3.5
		[Toggle(_DIR_INV_ON_ON)] _DIR_INV_ON("_DIR_INV_ON", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _DIR_INV_ON_ON
		#pragma shader_feature_local _KEYWORD1_ON
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _EdgeIntensity1;
		uniform float _ObjectScale;
		uniform float _TimeSpeed1;
		uniform float _ChangeAmount1;
		uniform float _Stread1;
		uniform sampler2D _Noise1;
		SamplerState sampler_Noise1;
		uniform float _Softness1;
		uniform float _EdgeWidth1;
		uniform sampler2D _MainTex1;
		uniform float4 _MainTex1_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 temp_cast_0 = (0.18).xxx;
			o.Albedo = temp_cast_0;
			float4 color51 = IsGammaSpace() ? float4(0.3466536,1.536094,1.792453,0) : float4(0.09850044,2.571101,3.610648,0);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld42 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult45 = clamp( ( ( length( ( ase_worldPos - objToWorld42 ) ) - 0.0 ) / _ObjectScale ) , 0.0 , 1.0 );
			#ifdef _DIR_INV_ON_ON
				float staticSwitch48 = ( 1.0 - clampResult45 );
			#else
				float staticSwitch48 = clampResult45;
			#endif
			float mulTime3 = _Time.y * _TimeSpeed1;
			#ifdef _KEYWORD1_ON
				float staticSwitch8 = _ChangeAmount1;
			#else
				float staticSwitch8 = frac( mulTime3 );
			#endif
			float Gradient18 = ( ( ( staticSwitch48 - (-_Stread1 + (staticSwitch8 - 0.0) * (1.0 - -_Stread1) / (1.0 - 0.0)) ) / _Stread1 ) * 2.0 );
			float2 temp_cast_1 = (0.0).xx;
			float2 panner19 = ( 1.0 * _Time.y * temp_cast_1 + i.uv_texcoord);
			float Noise24 = ( 1.0 - tex2D( _Noise1, panner19 ).r );
			float temp_output_31_0 = ( Gradient18 - Noise24 );
			float temp_output_25_0 = distance( temp_output_31_0 , _Softness1 );
			float clampResult34 = clamp( ( 1.0 - ( temp_output_25_0 / _EdgeWidth1 ) ) , 0.0 , 1.0 );
			o.Emission = ( color51 * _EdgeIntensity1 * clampResult34 ).rgb;
			float2 uv_MainTex1 = i.uv_texcoord * _MainTex1_ST.xy + _MainTex1_ST.zw;
			o.Alpha = ( tex2D( _MainTex1, uv_MainTex1 ) * step( temp_output_31_0 , temp_output_25_0 ) ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
541;338;1353;876;3173.334;1404.627;1.398067;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-2828.032,-965.4591;Inherit;False;2538.307;1419.816;Gradient;24;18;16;13;12;11;10;48;8;7;49;45;5;4;6;46;3;47;43;2;41;42;56;58;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;41;-2674.605,-912.7623;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;42;-2696.133,-735.7845;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;-2438.037,-808.6888;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;56;-2284.433,-802.4116;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2353.324,-698.6782;Inherit;False;Constant;_Radius;Radius;12;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-2132.428,-820.3093;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2187.005,-661.2201;Inherit;False;Property;_ObjectScale;ObjectScale;10;0;Create;True;0;0;False;0;False;3.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2415.291,-258.7639;Inherit;False;Property;_TimeSpeed1;TimeSpeed;7;0;Create;True;0;0;False;0;False;0.03;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;46;-1988.403,-803.8615;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-2157.995,-231.0305;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2230.963,-24.59904;Inherit;False;Property;_ChangeAmount1;ChangeAmount;2;0;Create;True;0;0;False;0;False;0.5559191;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;45;-1832.703,-812.1024;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1925.029,138.6582;Inherit;False;Property;_Stread1;Stread;6;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;6;-1985.232,-258.1147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;49;-1584.965,-663.6345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;8;-1589.899,-176.2863;Inherit;False;Property;_Keyword1;Keyword 0;5;0;Create;True;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;7;-1524.489,172.6976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-871.7557,706.7057;Inherit;False;Constant;_NoiseSpeed1;NoiseSpeed;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-932.0757,530.4989;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-1308.14,-248.5117;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;48;-1432.237,-822.1578;Inherit;False;Property;_DIR_INV_ON;_DIR_INV_ON;11;0;Create;True;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-980.6409,-658.0826;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-649.8066,575.3245;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-938.4905,170.5459;Inherit;False;Constant;_Float1;Float 0;11;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-420.7191,557.6149;Inherit;True;Property;_Noise1;Noise;9;0;Create;True;0;0;False;0;False;-1;64c6680852356db499f760a5a23c9cfc;64c6680852356db499f760a5a23c9cfc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-992.8276,-83.52973;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;54;-95.04004,578.83;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-741.6398,-41.00336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-574.7915,-69.87995;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;84.33009,575.6654;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-169.3676,-174.3826;Inherit;True;24;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-172.2326,-404.855;Inherit;True;18;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;17;512.1487,141.2735;Inherit;False;1388.417;512.8556;EdgeColor;6;34;32;27;25;23;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;136.7197,-252.4659;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;542.3571,220.8775;Inherit;False;Property;_Softness1;Softness;8;0;Create;True;0;0;False;0;False;0.3373984;0.26;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;812.1403,454.5144;Inherit;False;Property;_EdgeWidth1;EdgeWidth;3;0;Create;True;0;0;False;0;False;0.1779765;0.04;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;25;878.0192,210.0987;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;27;1118.63,255.6139;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;1357.875,259.5037;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;390.1929,-613.3071;Inherit;True;Property;_MainTex1;MainTex;1;0;Create;True;0;0;False;0;False;-1;89a4bd307b8d8fc41b86ee482feaf974;818324896388d98438058d56f7e522f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;55;599.5349,-303.2871;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;942.8197,-731.5235;Inherit;False;Constant;_EdgeColor;EdgeColor;14;1;[HDR];Create;True;0;0;False;0;False;0.3466536,1.536094,1.792453,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;966.0739,-535.3201;Inherit;False;Property;_EdgeIntensity1;EdgeIntensity;4;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;34;1549.274,260.6038;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;1198.473,-631.5052;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;57;-2397.882,-1129.261;Inherit;False;SphereMask;-1;;1;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT3;0,0,0;False;14;FLOAT;0;False;12;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;1394.943,-781.6855;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;799.1501,-439.1572;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1586.13,-662.0922;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;6_Disslove_Double_Vertical;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;56;0;43;0
WireConnection;58;0;56;0
WireConnection;58;1;59;0
WireConnection;46;0;58;0
WireConnection;46;1;47;0
WireConnection;3;0;2;0
WireConnection;45;0;46;0
WireConnection;6;0;3;0
WireConnection;49;0;45;0
WireConnection;8;1;6;0
WireConnection;8;0;4;0
WireConnection;7;0;5;0
WireConnection;10;0;8;0
WireConnection;10;3;7;0
WireConnection;48;1;45;0
WireConnection;48;0;49;0
WireConnection;11;0;48;0
WireConnection;11;1;10;0
WireConnection;19;0;15;0
WireConnection;19;2;14;0
WireConnection;21;1;19;0
WireConnection;13;0;11;0
WireConnection;13;1;5;0
WireConnection;54;0;21;1
WireConnection;16;0;13;0
WireConnection;16;1;12;0
WireConnection;18;0;16;0
WireConnection;24;0;54;0
WireConnection;31;0;20;0
WireConnection;31;1;26;0
WireConnection;25;0;31;0
WireConnection;25;1;22;0
WireConnection;27;0;25;0
WireConnection;27;1;23;0
WireConnection;32;0;27;0
WireConnection;55;0;31;0
WireConnection;55;1;25;0
WireConnection;34;0;32;0
WireConnection;52;0;51;0
WireConnection;52;1;28;0
WireConnection;52;2;34;0
WireConnection;37;0;30;0
WireConnection;37;1;55;0
WireConnection;0;0;53;0
WireConnection;0;2;52;0
WireConnection;0;9;37;0
ASEEND*/
//CHKSM=201E83C66CF6D6DDFC004FBED52B0220EECFE816
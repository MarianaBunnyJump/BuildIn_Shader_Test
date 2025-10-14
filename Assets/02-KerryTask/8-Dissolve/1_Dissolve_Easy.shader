// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5559191
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.554593
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		[Toggle(_KEYWORD0_ON)] _Keyword0("Keyword 0", Float) = 1
		_TimeSpeed("TimeSpeed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _KEYWORD0_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color0;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _TimeSpeed;
		uniform float _ChangeAmount;
		uniform float _EdgeWidth;
		SamplerState sampler_MainTex;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime31 = _Time.y * _TimeSpeed;
			#ifdef _KEYWORD0_ON
				float staticSwitch38 = _ChangeAmount;
			#else
				float staticSwitch38 = frac( mulTime31 );
			#endif
			float Gradient24 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-1.0 + (staticSwitch38 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) / 1.0 );
			float clampResult16 = clamp( ( 1.0 - ( distance( Gradient24 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float EdgeFrame28 = clampResult16;
			float4 lerpResult21 = lerp( tex2DNode1 , ( _Color0 * 2.0 * tex2DNode1 ) , EdgeFrame28);
			o.Emission = lerpResult21.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , Gradient24 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;0;1920;1011;2582.654;574.936;1.474327;True;False
Node;AmplifyShaderEditor.CommentaryNode;22;-2533.039,-101.6935;Inherit;False;1768.176;798.5169;Gradient;12;41;24;37;4;8;2;38;40;39;32;5;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2474.234,182.1291;Inherit;False;Property;_TimeSpeed;TimeSpeed;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-2322.94,186.5421;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;32;-2145.177,186.4182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2239.187,508.3416;Inherit;False;Constant;_Stread;Stread;7;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2371.278,355.6847;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;False;0;False;0.5559191;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;40;-1907.288,450.6202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;38;-1978.258,314.2395;Inherit;False;Property;_Keyword0;Keyword 0;6;0;Create;True;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1986.216,-18.31673;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;False;0;False;-1;63fefab669d898c4b8f7a92523ad7bd3;89a4bd307b8d8fc41b86ee482feaf974;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1696.499,242.0141;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1496.746,93.39037;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;37;-1262.051,408.8628;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1003.573,217.9449;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-672.1475,304.175;Inherit;False;1295.767;477.6484;EdgeColor;7;16;14;12;10;13;11;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-668.9877,112.4992;Inherit;False;24;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-627.5259,440.5308;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;10;-398.9275,373.0003;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-464.8064,617.4154;Inherit;False;Property;_EdgeWidth;EdgeWidth;4;0;Create;True;0;0;False;0;False;0.554593;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-158.3162,418.5155;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;80.92744,422.4052;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;16;272.3278,423.5053;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-759.7462,-411.3309;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;818324896388d98438058d56f7e522f3;818324896388d98438058d56f7e522f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-370.559,-549.5275;Inherit;False;Constant;_EdgeIntensity;EdgeIntensity;4;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-381.8612,-755.3333;Inherit;False;Property;_Color0;Color 0;5;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;434.4934,416.8855;Inherit;False;EdgeFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-135.575,-251.6313;Inherit;False;28;EdgeFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-35.78078,-578.6008;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;9;-333.9362,19.78455;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;183.6102,-392.5804;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-125.3246,-92.8377;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;670.546,-322.6471;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;41;0
WireConnection;32;0;31;0
WireConnection;40;0;39;0
WireConnection;38;1;32;0
WireConnection;38;0;5;0
WireConnection;8;0;38;0
WireConnection;8;3;40;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;37;0;4;0
WireConnection;37;1;39;0
WireConnection;24;0;37;0
WireConnection;10;0;25;0
WireConnection;10;1;11;0
WireConnection;12;0;10;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;16;0;14;0
WireConnection;28;0;16;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;19;2;1;0
WireConnection;9;1;25;0
WireConnection;21;0;1;0
WireConnection;21;1;19;0
WireConnection;21;2;29;0
WireConnection;3;0;1;4
WireConnection;3;1;9;0
WireConnection;0;2;21;0
WireConnection;0;10;3;0
ASEEND*/
//CHKSM=31E3FEC17AAFE2C7D41369FCA2695CFDEBF11D61
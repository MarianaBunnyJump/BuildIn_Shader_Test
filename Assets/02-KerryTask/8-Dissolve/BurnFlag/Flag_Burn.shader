// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Flag_Burn"
{
	Properties
	{
		_Size("Size", Range( 0 , 10)) = 1
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_VAT_POS("VAT_POS", 2D) = "white" {}
		_VAT_NORMAL("VAT_NORMAL", 2D) = "white" {}
		_FrameCount("FrameCount", Float) = 0
		_Speed("Speed", Range( 0 , 3)) = 0.25
		_BoudingMin("BoudingMin", Float) = -2.653735
		_BoudingMax("BoudingMax", Float) = 1.072085
		_WindIntensity("WindIntensity", Range( 0 , 2)) = 1
		[Toggle(_MANNULCONTROL_ON)] _MANNULCONTROL("MANNULCONTROL", Float) = 1
		_TimeSpeed("TimeSpeed", Float) = 0.02
		_ObjectScale("ObjectScale", Float) = 15
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5559191
		_Spread("Spread", Range( 0 , 1)) = 0.7867885
		_PivotOffset("PivotOffset", Float) = 0
		_FlameOffset("FlameOffset", Range( 0 , 0.5)) = 0.3373984
		_FlameWidth("FlameWidth", Range( 0 , 2)) = 0.1779765
		[HDR]_FlameColor("FlameColor", Color) = (0,0,0,0)
		_FlameIntensity("FlameIntensity", Float) = 5
		_CharringWidth("CharringWidth", Range( 0 , 2)) = 0.1779765
		_CharringOffset("CharringOffset", Range( 0 , 0.5)) = 0.5
		_FlowMap("FlowMap", 2D) = "white" {}
		_Noise2("Noise2", 2D) = "white" {}
		_Flow2NoiseStrength("Flow2NoiseStrength", Vector) = (1,1,0,0)
		_Flow1("Flow1", Float) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MANNULCONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _VAT_POS;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoudingMax;
		uniform float _BoudingMin;
		uniform float _WindIntensity;
		uniform sampler2D _VAT_NORMAL;
		uniform sampler2D _Noise2;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		SamplerState sampler_FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float2 _Flow2NoiseStrength;
		uniform float _Flow1;
		uniform float _PivotOffset;
		uniform float _ObjectScale;
		uniform float _TimeSpeed;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _CharringOffset;
		uniform float _CharringWidth;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _FlameOffset;
		uniform float _FlameWidth;
		uniform float4 _FlameColor;
		uniform float _FlameIntensity;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame17 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult20 = (float2(v.texcoord1.xy.x , CurrentFrame17));
			float2 UV_VAT21 = appendResult20;
			float3 appendResult32 = (float3(-( ( (tex2Dlod( _VAT_POS, float4( UV_VAT21, 0, 0.0) )).rgb * ( _BoudingMax - _BoudingMin ) ) + _BoudingMin ).x , 0.0 , 0.0));
			float3 VAT_VertexOffset33 = appendResult32;
			v.vertex.xyz += ( VAT_VertexOffset33 * _WindIntensity );
			v.vertex.w = 1;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 break37 = ((tex2Dlod( _VAT_NORMAL, float4( UV_VAT21, 0, 0.0) )).rgb*-1.0 + 1.0);
			float3 appendResult40 = (float3(-break37.x , break37.z , break37.y));
			float3 VAT_VertexNormal36 = appendResult40;
			float clampResult48 = clamp( _WindIntensity , 0.0 , 1.0 );
			float3 lerpResult45 = lerp( ase_vertexNormal , VAT_VertexNormal36 , clampResult48);
			v.normal = lerpResult45;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_output_4_0_g1 = (( i.uv_texcoord / _Size )).xy;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float4 tex2DNode142 = tex2D( _FlowMap, uv_FlowMap );
			float2 appendResult145 = (float2(tex2DNode142.r , tex2DNode142.g));
			float2 temp_output_41_0_g1 = ( appendResult145 + 0.5 );
			float2 temp_output_17_0_g1 = _Flow2NoiseStrength;
			float mulTime22_g1 = _Time.y * _Flow1;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( temp_output_41_0_g1 * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _Noise2, temp_output_11_0_g1 ) , tex2D( _Noise2, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float4 Noise2140 = (lerpResult9_g1).rgba;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld51 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult61 = clamp( ( ( ( ase_worldPos.y - objToWorld51.y ) - _PivotOffset ) / _ObjectScale ) , 0.0 , 1.0 );
			float mulTime59 = _Time.y * _TimeSpeed;
			#ifdef _MANNULCONTROL_ON
				float staticSwitch65 = _ChangeAmount;
			#else
				float staticSwitch65 = frac( mulTime59 );
			#endif
			float Gradient73 = ( ( ( ( 1.0 - clampResult61 ) - (-_Spread + (staticSwitch65 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float4 temp_cast_0 = (Gradient73).xxxx;
			float4 GradientNoise85 = ( Noise2140 - temp_cast_0 );
			float4 temp_cast_1 = (_CharringOffset).xxxx;
			float clampResult119 = clamp( ( ( distance( GradientNoise85 , temp_cast_1 ) / _CharringWidth ) - 0.25 ) , 0.0 , 1.0 );
			float Charring127 = (clampResult119*2.0 + -1.0);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( Charring127 * tex2D( _MainTex, uv_MainTex ) ).rgb;
			float4 temp_cast_3 = (_FlameOffset).xxxx;
			float clampResult99 = clamp( ( 1.0 - ( distance( GradientNoise85 , temp_cast_3 ) / _FlameWidth ) ) , 0.0 , 1.0 );
			float4 temp_output_101_0 = ( clampResult99 * _FlameColor * 2.0 );
			float4 FlameColor106 = ( ( temp_output_101_0 * temp_output_101_0 ) * _FlameIntensity );
			o.Emission = FlameColor106.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			clip( step( float4( 0,0,0,0 ) , GradientNoise85 ).x - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1361;589;976;786;485.217;1945.548;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;5;-3425.956,-431.3821;Inherit;False;2200.86;1190.064;VAT;35;40;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;-3648.426,-1905.314;Inherit;False;2463.022;1237.973;Gradient;22;90;91;52;51;50;73;72;71;70;69;67;65;61;66;63;60;58;62;59;56;92;109;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;7;-3351.682,-381.3822;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;50;-3571.404,-1816.604;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;51;-3569.11,-1648.891;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;6;-3426.956,-243.8744;Inherit;False;Property;_Speed;Speed;10;0;Create;True;0;0;False;0;False;0.25;0.25;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-3171.855,-368.3742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-3321.162,-1657.315;Inherit;False;Property;_PivotOffset;PivotOffset;20;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-3570.308,-1395.276;Inherit;False;Property;_TimeSpeed;TimeSpeed;15;0;Create;True;0;0;False;0;False;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;52;-3327.331,-1766.736;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-3066.5,-205.9181;Inherit;False;Property;_FrameCount;FrameCount;9;0;Create;True;0;0;False;0;False;0;101;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-3136.353,-1648.592;Inherit;False;Property;_ObjectScale;ObjectScale;17;0;Create;True;0;0;False;0;False;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;90;-3141.556,-1765.466;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;10;-3023.121,-369.2647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-3275.985,-1416.356;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-3018.6,-1095.974;Inherit;False;Property;_Spread;Spread;19;0;Create;True;0;0;False;0;False;0.7867885;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;134;-3897.961,1529.186;Inherit;False;2111.714;944.6577;Noise;10;143;142;141;140;136;144;146;147;149;145;Noise;0.2082592,0.7757359,0.9811321,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2829.881,-376.4822;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-3258.375,-1251.332;Inherit;False;Property;_ChangeAmount;ChangeAmount;18;0;Create;True;0;0;False;0;False;0.5559191;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;63;-3057.933,-1421.442;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;-2933.642,-1759.333;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;61;-2738.179,-1743.639;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;65;-2824.348,-1366.788;Inherit;False;Property;_MANNULCONTROL;MANNULCONTROL;14;0;Create;True;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;12;-2673.881,-358.4822;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;136;-3688.19,2011.281;Inherit;False;0;142;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;66;-2706.754,-1208.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;142;-3391.42,2015.772;Inherit;True;Property;_FlowMap;FlowMap;27;0;Create;True;0;0;False;0;False;-1;75c11ff777c73f745a290b5eb6b2723f;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;67;-2494.972,-1389.448;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;92;-2419.924,-1646.52;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;13;-2554.981,-350.0549;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;145;-3050.904,2051.584;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;144;-3114.453,1817.362;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-2421.557,-215.0241;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-2863.322,2264.512;Inherit;False;Property;_Flow1;Flow1;30;0;Create;True;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;146;-3148.585,2222.792;Inherit;False;Property;_Flow2NoiseStrength;Flow2NoiseStrength;29;0;Create;True;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;143;-3113.097,1603.814;Inherit;True;Property;_Noise2;Noise2;28;0;Create;True;0;0;False;0;False;6e9e3841a0552a34cb7c38b3628da853;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-2143.669,-1543.064;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-2401.47,-352.0028;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1957.84,-1027.764;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2222.559,-296.0241;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;71;-1829.214,-1154.162;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;141;-2772.57,1682.156;Inherit;True;Flow;0;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;5;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2083.071,-296.9028;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;149;-2360.631,1667.971;Inherit;False;FLOAT4;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1605.243,-1149.652;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-3317.719,80.90736;Inherit;False;17;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-2140.584,1650.474;Inherit;True;Noise2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1419.264,-1143.746;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;86;-4350.561,1064.141;Inherit;False;731.825;325.5619;GradientNoise;4;84;83;82;85;GradientNoise;1,0.9202199,0.1839623,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-3329.719,-59.09257;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;83;-4300.993,1106.341;Inherit;False;140;Noise2;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;-4316.16,1213.85;Inherit;False;73;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2977.719,-38.41436;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-2804.719,-41.09265;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-4070.254,1135.703;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;93;-1081.924,-1152.892;Inherit;False;2044.417;583.8556;FlameColor;14;104;103;102;100;101;95;99;98;97;96;94;105;106;111;FlameColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-3333.03,305.3199;Inherit;False;21;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-3842.735,1182.668;Inherit;False;GradientNoise;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1055.395,-963.1001;Inherit;False;Property;_FlameOffset;FlameOffset;21;0;Create;True;0;0;False;0;False;0.3373984;0.26;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-3043.789,186.6814;Inherit;True;Property;_VAT_POS;VAT_POS;7;0;Create;True;0;0;False;0;False;-1;0680b1a9af24f4442b4e252b528cf1db;0680b1a9af24f4442b4e252b528cf1db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1033.29,-1089.693;Inherit;False;85;GradientNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1027.851,-1926;Inherit;False;2044.417;583.8556;Charring;10;126;125;119;117;116;115;127;129;130;133;Charring;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2717.937,395.7137;Inherit;False;Property;_BoudingMin;BoudingMin;11;0;Create;True;0;0;False;0;False;-2.653735;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2720.637,294.8633;Inherit;False;Property;_BoudingMax;BoudingMax;12;0;Create;True;0;0;False;0;False;1.072085;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;-2501.847,299.0429;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1001.777,-1724.921;Inherit;False;Property;_CharringOffset;CharringOffset;26;0;Create;True;0;0;False;0;False;0.5;0.5;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-781.931,-839.6514;Inherit;False;Property;_FlameWidth;FlameWidth;22;0;Create;True;0;0;False;0;False;0.1779765;0.04;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-3018.789,528.6816;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;8;0;Create;True;0;0;False;0;False;-1;908c9706f47c33a4aa4a2f048c2d4f90;908c9706f47c33a4aa4a2f048c2d4f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;126;-964.4117,-1850.957;Inherit;False;85;GradientNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DistanceOpNode;96;-716.0521,-1084.067;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;26;-2715.167,168.447;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;38;-2699.248,548.0132;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;115;-661.9795,-1857.175;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-764.5585,-1603.585;Inherit;False;Property;_CharringWidth;CharringWidth;25;0;Create;True;0;0;False;0;False;0.1779765;0.04;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-2356.846,170.0428;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;97;-475.4414,-1038.552;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-236.1963,-1034.662;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-459.5068,-1623.829;Inherit;False;Constant;_Float2;Float 2;25;0;Create;True;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;117;-458.0685,-1802.485;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-2263.086,345.2556;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;35;-2501.711,549.0369;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-29.72893,-702.7385;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;37;-2289.846,545.9661;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;30;-2120.1,323.7863;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;99;-44.79741,-1033.562;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;129;-309.5068,-1762.829;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;100;-258.4952,-822.1824;Inherit;False;Property;_FlameColor;FlameColor;23;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;117.2198,-927.6779;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;119;-125.7248,-1805.67;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;39;-2033.969,529.5901;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-1865.49,305.1577;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-1854.855,534.7076;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;133;81.12278,-1714.281;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;346.686,-763.5074;Inherit;False;Property;_FlameIntensity;FlameIntensity;24;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;298.8618,-908.5981;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-1706.49,306.1577;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1493.096,303.522;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-560.7372,472.2067;Inherit;False;Property;_WindIntensity;WindIntensity;13;0;Create;True;0;0;False;0;False;1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;524.686,-886.5073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1679.953,528.4491;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;348.089,-1723.043;Inherit;False;Charring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-609.5934,-177.8947;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;False;0;False;-1;de5969b59a7d5db48b198da3aa63c061;de5969b59a7d5db48b198da3aa63c061;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;132;-498.7847,-263.0233;Inherit;False;127;Charring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;48;-251.9375,506.3067;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;46;-499.4375,601.1068;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;42;-503.0994,350.4456;Inherit;False;33;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;81;-3379.982,867.5703;Inherit;False;1720.609;466.3535;Noise;5;80;79;77;110;76;Noise;0.2082592,0.7757359,0.9811321,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-519.3611,759.2761;Inherit;False;36;VAT_VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;711.686,-876.5073;Inherit;False;FlameColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1022.631,247.7231;Inherit;False;85;GradientNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-196.2803,11.86517;Inherit;False;106;FlameColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;45;-66.9375,597.3067;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-268.9375,393.3067;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2319.786,962.7368;Inherit;True;Noise1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-2492.946,965.9014;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-391.4903,152.3891;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;214.5833,557.8274;Inherit;False;140;Noise2;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-3329.982,917.5703;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;77;-3047.713,962.3959;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-396.3062,79.94122;Inherit;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;89;-786.3213,237.1967;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-202.7847,-221.0233;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;110;-3313.856,1065.336;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;16;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;393.4336,55.41319;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Flag_Burn;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;52;0;50;2
WireConnection;52;1;51;2
WireConnection;90;0;52;0
WireConnection;90;1;91;0
WireConnection;10;0;8;0
WireConnection;59;0;109;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;63;0;59;0
WireConnection;58;0;90;0
WireConnection;58;1;56;0
WireConnection;61;0;58;0
WireConnection;65;1;63;0
WireConnection;65;0;60;0
WireConnection;12;0;11;0
WireConnection;66;0;62;0
WireConnection;142;1;136;0
WireConnection;67;0;65;0
WireConnection;67;3;66;0
WireConnection;92;0;61;0
WireConnection;13;0;12;0
WireConnection;145;0;142;1
WireConnection;145;1;142;2
WireConnection;14;1;9;0
WireConnection;69;0;92;0
WireConnection;69;1;67;0
WireConnection;15;0;13;0
WireConnection;15;1;9;0
WireConnection;16;0;15;0
WireConnection;16;1;14;0
WireConnection;71;0;69;0
WireConnection;71;1;62;0
WireConnection;141;5;143;0
WireConnection;141;2;144;0
WireConnection;141;18;145;0
WireConnection;141;17;146;0
WireConnection;141;24;147;0
WireConnection;17;0;16;0
WireConnection;149;0;141;0
WireConnection;72;0;71;0
WireConnection;72;1;70;0
WireConnection;140;0;149;0
WireConnection;73;0;72;0
WireConnection;20;0;18;1
WireConnection;20;1;19;0
WireConnection;21;0;20;0
WireConnection;84;0;83;0
WireConnection;84;1;82;0
WireConnection;85;0;84;0
WireConnection;25;1;22;0
WireConnection;27;0;23;0
WireConnection;27;1;24;0
WireConnection;34;1;22;0
WireConnection;96;0;111;0
WireConnection;96;1;94;0
WireConnection;26;0;25;0
WireConnection;38;0;34;0
WireConnection;115;0;126;0
WireConnection;115;1;125;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;98;0;97;0
WireConnection;117;0;115;0
WireConnection;117;1;116;0
WireConnection;29;0;28;0
WireConnection;29;1;24;0
WireConnection;35;0;38;0
WireConnection;37;0;35;0
WireConnection;30;0;29;0
WireConnection;99;0;98;0
WireConnection;129;0;117;0
WireConnection;129;1;130;0
WireConnection;101;0;99;0
WireConnection;101;1;100;0
WireConnection;101;2;102;0
WireConnection;119;0;129;0
WireConnection;39;0;37;0
WireConnection;31;0;30;0
WireConnection;40;0;39;0
WireConnection;40;1;37;2
WireConnection;40;2;37;1
WireConnection;133;0;119;0
WireConnection;103;0;101;0
WireConnection;103;1;101;0
WireConnection;32;0;31;0
WireConnection;33;0;32;0
WireConnection;104;0;103;0
WireConnection;104;1;105;0
WireConnection;36;0;40;0
WireConnection;127;0;133;0
WireConnection;48;0;43;0
WireConnection;106;0;104;0
WireConnection;45;0;46;0
WireConnection;45;1;41;0
WireConnection;45;2;48;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;80;0;79;0
WireConnection;77;0;76;0
WireConnection;77;2;110;0
WireConnection;89;1;87;0
WireConnection;131;0;132;0
WireConnection;131;1;1;0
WireConnection;0;0;131;0
WireConnection;0;2;107;0
WireConnection;0;3;2;0
WireConnection;0;4;3;0
WireConnection;0;10;89;0
WireConnection;0;11;44;0
WireConnection;0;12;45;0
ASEEND*/
//CHKSM=FEE115502DF592B734C35237229209380A769951
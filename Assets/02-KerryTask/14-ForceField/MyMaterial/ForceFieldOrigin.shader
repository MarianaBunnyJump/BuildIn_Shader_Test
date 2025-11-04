// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceFieldOrigin"
{
	Properties
	{
		_Noise1("Noise", 2D) = "white" {}
		_HitSpread1("HitSpread", Float) = 4
		_HitNoiseIntensity1("HitNoiseIntensity", Float) = 0
		_RampTex1("RampTex", 2D) = "white" {}
		_HitFadeDistance1("HitFadeDistance", Float) = 0
		_HitFadePower1("HitFadePower", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float3 HitPosition;
		uniform float _HitFadeDistance1;
		uniform float _HitFadePower1;
		uniform sampler2D _RampTex1;
		SamplerState sampler_RampTex1;
		uniform float HitSize;
		uniform sampler2D _Noise1;
		SamplerState sampler_Noise1;
		uniform float _HitNoiseIntensity1;
		uniform float _HitSpread1;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float temp_output_6_0 = distance( HitPosition , ase_worldPos );
			float clampResult22 = clamp( ( ( 1.0 - ( temp_output_6_0 / _HitFadeDistance1 ) ) * _HitFadePower1 ) , 0.0 , 1.0 );
			float clampResult15 = clamp( ( ( ( temp_output_6_0 - HitSize ) + ( tex2D( _Noise1, i.uv_texcoord ).r * _HitNoiseIntensity1 ) ) / _HitSpread1 ) , 0.0 , 1.0 );
			float2 appendResult20 = (float2(-clampResult15 , 0.5));
			float3 temp_cast_0 = (( clampResult22 * tex2D( _RampTex1, appendResult20 ).r )).xxx;
			o.Emission = temp_cast_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1404;329;1264;990;2972.089;932.197;2.868036;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-1743.882,-203.5228;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;1;-1777.729,-402.4506;Inherit;False;Global;HitPosition;HitPosition;1;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1870.565,140.5179;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1553.18,335.0262;Inherit;False;Property;_HitNoiseIntensity1;HitNoiseIntensity;2;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1541.898,-126.8795;Inherit;False;Global;HitSize;HitSize;3;0;Create;True;0;0;False;0;False;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;6;-1555.749,-283.4576;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1638.62,131.9513;Inherit;True;Property;_Noise1;Noise;0;0;Create;True;0;0;False;0;False;-1;6e9e3841a0552a34cb7c38b3628da853;6e9e3841a0552a34cb7c38b3628da853;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1310.701,238.2514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-1176.13,-197.6295;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-978.5394,-74.71455;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1020.783,123.2944;Inherit;False;Property;_HitSpread1;HitSpread;1;0;Create;True;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1234.652,-292.2122;Inherit;False;Property;_HitFadeDistance1;HitFadeDistance;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-799.9183,37.31991;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-670.8434,42.66625;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-969.0684,-373.2679;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-812.9524,-233.9195;Inherit;False;Property;_HitFadePower1;HitFadePower;5;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-774.8615,-360.9736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;16;-523.2952,41.35058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-588.7284,-341.7471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-384.4126,46.09088;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;21;-246.8497,18.52725;Inherit;True;Property;_RampTex1;RampTex;3;0;Create;True;0;0;False;0;False;-1;256d86d8496a4e0f947100121f1fafb2;256d86d8496a4e0f947100121f1fafb2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;22;-406.8467,-274.9808;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;26.17392,-168.1507;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;289,-130;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ForceFieldOrigin;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;1;0
WireConnection;6;1;2;0
WireConnection;5;1;3;0
WireConnection;9;0;5;1
WireConnection;9;1;4;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;11;0;8;0
WireConnection;11;1;9;0
WireConnection;12;0;11;0
WireConnection;12;1;10;0
WireConnection;15;0;12;0
WireConnection;14;0;6;0
WireConnection;14;1;13;0
WireConnection;17;0;14;0
WireConnection;16;0;15;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;20;0;16;0
WireConnection;21;1;20;0
WireConnection;22;0;19;0
WireConnection;23;0;22;0
WireConnection;23;1;21;1
WireConnection;0;2;23;0
ASEEND*/
//CHKSM=F9B105F51BD04AAF3209D876D403B0604FAC114B
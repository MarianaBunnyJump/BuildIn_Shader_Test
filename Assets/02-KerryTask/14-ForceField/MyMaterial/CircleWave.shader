// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CircleWave"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_HitSpread("HitSpread", Float) = 4
		_HitPosition("HitPosition", Vector) = (0,0,0,0)
		_HitNoiseIntensity("HitNoiseIntensity", Float) = 0
		_RampTex("RampTex", 2D) = "white" {}
		_HitSize("HitSize", Float) = 6.066939
		_HitFadeDistance("HitFadeDistance", Float) = 6
		_HitFadePower("HitFadePower", Float) = 0
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

		uniform float3 _HitPosition;
		uniform float _HitFadeDistance;
		uniform float _HitFadePower;
		uniform sampler2D _RampTex;
		SamplerState sampler_RampTex;
		uniform float _HitSize;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float _HitNoiseIntensity;
		uniform float _HitSpread;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float temp_output_6_0 = distance( _HitPosition , ase_worldPos );
			float clampResult21 = clamp( ( ( 1.0 - ( temp_output_6_0 / _HitFadeDistance ) ) * _HitFadePower ) , 0.0 , 1.0 );
			float clampResult14 = clamp( ( ( ( temp_output_6_0 - _HitSize ) + ( tex2D( _Noise, i.uv_texcoord ).r * _HitNoiseIntensity ) ) / _HitSpread ) , -1.0 , 0.0 );
			float2 appendResult20 = (float2(-clampResult14 , 0.5));
			float3 temp_cast_0 = (( clampResult21 * tex2D( _RampTex, appendResult20 ).r )).xxx;
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
598;1203;1264;679;2006.093;533.6937;2.227927;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;1;-1667.619,-167.4648;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1737.111,396.8056;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;2;-1671.322,-344.2864;Inherit;False;Property;_HitPosition;HitPosition;2;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-1500.112,610.0082;Inherit;False;Property;_HitNoiseIntensity;HitNoiseIntensity;3;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;6;-1473.458,-257.4479;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-1505.166,388.239;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;6e9e3841a0552a34cb7c38b3628da853;6e9e3841a0552a34cb7c38b3628da853;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1421.655,-30.89877;Inherit;False;Property;_HitSize;HitSize;5;0;Create;True;0;0;False;0;False;6.066939;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1177.247,494.5392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-1212.665,-220.7021;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-840.2833,503.611;Inherit;False;Property;_HitSpread;HitSpread;1;0;Create;True;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-798.0397,305.6021;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1085.132,-291.9037;Inherit;False;Property;_HitFadeDistance;HitFadeDistance;6;0;Create;True;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-619.4186,417.6365;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;14;-488.3437,417.9828;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-868.2383,-412.2783;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-712.1223,-272.9298;Inherit;False;Property;_HitFadePower;HitFadePower;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;18;-342.7955,421.6672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-674.0314,-399.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-487.8984,-380.7575;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-203.9128,426.4075;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;21;-306.0166,-313.9911;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;-56.27972,381.5807;Inherit;True;Property;_RampTex;RampTex;4;0;Create;True;0;0;False;0;False;-1;256d86d8496a4e0f947100121f1fafb2;256d86d8496a4e0f947100121f1fafb2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;28;-74.23644,107.2641;Inherit;False;Property;_Color0;Color 0;8;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;25;-1940.283,46.53395;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;27;-1882.283,191.534;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;230.119,-102.6713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1704.283,76.53396;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;575.0068,-156.1132;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;CircleWave;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;0
WireConnection;6;1;1;0
WireConnection;7;1;3;0
WireConnection;8;0;7;1
WireConnection;8;1;4;0
WireConnection;9;0;6;0
WireConnection;9;1;5;0
WireConnection;11;0;9;0
WireConnection;11;1;8;0
WireConnection;13;0;11;0
WireConnection;13;1;10;0
WireConnection;14;0;13;0
WireConnection;15;0;6;0
WireConnection;15;1;12;0
WireConnection;18;0;14;0
WireConnection;17;0;15;0
WireConnection;19;0;17;0
WireConnection;19;1;16;0
WireConnection;20;0;18;0
WireConnection;21;0;19;0
WireConnection;22;1;20;0
WireConnection;23;0;21;0
WireConnection;23;1;22;1
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;0;2;23;0
ASEEND*/
//CHKSM=AC1FC0EDE0327E1CC69C01ECD721A919EF990997
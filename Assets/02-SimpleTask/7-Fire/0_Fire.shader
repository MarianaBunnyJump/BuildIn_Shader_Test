// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "0_Fire"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 1)) = 0.6878625
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color0;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _Softness;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Emission = _Color0.rgb;
			o.Alpha = 1;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner9 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float Noise24 = tex2D( _Noise, panner9 ).r;
			float clampResult22 = clamp( ( Noise24 - _Softness ) , 0.0 , 1.0 );
			float4 tex2DNode15 = tex2D( _Gradient, i.uv_texcoord );
			float Gradient23 = tex2DNode15.r;
			float smoothstepResult16 = smoothstep( clampResult22 , Noise24 , Gradient23);
			clip( smoothstepResult16 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
836;345;1003;593;1177.638;237.9358;1.909403;False;True
Node;AmplifyShaderEditor.CommentaryNode;28;-2370.783,-29.92085;Inherit;False;1030.885;623.0464;Comment;12;8;10;9;5;24;13;15;23;29;30;31;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;10;-2289.617,429.1256;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;2;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-2320.783,288.3406;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;9;-2087.462,368.9749;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1894.252,317.2897;Inherit;True;Property;_Noise;Noise;1;0;Create;True;0;0;False;0;False;-1;c75f2bae5d9fca94da9f4b2be19dfcf9;c75f2bae5d9fca94da9f4b2be19dfcf9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-2239.854,49.61121;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1563.898,345.0883;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1160.735,515.9097;Inherit;False;Property;_Softness;Softness;5;0;Create;True;0;0;False;0;False;0.6878625;0.6878625;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1092.392,384.4976;Inherit;False;24;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-2009.862,20.07915;Inherit;True;Property;_Gradient;Gradient;4;0;Create;True;0;0;False;0;False;-1;fdb7bb09d8edcf642b01b32a58ce044d;fdb7bb09d8edcf642b01b32a58ce044d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1633.007,40.48087;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-863.3387,501.4106;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;22;-699.2375,495.9181;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-780.356,228.0827;Inherit;True;23;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1970.062,228.0307;Inherit;False;Property;_GradientEndControl;GradientEndControl;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1712.062,139.0307;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-1572.789,156.1565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1561.089,224.0894;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-550.697,-173.2238;Inherit;False;Property;_Color0;Color 0;3;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;16;-454.1897,351.3943;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-159.6501,-17.6375;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;0_Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;8;0
WireConnection;9;2;10;0
WireConnection;5;1;9;0
WireConnection;24;0;5;1
WireConnection;15;1;13;0
WireConnection;23;0;15;1
WireConnection;17;0;25;0
WireConnection;17;1;19;0
WireConnection;22;0;17;0
WireConnection;29;0;15;1
WireConnection;29;1;30;0
WireConnection;31;0;29;0
WireConnection;16;0;27;0
WireConnection;16;1;22;0
WireConnection;16;2;25;0
WireConnection;0;2;11;0
WireConnection;0;10;16;0
ASEEND*/
//CHKSM=8D71C488171141099ABD58B976D442C92D800BE3
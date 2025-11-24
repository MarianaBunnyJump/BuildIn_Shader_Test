// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sky"
{
	Properties
	{
		_SkyHDR("SkyHDR", 2D) = "white" {}
		_FogColor1("FogColor", Color) = (0,0,0,0)
		_FogHeightStart1("Fog Height Start", Range( -1 , 1)) = 0
		_FogHeightEnd1("Fog Height End", Range( -1 , 1)) = 0.2
		_SunFogRange1("Sun Fog Range", Float) = 10
		_SunFogintensity1("Sun Fog intensity", Float) = 1
		_SunFogColor1("SunFogColor", Color) = (0.9716981,0.7376654,0.1695888,0)
		_FogIntensity1("Fog Intensity", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldPos;
		};

		uniform sampler2D _SkyHDR;
		uniform float4 _SkyHDR_ST;
		uniform float4 _FogColor1;
		uniform float4 _SunFogColor1;
		uniform float _SunFogRange1;
		uniform float _SunFogintensity1;
		uniform float _FogHeightEnd1;
		uniform float _FogHeightStart1;
		uniform float _FogIntensity1;


		float3 ACESToneMap45( float3 LinearColor )
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return
			saturate((LinearColor*(a*LinearColor+b))/ (LinearColor*(c*LinearColor+d)+e));
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_SkyHDR = i.uv_texcoord * _SkyHDR_ST.xy + _SkyHDR_ST.zw;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult14 = dot( -i.viewDir , ase_worldlightDir );
			float clampResult28 = clamp( pow( (dotResult14*0.5 + 0.5) , _SunFogRange1 ) , 0.0 , 1.0 );
			float SunFog33 = ( clampResult28 * _SunFogintensity1 );
			float4 lerpResult40 = lerp( _FogColor1 , _SunFogColor1 , SunFog33);
			float temp_output_10_0_g6 = _FogHeightEnd1;
			float3 objToWorld50 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 normalizeResult51 = normalize( ( ase_worldPos - objToWorld50 ) );
			float clampResult8_g6 = clamp( ( ( temp_output_10_0_g6 - (normalizeResult51).y ) / ( temp_output_10_0_g6 - _FogHeightStart1 ) ) , 0.0 , 1.0 );
			float FogHeight27 = ( 1.0 - ( 1.0 - clampResult8_g6 ) );
			float clampResult41 = clamp( ( FogHeight27 * _FogIntensity1 ) , 0.0 , 1.0 );
			float4 lerpResult43 = lerp( tex2D( _SkyHDR, uv_SkyHDR ) , lerpResult40 , clampResult41);
			float3 LinearColor45 = ( lerpResult43 * lerpResult43 ).rgb;
			float3 localACESToneMap45 = ACESToneMap45( LinearColor45 );
			o.Emission = sqrt( localACESToneMap45 );
			o.Alpha = 1;
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
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
1261;377;1168;774;4765.199;679.6973;3.501799;True;False
Node;AmplifyShaderEditor.CommentaryNode;4;-3048.482,467.3976;Inherit;False;1714.466;547.4655;SunFog;11;33;32;29;28;24;19;18;14;7;6;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-3223.276,-206.4292;Inherit;False;1751.543;622.7372;FogDistance_高度雾;10;52;51;49;50;48;27;23;20;12;15;FogDistance;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-2998.482,517.3975;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;50;-3182.314,78.31059;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;48;-3175.865,-77.41395;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;7;-2779.526,551.0724;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;6;-2898.08,703.1205;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-2950.865,-18.41393;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;14;-2587.016,586.8624;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;51;-2785.865,-14.41393;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;52;-2606.619,-16.63368;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2636.204,98.60017;Inherit;False;Property;_FogHeightStart1;Fog Height Start;2;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2407.016,752.8624;Inherit;False;Property;_SunFogRange1;Sun Fog Range;4;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2639.97,199.0007;Inherit;False;Property;_FogHeightEnd1;Fog Height End;3;0;Create;True;0;0;False;0;False;0.2;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;19;-2401.016,585.8624;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-2179.016,669.8624;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;20;-2390.328,2.68696;Inherit;False;FogLinear;7;;6;681391ee5319e434fa26eb030e6faeec;0;3;12;FLOAT;500;False;11;FLOAT;0;False;10;FLOAT;700;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2052.016,870.8624;Inherit;False;Property;_SunFogintensity1;Sun Fog intensity;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-2102.642,16.43936;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;28;-1992.015,695.8624;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1425.55,-245.5204;Inherit;False;896.4102;916.8116;FogCombine;9;43;41;40;39;38;37;36;35;31;FogCombine;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1777.015,762.8624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1915.078,7.969378;Inherit;False;FogHeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1404.478,496.3475;Inherit;False;Property;_FogIntensity1;Fog Intensity;10;0;Create;True;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1401.608,372.6706;Inherit;False;27;FogHeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-1603.526,756.5504;Inherit;False;SunFog;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1306.128,-585.6051;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1079.579,360.5467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1373.646,-195.5204;Inherit;False;Property;_FogColor1;FogColor;1;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;-1375.55,-6.627377;Inherit;False;Property;_SunFogColor1;SunFogColor;6;0;Create;True;0;0;False;0;False;0.9716981,0.7376654,0.1695888,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1350.565,175.8127;Inherit;False;33;SunFog;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;-1035.842,80.82036;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;41;-954.356,333.2462;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1039.479,-538.2047;Inherit;True;Property;_SkyHDR;SkyHDR;0;0;Create;True;0;0;False;0;False;-1;None;682bb53eb6c209e4ca3e869930244740;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;43;-720.5649,134.5369;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-483.3814,60.42149;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;45;-324.271,44.0001;Inherit;False;float a = 2.51f@$float b = 0.03f@$float c = 2.43f@$float d = 0.59f@$float e = 0.14f@$return$saturate((LinearColor*(a*LinearColor+b))/ (LinearColor*(c*LinearColor+d)+e))@;3;False;1;True;LinearColor;FLOAT3;0,0,0;In;;Inherit;False;ACESToneMap;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;46;-89.02718,22.18479;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;47;106.3162,-26.31725;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Sky;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;5;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;14;0;7;0
WireConnection;14;1;6;0
WireConnection;51;0;49;0
WireConnection;52;0;51;0
WireConnection;19;0;14;0
WireConnection;24;0;19;0
WireConnection;24;1;18;0
WireConnection;20;12;52;0
WireConnection;20;11;15;0
WireConnection;20;10;12;0
WireConnection;23;0;20;0
WireConnection;28;0;24;0
WireConnection;32;0;28;0
WireConnection;32;1;29;0
WireConnection;27;0;23;0
WireConnection;33;0;32;0
WireConnection;38;0;31;0
WireConnection;38;1;35;0
WireConnection;40;0;39;0
WireConnection;40;1;37;0
WireConnection;40;2;36;0
WireConnection;41;0;38;0
WireConnection;1;1;2;0
WireConnection;43;0;1;0
WireConnection;43;1;40;0
WireConnection;43;2;41;0
WireConnection;44;0;43;0
WireConnection;44;1;43;0
WireConnection;45;0;44;0
WireConnection;46;0;45;0
WireConnection;47;2;46;0
ASEEND*/
//CHKSM=43577B8280675800C09B6CF113FA265BECEB384B
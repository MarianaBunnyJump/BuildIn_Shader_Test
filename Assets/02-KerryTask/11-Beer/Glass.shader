// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Glass"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_RefractMatcap("RefractMatcap", 2D) = "white" {}
		[HDR]_RefractColor("RefractColor", Color) = (0,0,0,0)
		_RefractIntensity("RefractIntensity", Float) = 0.3
		_Decal("Decal", 2D) = "black" {}
		_Min("Min", Float) = 0
		_Max("Max", Float) = 1
		_ObjectPivotOffset("ObjectPivotOffset", Float) = 0
		_ObjectHeight("ObjectHeight", Float) = 0.36
		_ThickMap("ThickMap", 2D) = "white" {}
		_DirtyMask("DirtyMask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _Matcap;
		uniform float4 _RefractColor;
		uniform sampler2D _RefractMatcap;
		uniform float _Min;
		uniform float _Max;
		uniform sampler2D _ThickMap;
		SamplerState sampler_ThickMap;
		uniform float _ObjectPivotOffset;
		uniform float _ObjectHeight;
		uniform sampler2D _DirtyMask;
		SamplerState sampler_DirtyMask;
		uniform float4 _DirtyMask_ST;
		uniform float _RefractIntensity;
		uniform sampler2D _Decal;
		uniform float4 _Decal_ST;
		SamplerState sampler_Decal;
		SamplerState sampler_Matcap;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult29 = normalize( mul( UNITY_MATRIX_V, float4( reflect( -i.viewDir , ase_worldNormal ) , 0.0 ) ).xyz );
			float temp_output_31_0 = (normalizeResult29).x;
			float temp_output_32_0 = (normalizeResult29).y;
			float temp_output_38_0 = ( (normalizeResult29).z + 1.0 );
			float2 MatcapImproved347 = ( ( (normalizeResult29).xy / ( sqrt( ( ( temp_output_31_0 * temp_output_31_0 ) + ( temp_output_32_0 * temp_output_32_0 ) + ( temp_output_38_0 * temp_output_38_0 ) ) ) * 2.0 ) ) + 0.5 );
			float4 tex2DNode1 = tex2D( _Matcap, MatcapImproved347 );
			float dotResult56 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult57 = smoothstep( _Min , _Max , dotResult56);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld82 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult90 = (float2(0.5 , ( ( ( ase_worldPos.y - objToWorld82.y ) - _ObjectPivotOffset ) / _ObjectHeight )));
			float2 uv_DirtyMask = i.uv_texcoord * _DirtyMask_ST.xy + _DirtyMask_ST.zw;
			float clampResult94 = clamp( ( ( 1.0 - smoothstepResult57 ) + tex2D( _ThickMap, appendResult90 ).r + tex2D( _DirtyMask, uv_DirtyMask ).a ) , 0.0 , 1.0 );
			float Thickness64 = clampResult94;
			float temp_output_60_0 = ( Thickness64 * _RefractIntensity );
			float4 lerpResult69 = lerp( ( 0.5 * _RefractColor ) , ( _RefractColor * tex2D( _RefractMatcap, ( MatcapImproved347 + temp_output_60_0 ) ) ) , temp_output_60_0);
			float2 uv_Decal = i.uv_texcoord * _Decal_ST.xy + _Decal_ST.zw;
			float4 tex2DNode76 = tex2D( _Decal, uv_Decal );
			float4 lerpResult77 = lerp( ( tex2DNode1 + lerpResult69 ) , tex2DNode76 , tex2DNode76.a);
			o.Emission = lerpResult77.rgb;
			float clampResult70 = clamp( ( tex2DNode76.a + max( tex2DNode1.r , Thickness64 ) ) , 0.0 , 1.0 );
			o.Alpha = clampResult70;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
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
				surfIN.worldNormal = IN.worldNormal;
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
775;835;1168;938;3468.675;1114.114;1.753051;True;False
Node;AmplifyShaderEditor.CommentaryNode;48;-3452.217,1062.115;Inherit;False;2330.287;601.4426;Matcap_Improved3;24;26;27;28;23;25;24;31;34;29;32;35;30;40;33;38;36;39;41;42;43;44;45;46;47;Matcap_Improved3;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;23;-3402.217,1163.262;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;24;-3362.86,1336.423;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;25;-3224.59,1173.267;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;26;-3046.919,1257.347;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;27;-2982.393,1138.394;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2931.076,-1295.014;Inherit;False;1971.71;1124.538;Thickness;20;94;93;92;91;90;64;89;88;84;86;83;82;81;80;79;58;57;56;55;54;Thickness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-2851.144,1190.895;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;29;-2705.889,1177.408;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;81;-2779.629,-723.9052;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;82;-2810.797,-559.6474;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-2553.147,-631.4722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2553.92,-473.6892;Inherit;False;Property;_ObjectPivotOffset;ObjectPivotOffset;8;0;Create;True;0;0;False;0;False;0;-0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;33;-2537.704,1461.518;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2547.225,1547.558;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;32;-2391.78,1355.583;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-2344.32,-587.6891;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-2390.761,1462.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2347.2,-456.4121;Inherit;False;Property;_ObjectHeight;ObjectHeight;9;0;Create;True;0;0;False;0;False;0.36;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;54;-2880.756,-1245.014;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;31;-2422.361,1234.97;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;55;-2881.076,-1084.862;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;56;-2667.077,-1136.862;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2236.53,1347.025;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2721.373,-915.6776;Inherit;False;Property;_Max;Max;7;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2263.385,1210.028;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-2156.327,-569.2606;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2729.374,-1006.877;Inherit;False;Property;_Min;Min;6;0;Create;True;0;0;False;0;False;0;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2234.299,1475.894;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-2046.839,1295.728;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;90;-2036.664,-594.7944;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;57;-2548.413,-1109.166;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-2387.812,-1129.964;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1923.294,1415.173;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;92;-1907.338,-422.2434;Inherit;True;Property;_DirtyMask;DirtyMask;11;0;Create;True;0;0;False;0;False;-1;None;a7655f7426028534c814a55f678cf00e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SqrtOpNode;42;-1915.51,1299.375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-1909.54,-629.5647;Inherit;True;Property;_ThickMap;ThickMap;10;0;Create;True;0;0;False;0;False;-1;None;ddcb58aad1f4a1d4dae9ee40927d74f8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1775.067,1295.908;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;30;-2413.002,1112.115;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1492.29,-1132.283;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;94;-1360.813,-1130.661;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-1646.813,1124.254;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1636.939,1380.159;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1192.924,-1129.905;Inherit;False;Thickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1492.151,1233.814;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1085.569,244.1373;Inherit;False;64;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-1085.657,339.0105;Inherit;False;Property;_RefractIntensity;RefractIntensity;4;0;Create;True;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1362.932,1235.37;Inherit;False;MatcapImproved3;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1048.141,135.2077;Inherit;False;47;MatcapImproved3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-884.8412,275.5978;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-743.3655,189.0813;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;63;-420.0215,-87.23273;Inherit;False;Property;_RefractColor;RefractColor;3;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0.1981132,0.1981132,0.1981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;-364.5508,-171.2478;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-592.5471,103.4535;Inherit;True;Property;_RefractMatcap;RefractMatcap;2;0;Create;True;0;0;False;0;False;-1;None;71dc0b9800da5da4db0ba7884e540e77;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;50;-441.8604,-405.861;Inherit;False;47;MatcapImproved3;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;424.0058,90.6561;Inherit;False;64;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-177.556,-441.8487;Inherit;True;Property;_Matcap;Matcap;1;0;Create;True;0;0;False;0;False;-1;None;7b6c994ca124f7844933ff29a828e014;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-139.9215,-83.70392;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-24.79852,114.1057;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;69;230.7248,166.4084;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;62;645.4615,63.1573;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;569.4291,-310.928;Inherit;True;Property;_Decal;Decal;5;0;Create;True;0;0;False;0;False;-1;None;7f3ae9a67ef08774184012ef461a487b;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;78;876.6203,-111.9917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;8;-3474.707,-45.71981;Inherit;False;970.1967;347.546;matcap_uv;6;2;3;4;5;6;7;matcap_uv;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;434.0492,-377.458;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3454.35,425.2402;Inherit;False;1876.738;532.1044;matcap_uv_Update2;12;22;15;14;13;20;19;18;17;10;12;11;16;matcap_uv_Update2;1,1,1,1;0;0
Node;AmplifyShaderEditor.SwizzleNode;5;-3097.461,52.4511;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;70;1014.986,9.898829;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1819.206,565.5764;Inherit;False;matcap_uv_Update2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-3404.351,475.24;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;11;-3171.938,745.1191;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;17;-2583.488,572.4197;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TransformPositionNode;14;-3220.351,478.24;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;15;-2986.491,510.4108;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;77;939.7723,-415.9395;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2943.938,681.1194;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;4;-3400.012,4.280105;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;20;-2008.933,571.2685;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;19;-2334.934,669.2687;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;16;-2743.555,565.2154;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-2175.564,570.3596;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-3424.707,118.8261;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;10;-3131.118,642.6202;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-2728.511,53.28583;Inherit;False;matcap_uv;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-2945.923,63.4002;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-3239.479,55.61322;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1260.027,-351.9665;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;25;0;23;0
WireConnection;26;0;25;0
WireConnection;26;1;24;0
WireConnection;28;0;27;0
WireConnection;28;1;26;0
WireConnection;29;0;28;0
WireConnection;83;0;81;2
WireConnection;83;1;82;2
WireConnection;33;0;29;0
WireConnection;32;0;29;0
WireConnection;84;0;83;0
WireConnection;84;1;86;0
WireConnection;38;0;33;0
WireConnection;38;1;39;0
WireConnection;31;0;29;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;35;0;32;0
WireConnection;35;1;32;0
WireConnection;34;0;31;0
WireConnection;34;1;31;0
WireConnection;88;0;84;0
WireConnection;88;1;89;0
WireConnection;36;0;38;0
WireConnection;36;1;38;0
WireConnection;41;0;34;0
WireConnection;41;1;35;0
WireConnection;41;2;36;0
WireConnection;90;1;88;0
WireConnection;57;0;56;0
WireConnection;57;1;79;0
WireConnection;57;2;80;0
WireConnection;58;0;57;0
WireConnection;42;0;41;0
WireConnection;91;1;90;0
WireConnection;43;0;42;0
WireConnection;43;1;44;0
WireConnection;30;0;29;0
WireConnection;93;0;58;0
WireConnection;93;1;91;1
WireConnection;93;2;92;4
WireConnection;94;0;93;0
WireConnection;40;0;30;0
WireConnection;40;1;43;0
WireConnection;64;0;94;0
WireConnection;45;0;40;0
WireConnection;45;1;46;0
WireConnection;47;0;45;0
WireConnection;60;0;65;0
WireConnection;60;1;59;0
WireConnection;53;0;52;0
WireConnection;53;1;60;0
WireConnection;51;1;53;0
WireConnection;1;1;50;0
WireConnection;75;0;74;0
WireConnection;75;1;63;0
WireConnection;73;0;63;0
WireConnection;73;1;51;0
WireConnection;69;0;75;0
WireConnection;69;1;73;0
WireConnection;69;2;60;0
WireConnection;62;0;1;1
WireConnection;62;1;72;0
WireConnection;78;0;76;4
WireConnection;78;1;62;0
WireConnection;61;0;1;0
WireConnection;61;1;69;0
WireConnection;5;0;3;0
WireConnection;70;0;78;0
WireConnection;22;0;20;0
WireConnection;17;0;16;0
WireConnection;14;0;13;0
WireConnection;15;0;14;0
WireConnection;77;0;61;0
WireConnection;77;1;76;0
WireConnection;77;2;76;4
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;20;0;18;0
WireConnection;19;0;17;1
WireConnection;16;0;15;0
WireConnection;16;1;12;0
WireConnection;18;0;19;0
WireConnection;18;1;17;0
WireConnection;7;0;6;0
WireConnection;6;0;5;0
WireConnection;3;0;4;0
WireConnection;3;1;2;0
WireConnection;0;2;77;0
WireConnection;0;9;70;0
ASEEND*/
//CHKSM=1E2B0A4A1B3300A05F5C44E7BB1743CC84D46705
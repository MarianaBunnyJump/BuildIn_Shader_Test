// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Slime"
{
	Properties
	{
		_MatCap("MatCap", 2D) = "white" {}
		_BaseMap("BaseMap", 2D) = "white" {}
		_EmissMap("EmissMap", 2D) = "white" {}
		_RimColor("RimColor", Color) = (1,1,1,0)
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 2
		_NormalMap("NormalMap", 2D) = "bump" {}
		_SlimeNormalTex("SlimeNormalTex", 2D) = "bump" {}
		_ConTrast("ConTrast", Float) = 5
		_SmileTilling("SmileTilling", Vector) = (2,2,2,0)
		_NoiseSpeed1("NoiseSpeed", Vector) = (0.15,0.16,0,0)
		_VertexAnimations("VertexAnimations", 2D) = "white" {}
		_VertexNoiseTilling("VertexNoiseTilling", Vector) = (2,2,2,0)
		_VertexNoiseSpeed("VertexNoiseSpeed", Vector) = (0,0,0,0)
		_VertexAnimIntensity("VertexAnimIntensity", Float) = 0.01
		_Float0("Float 0", Float) = 0.03
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		ColorMask 0
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _VertexAnimations;
		uniform float3 _VertexNoiseTilling;
		uniform float3 _VertexNoiseSpeed;
		uniform float _Float0;
		uniform float _VertexAnimIntensity;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform sampler2D _MatCap;
		uniform sampler2D _SlimeNormalTex;
		uniform float _ConTrast;
		uniform float3 _SmileTilling;
		uniform float3 _NoiseSpeed1;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform sampler2D _EmissMap;
		uniform float4 _EmissMap_ST;


		inline float4 TriplanarSampling122( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float3 TriplanarSampling105( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackNormal( xNorm ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackNormal( yNorm ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackNormal( zNorm ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 objToWorld123 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 triplanar122 = TriplanarSampling122( _VertexAnimations, ( ( ( ase_worldPos - objToWorld123 ) * _VertexNoiseTilling ) + ( _Time.y * _VertexNoiseSpeed ) ), ase_worldNormal, 0.0, float2( 1,1 ), 1.0, 0 );
			float4 VertexNoise134 = triplanar122;
			float3 _VertexBias = float3(0,-0.2,0);
			float dotResult149 = dot( ase_worldNormal , _VertexBias );
			float clampResult150 = clamp( dotResult149 , 0.0 , 1.0 );
			float3 worldToObj154 = mul( unity_WorldToObject, float4( ( ( ( VertexNoise134 * float4( ( ase_worldNormal + _VertexBias ) , 0.0 ) * ( clampResult150 + 1.0 ) * v.color.r ) * _Float0 * _VertexAnimIntensity ) + float4( ase_worldPos , 0.0 ) ).xyz, 1 ) ).xyz;
			float3 FinalVertexPosition141 = worldToObj154;
			v.vertex.xyz = FinalVertexPosition141;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 objToWorld109 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 triplanar105 = TriplanarSampling105( _SlimeNormalTex, ( ( ( ase_worldPos - objToWorld109 ) * _SmileTilling ) + ( _Time.y * _NoiseSpeed1 ) ), ase_worldNormal, _ConTrast, float2( 1,1 ), 1.0, 0 );
			float3 TriNormalEasy118 = triplanar105;
			float4 MatcapColor22 = tex2D( _MatCap, ((mul( UNITY_MATRIX_V, float4( TriNormalEasy118 , 0.0 ) ).xyz).xy*0.5 + 0.5) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV11 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) ), ase_worldViewDir );
			float fresnelNode11 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV11 , 0.0001 ), _RimPower ) );
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float4 RimColor24 = ( ( fresnelNode11 * _RimColor ) * tex2D( _EmissMap, uv_EmissMap ) );
			o.Emission = ( ( tex2D( _BaseMap, uv_BaseMap ) * MatcapColor22 ) + RimColor24 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
1411;584;1134;781;4916.461;19.88097;6.397977;True;False
Node;AmplifyShaderEditor.CommentaryNode;119;-4051.606,-401.2055;Inherit;False;1589.401;806.58;TriPannelEasy;13;118;105;107;117;112;111;116;114;115;110;113;108;109;TriPannelEasy;0.9150943,0.8353243,0.0561143,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;108;-3956.236,-300.0582;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;109;-3960.158,-141.1335;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;135;-2338.34,1253.165;Inherit;False;1622.861;748.3793;VertexNoise;12;121;123;124;125;126;129;130;131;128;127;122;134;VertexNoise;0.1760413,0.8094933,0.8679245,1;0;0
Node;AmplifyShaderEditor.Vector3Node;111;-3742.188,-117.881;Inherit;False;Property;_SmileTilling;SmileTilling;10;0;Create;True;0;0;False;0;False;2,2,2;2,2,2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;113;-3739.772,82.38854;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;-3733.478,-230.2295;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;112;-3727.923,178.0515;Inherit;False;Property;_NoiseSpeed1;NoiseSpeed;11;0;Create;True;0;0;False;0;False;0.15,0.16,0;0.26,0.5,0.2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;124;-2284.417,1335.434;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;123;-2288.34,1494.359;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-3507.351,-151.0727;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-3514.922,119.4516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-3305.094,-53.61624;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;-2061.66,1405.263;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;107;-3345.626,-336.3735;Inherit;True;Property;_SlimeNormalTex;SlimeNormalTex;8;0;Create;True;0;0;False;0;False;f6663cc8ff405154382dd25badec27ab;f6663cc8ff405154382dd25badec27ab;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector3Node;128;-2055.273,1525.999;Inherit;False;Property;_VertexNoiseTilling;VertexNoiseTilling;13;0;Create;True;0;0;False;0;False;2,2,2;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;117;-3317.276,72.27773;Inherit;False;Property;_ConTrast;ConTrast;9;0;Create;True;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;125;-2067.955,1717.881;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;127;-2056.104,1813.544;Inherit;False;Property;_VertexNoiseSpeed;VertexNoiseSpeed;14;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1843.105,1754.944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;105;-3086.188,-146.8058;Inherit;True;Spherical;World;True;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;World;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-1835.534,1484.42;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;146;-2314.611,2115.272;Inherit;False;2077.581;807.1682;VertexAnimation;16;153;141;154;152;139;138;140;143;137;145;148;151;150;149;136;147;VertexAnimation;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-1633.277,1581.876;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;136;-2252.424,2270.115;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;147;-2237.171,2440.965;Inherit;False;Constant;_VertexBias;VertexBias;16;0;Create;True;0;0;False;0;False;0,-0.2,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2700.984,-152.6208;Inherit;False;TriNormalEasy;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2354.811,-109.3365;Inherit;False;1434.836;359.3494;MatcapColor;7;1;6;5;3;22;50;4;MatcapColor;0.7169812,0.1927732,0.7064015,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;121;-1676.68,1303.165;Inherit;True;Property;_VertexAnimations;VertexAnimations;12;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DotProductOpNode;149;-1976.278,2423.878;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;122;-1351.506,1426.968;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewMatrixNode;4;-2265.568,-59.20922;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2318.843,56.71868;Inherit;False;118;TriNormalEasy;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;23;-2341.928,436.4126;Inherit;False;1981.195;695.2677;RimColor;12;24;20;19;10;17;11;18;15;14;12;16;13;RimColorr;0.9811321,0.3563546,0.3563546,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;150;-1841.666,2431.584;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2081.296,-17.65382;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-939.4791,1423.282;Inherit;False;VertexNoise;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;20;-2291.928,486.4125;Inherit;True;Property;_NormalMap;NormalMap;7;0;Create;True;0;0;False;0;False;-1;None;f6663cc8ff405154382dd25badec27ab;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-1826.216,899.1506;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-2030.943,2185.961;Inherit;False;134;VertexNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;5;-1948.302,-21.42884;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-1691.024,2438.005;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;145;-1789.108,2581.833;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-1852.443,657.4305;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;14;-1828.216,825.1506;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-1982.159,2272.038;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-1881.611,495.7873;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;16;-1826.216,976.1506;Inherit;False;Property;_RimPower;RimPower;6;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1447.681,2482.511;Inherit;False;Property;_Float0;Float 0;16;0;Create;True;0;0;False;0;False;0.03;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1479.325,2581.521;Inherit;False;Property;_VertexAnimIntensity;VertexAnimIntensity;15;0;Create;True;0;0;False;0;False;0.01;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-1785.255,-3.559529;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1418.896,2319.066;Inherit;False;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;18;-1547.84,779.5295;Inherit;False;Property;_RimColor;RimColor;3;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;11;-1550.251,592.8168;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1554.547,-26.38062;Inherit;True;Property;_MatCap;MatCap;0;0;Create;True;0;0;False;0;False;-1;ee03792452cf4004a9db0ec7b1815c55;ee03792452cf4004a9db0ec7b1815c55;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1159.938,2377.969;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;10;-1325.699,849.8646;Inherit;True;Property;_EmissMap;EmissMap;2;0;Create;True;0;0;False;0;False;-1;5f350709ef735db468df16b8c7013f69;5f350709ef735db468df16b8c7013f69;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;153;-1155.873,2549.995;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1286.6,671.8475;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1220.461,-23.7437;Inherit;False;MatcapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-984.2297,679.7006;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-892.4786,2425.783;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-126.8026,982.1077;Inherit;False;22;MatcapColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-839.8748,678.4886;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-188.5026,765.1489;Inherit;True;Property;_BaseMap;BaseMap;1;0;Create;True;0;0;False;0;False;-1;fcf411f69f936a843a49f1a9cdfdde3c;fcf411f69f936a843a49f1a9cdfdde3c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;154;-746.2795,2373.307;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;26;77.9906,1057.147;Inherit;False;24;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-515.5245,2384.354;Inherit;False;FinalVertexPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;176.2388,881.4208;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;141.0392,1181.029;Inherit;False;141;FinalVertexPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;381.1637,897.553;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;566.9867,897.0178;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;False;False;False;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;110;0;108;0
WireConnection;110;1;109;0
WireConnection;115;0;110;0
WireConnection;115;1;111;0
WireConnection;114;0;113;0
WireConnection;114;1;112;0
WireConnection;116;0;115;0
WireConnection;116;1;114;0
WireConnection;126;0;124;0
WireConnection;126;1;123;0
WireConnection;130;0;125;0
WireConnection;130;1;127;0
WireConnection;105;0;107;0
WireConnection;105;9;116;0
WireConnection;105;4;117;0
WireConnection;129;0;126;0
WireConnection;129;1;128;0
WireConnection;131;0;129;0
WireConnection;131;1;130;0
WireConnection;118;0;105;0
WireConnection;149;0;136;0
WireConnection;149;1;147;0
WireConnection;122;0;121;0
WireConnection;122;9;131;0
WireConnection;150;0;149;0
WireConnection;3;0;4;0
WireConnection;3;1;50;0
WireConnection;134;0;122;0
WireConnection;5;0;3;0
WireConnection;151;0;150;0
WireConnection;148;0;136;0
WireConnection;148;1;147;0
WireConnection;12;0;20;0
WireConnection;6;0;5;0
WireConnection;138;0;137;0
WireConnection;138;1;148;0
WireConnection;138;2;151;0
WireConnection;138;3;145;1
WireConnection;11;0;12;0
WireConnection;11;4;13;0
WireConnection;11;1;14;0
WireConnection;11;2;15;0
WireConnection;11;3;16;0
WireConnection;1;1;6;0
WireConnection;139;0;138;0
WireConnection;139;1;143;0
WireConnection;139;2;140;0
WireConnection;17;0;11;0
WireConnection;17;1;18;0
WireConnection;22;0;1;0
WireConnection;19;0;17;0
WireConnection;19;1;10;0
WireConnection;152;0;139;0
WireConnection;152;1;153;0
WireConnection;24;0;19;0
WireConnection;154;0;152;0
WireConnection;141;0;154;0
WireConnection;8;0;7;0
WireConnection;8;1;25;0
WireConnection;9;0;8;0
WireConnection;9;1;26;0
WireConnection;0;2;9;0
WireConnection;0;11;142;0
ASEEND*/
//CHKSM=605C73B5DD651CBDCAE3E7F80EF81ECBE2003D74
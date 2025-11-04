// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Disslove_Easy2"
{
    Properties
    {
        _Cutoff( "Mask Clip Value", Float ) = 0.5
        _MainTex1("MainTex", 2D) = "white" {}
        _Gradient1("Gradient", 2D) = "white" {}
        _ChangeAmount1("ChangeAmount", Range( 0 , 1)) = 0.5559191
        _EdgeWidth1("EdgeWidth", Range( 0 , 2)) = 0.1
        [HDR]_Color1("Color 0", Color) = (0,0,0,0)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
        [HideInInspector] __dirty( "", Int ) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Geometry+0" "IsEmissive" = "true"
        }
        Cull Back
        CGPROGRAM
        #pragma target 3.0
        #pragma surface surf Standard keepalpha addshadow fullforwardshadows
        struct Input
        {
            float2 uv_texcoord;
        };

        uniform sampler2D _MainTex1;
        uniform float4 _MainTex1_ST;
        uniform float4 _Color1;
        uniform sampler2D _Gradient1;
        SamplerState sampler_Gradient1;
        uniform float4 _Gradient1_ST;
        uniform float _ChangeAmount1;
        uniform float _EdgeWidth1;
        SamplerState sampler_MainTex1;
        uniform float _Cutoff = 0.5;

        void surf(Input i, inout SurfaceOutputStandard o)
        {
            float2 uv_MainTex1 = i.uv_texcoord * _MainTex1_ST.xy + _MainTex1_ST.zw;
            float4 tex2DNode13 = tex2D(_MainTex1, uv_MainTex1);
            float2 uv_Gradient1 = i.uv_texcoord * _Gradient1_ST.xy + _Gradient1_ST.zw;
            float temp_output_4_0 = (tex2D(_Gradient1, uv_Gradient1).r - (-1.0 + (_ChangeAmount1 - 0.0) * (1.0 - -1.0) /
                (1.0 - 0.0)));
            float clampResult10 = clamp((1.0 - (distance(temp_output_4_0, 0.5) / _EdgeWidth1)), 0.0, 1.0);
            float4 lerpResult14 = lerp(tex2DNode13, (tex2DNode13 * _Color1 * 2.0), clampResult10);
            o.Emission = lerpResult14.rgb;
            o.Alpha = 1;
            clip((tex2DNode13.a * step(0.5, temp_output_4_0)) - _Cutoff);
        }
        ENDCG
    }
    Fallback "Diffuse"
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1130;334;1353;919;1017.417;299.5124;1.762029;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1;-681.0659,912.6049;Inherit;False;Property;_ChangeAmount1;ChangeAmount;3;0;Create;True;0;0;False;0;False;0.5559191;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-468.6133,687.8745;Inherit;True;Property;_Gradient1;Gradient;2;0;Create;True;0;0;False;0;False;-1;89a4bd307b8d8fc41b86ee482feaf974;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;3;-404.5826,918.3056;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-137.6133,734.8745;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-105.8782,1067.895;Inherit;False;Constant;_Float1;Float 0;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;55.23145,1244.779;Inherit;False;Property;_EdgeWidth1;EdgeWidth;4;0;Create;True;0;0;False;0;False;0.1;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;7;122.7198,1000.364;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;8;363.3314,1045.88;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-264.6794,43.65282;Inherit;True;Property;_MainTex1;MainTex;1;0;Create;True;0;0;False;0;False;-1;818324896388d98438058d56f7e522f3;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;9;602.575,1049.769;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;199.4433,247.645;Inherit;False;Property;_Color1;Color 0;5;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;218.8463,428.0096;Inherit;False;Constant;_EdgeIntensity1;EdgeIntensity;4;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;10;820.9753,1045.869;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;540.1227,275.9746;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;11;128.67,662.6018;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;337.2816,549.9796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;643.8265,59.04736;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1080.035,146.7028;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Disslove_Easy2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;4;0;2;1
WireConnection;4;1;3;0
WireConnection;7;0;4;0
WireConnection;7;1;5;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;16;0;13;0
WireConnection;16;1;15;0
WireConnection;16;2;17;0
WireConnection;11;1;4;0
WireConnection;12;0;13;4
WireConnection;12;1;11;0
WireConnection;14;0;13;0
WireConnection;14;1;16;0
WireConnection;14;2;10;0
WireConnection;0;2;14;0
WireConnection;0;10;12;0
ASEEND*/
//CHKSM=3DA834DAA41331F9A8F5C99A2C2205ABF79AE1E7
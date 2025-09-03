Shader "Mariana/Test01/00_EnumTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(Custom)]
        [Enum(CustomEnum)] _CustomEnum("CustiomEnum",Float) = 1

        [Header(Option)]
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("BlendOp",Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendMode("BlendMode",Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode",Float) = 2
        [Enum(off,0,on,1)]_ZWriteMode("ZWriteMode",Float) =1
        [Toggle(on,off)] _ZTest("测试",Float) =1
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode",Float) = 4
        [Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask("ColorMask",Float) = 15

        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Compare",Float) = 8
        [IntRange]_StencilWriteMask("Stencil Write Mask",Range(0,255)) = 255
        [IntRange]_StencilReadMask("Stencil Read Mask",Range(0,255)) = 255
        [IntRange]_Stencil("Stencil ID",Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("Stencil Pass",Float) =0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilFail("Stencil Fail",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail("Stencil zFail",Float) = 0
    }

    SubShader
    {
        Pass {}
    }
}
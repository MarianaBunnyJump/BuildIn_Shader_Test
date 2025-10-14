// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Mariana/Test01/01_SimpleUnlitShader" //真正的shader命名，调用采用的名字
{
    Properties
    {
        //常用的五种类型
        _MyFloat("浮点数",Float) = 0.0
        _MyRange("范围",Range(0.0,1.0)) = 0.0
        _MyVector("向量",Vector) = (1,1,1,1)
        _MyColor("颜色",Color) = (0.5,0.5,0.5,0.5)
        _MainTex ("主要贴图", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            //属于UnityCG内容范围内
            #pragma vertex  vert
            #pragma fragment frag
            //unity库，很多内置函数可以调用
            //#include "UnityCG.cginc"

            //从CPU中拿到数据
            struct appdata
            {
                //一共就5个 
                //可使用常用的顶点结构appdata_base：位置、法线和一个纹理坐标。  appdata_tan：位置、切线、法线和一个纹理坐标。  appdata_full：位置、切线、法线、四个纹理坐标和颜色。
                //禁止在命名用中文！！！不然会报错
                //必须要用到的才可以写！！！不然也会报错
                float4 pos4 : POSITION;
                float2 uv : TEXCOORD0; //第一套uv
                /*float3 pos3 : POSITION;

                float3 normal3 : NORMAL;

                //模型最多4套UV
                float2 uv12 : TEXCOORD0;
                float3 uv13 : TEXCOORD0;
                float4 uv14 : TEXCOORD0;

                
                float2 uv22 : TEXCOORD1;
                float3 uv23 : TEXCOORD1;
                float4 uv24 : TEXCOORD1;

                float2 uv32 : TEXCOORD2;
                float3 uv33 : TEXCOORD2;
                float4 uv34 : TEXCOORD2;

                float2 uv42 : TEXCOORD3;
                float3 uv43 : TEXCOORD3;
                float4 uv44 : TEXCOORD3;

                float4 tangent : TANGENT; //切线矢量，用于法线贴图
                float4 color : COLOR;*/
            };

            //顶点Shader输出的结构体vertex to fragment
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0; //通用的储存器，插值器，可以放任何数据，一个凹槽，最多16个
            };

            //材质属性必须要定义，才能接收到这些数据
            //给颜色使用不同的精度，float =32位，float2 =64位，float3 =96位，float4 =128位 //坐标点使用
            //给UV使用不同的精度half = 16位 //uv 大部分向量， fixed = 8位 //颜色
            half _MyUv;
            float _MyColor;
            
            sampler2D _MainTex;
            //tex的四个数值需要使用float四维数据才能形成链接
            //对应的纹理命名，动态链接才能参与计算
            float4 _MainTex_ST;

            //顶点着色器，顶点着色器输入appdata输入的结构体声明，输出v2f输出的结构体
            v2f vert(appdata appdata)
            {
                v2f o;
                /*float4 pos_world = mul(unity_ObjectToWorld, appdata.pos4); //模型空间转世界空间
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world); //世界空间转观察空间（相机空间）
                float4 pos_screen = mul(UNITY_MATRIX_P, pos_view); //观察（相机）空间转屏幕（裁剪）空间*/
                //o.pos = pos_screen; //填充裁剪空间下的坐标
                //下面这一行 替代了上面的四行代码
                o.pos = UnityObjectToClipPos(appdata.pos4);
                
                o.uv = appdata.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            //片元Shader
            float4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
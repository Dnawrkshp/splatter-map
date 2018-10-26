// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Splatter/First-Pass Terrain"
{
	Properties
	{
		[HideInInspector]_Control("Control", 2D) = "white" {}
		[HideInInspector]_Splat3("Splat3", 2D) = "white" {}
		[HideInInspector]_Splat2("Splat2", 2D) = "white" {}
		[HideInInspector]_Splat1("Splat1", 2D) = "white" {}
		[HideInInspector]_Splat0("Splat0", 2D) = "white" {}
		[HideInInspector]_Normal0("Normal0", 2D) = "white" {}
		[HideInInspector]_Normal1("Normal1", 2D) = "white" {}
		[HideInInspector]_Normal2("Normal2", 2D) = "white" {}
		[HideInInspector]_Normal3("Normal3", 2D) = "white" {}
		[HideInInspector]_Smoothness3("Smoothness3", Range( 0 , 1)) = 1
		[HideInInspector]_Smoothness1("Smoothness1", Range( 0 , 1)) = 1
		[HideInInspector]_Smoothness0("Smoothness0", Range( 0 , 1)) = 1
		[HideInInspector]_Smoothness2("Smoothness2", Range( 0 , 1)) = 1
		_Splatter("Splatter", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" "SplatCount"="4" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#include "Splatter.hlsl"
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _Splatter;
		uniform float4 _Splatter_ST;
		uniform sampler2D _Control;
		uniform float4 _Control_ST;
		uniform float _Smoothness0;
		uniform sampler2D _Splat0;
		uniform float4 _Splat0_ST;
		uniform float _Smoothness1;
		uniform sampler2D _Splat1;
		uniform float4 _Splat1_ST;
		uniform float _Smoothness2;
		uniform sampler2D _Splat2;
		uniform float4 _Splat2_ST;
		uniform float _Smoothness3;
		uniform sampler2D _Splat3;
		uniform float4 _Splat3_ST;
		uniform sampler2D _Normal0;
		uniform sampler2D _Normal1;
		uniform sampler2D _Normal2;
		uniform sampler2D _Normal3;


		float Splatter( float4 Map , float3 WorldPos , inout float4 Albedo , inout float3 Normal , inout float Smoothness )
		{
			SplatterInput si;
			si.albedo = Albedo;
			si.normal = Normal;
			si.smoothness = Smoothness;
			si.map = Map;
			si.worldPos = WorldPos;
			SplatterOutput result = GetSplatter(si);
			Albedo = result.albedo;
			Normal = result.normal;
			Smoothness = result.smoothness;
			//Normal = float3(0, 0, 1);
			//Smoothness = 0;
			//Albedo = Map;
			return result.mask;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Splatter = i.uv_texcoord * _Splatter_ST.xy + _Splatter_ST.zw;
			float4 Map3 = tex2D( _Splatter, uv_Splatter );
			float3 ase_worldPos = i.worldPos;
			float3 WorldPos3 = ase_worldPos;
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode5_g1 = tex2D( _Control, uv_Control );
			float dotResult20_g1 = dot( tex2DNode5_g1 , float4(1,1,1,1) );
			float SplatWeight22_g1 = dotResult20_g1;
			float localSplatClip74_g1 = ( SplatWeight22_g1 );
			float SplatWeight74_g1 = SplatWeight22_g1;
			#if !defined(SHADER_API_MOBILE) && defined(TERRAIN_SPLAT_ADDPASS)
				clip(SplatWeight74_g1 == 0.0f ? -1 : 1);
			#endif
			float4 SplatControl26_g1 = ( tex2DNode5_g1 / ( localSplatClip74_g1 + 0.001 ) );
			float4 temp_output_59_0_g1 = SplatControl26_g1;
			float4 appendResult33_g1 = (float4(1.0 , 1.0 , 1.0 , _Smoothness0));
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float4 appendResult36_g1 = (float4(1.0 , 1.0 , 1.0 , _Smoothness1));
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float4 appendResult39_g1 = (float4(1.0 , 1.0 , 1.0 , _Smoothness2));
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float4 appendResult42_g1 = (float4(1.0 , 1.0 , 1.0 , _Smoothness3));
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 weightedBlendVar9_g1 = temp_output_59_0_g1;
			float4 weightedBlend9_g1 = ( weightedBlendVar9_g1.x*( appendResult33_g1 * tex2D( _Splat0, uv_Splat0 ) ) + weightedBlendVar9_g1.y*( appendResult36_g1 * tex2D( _Splat1, uv_Splat1 ) ) + weightedBlendVar9_g1.z*( appendResult39_g1 * tex2D( _Splat2, uv_Splat2 ) ) + weightedBlendVar9_g1.w*( appendResult42_g1 * tex2D( _Splat3, uv_Splat3 ) ) );
			float4 MixDiffuse28_g1 = weightedBlend9_g1;
			float4 Albedo3 = MixDiffuse28_g1;
			float4 weightedBlendVar8_g1 = temp_output_59_0_g1;
			float4 weightedBlend8_g1 = ( weightedBlendVar8_g1.x*tex2D( _Normal0, uv_Splat0 ) + weightedBlendVar8_g1.y*tex2D( _Normal1, uv_Splat1 ) + weightedBlendVar8_g1.z*tex2D( _Normal2, uv_Splat2 ) + weightedBlendVar8_g1.w*tex2D( _Normal3, uv_Splat3 ) );
			float3 Normal3 = UnpackNormal( weightedBlend8_g1 );
			float Smoothness3 = (MixDiffuse28_g1).w;
			float localSplatter3 = Splatter( Map3 , WorldPos3 , Albedo3 , Normal3 , Smoothness3 );
			o.Normal = Normal3;
			o.Albedo = Albedo3.xyz;
			o.Smoothness = Smoothness3;
			o.Alpha = 1;
		}

		ENDCG
	}

	Dependency "BaseMapShader"="Custom/Splatter/TerrainBase"
	Fallback "Diffuse"
}
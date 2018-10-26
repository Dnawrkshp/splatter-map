Shader "Custom/Splatter Map" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset] _MainTex("Albedo (RGB)", 2D) = "white" {}
		[NoScaleOffset] [Normal] _NormalMap("Normal", 2D) = "bump" {}
		[NoScaleOffset] _MetSm("Metallic Smoothness (RGB A)", 2D) = "black" {}
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "Splatter.hlsl"

		sampler2D _MainTex;
		sampler2D _NormalMap;
		sampler2D _MetSm;

		struct Input {
			float2 uv_MainTex;
			float4 vertexColor : COLOR;
			float3 worldPos;
		};

		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutputStandard o) {
			SplatterInput si;


			fixed4 ms = tex2D(_MetSm, IN.uv_MainTex);

			si.albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			si.normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
			si.smoothness = ms.a;
			si.map = IN.vertexColor;
			si.worldPos = IN.worldPos;

			SplatterOutput result = GetSplatter(si);

			o.Albedo = result.albedo;
			o.Smoothness = result.smoothness;
			o.Metallic = lerp(ms.rgb, 0, result.mask);
			o.Normal = result.normal;
		}
		ENDCG
	}
		FallBack "Diffuse"
}

Shader "Custom/Hologram"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _HoloTex ("Hologram Texture", 2D) = "white" {}
		_HoloSpeed ("Scroll Speed", Float) = 1 
    }
    SubShader
    {
		Pass
		{
			Tags 
			{ 
				"RenderPipeline"="UniversalRenderPipeline"
				"RenderType"="Transparent"
				"Queue"="Transparent"
			}

			Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			#pragma vertex vert
			#pragma fragment frag

			CBUFFER_START(UnityPerMaterial)

			float3 _Color;
			float _HoloSpeed;

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_HoloTex);
			SAMPLER(sampler_HoloTex);

			CBUFFER_END

			struct Attributes
			{
				float3 positionOS	: POSITION;
				float2 uv			: TEXCOORD;
				float3 normalOS		: NORMAL;
			};

			struct Varyings
			{
				float4 positionWS	: SV_POSITION;
				float2 uv			: TEXCOORD;
				float3 normalWS		: NORMAL;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;

				OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
				OUT.positionWS = TransformObjectToHClip(IN.positionOS);
				OUT.uv = IN.uv;

				return OUT;
			}

			float4 frag(Varyings IN) : SV_TARGET
			{
				float3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color;

				Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

				half3 normalWS = normalize(IN.normalWS);

				// Use half lambert for a more cartoonish look
				half lambert = dot(normalWS, lightDir) * 0.5 + 0.5;
				lambert = lambert * lambert;

				float3 finalColor = color * lambert;

				// Scroll holo texture
				float scroll = -_Time.y * _HoloSpeed;
				float holo = SAMPLE_TEXTURE2D(_HoloTex, sampler_HoloTex, IN.uv + float2(0, scroll)).a;

				return float4(finalColor, holo);
			}

			ENDHLSL
		}
	}    
}

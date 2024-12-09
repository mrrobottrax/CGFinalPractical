Shader "Custom/Rim"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_RimPower ("Rim Exponent", Float) = 2
		_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
		Pass
		{
			Tags 
			{ 
				"RenderPipeline"="UniversalRenderPipeline"
				"RenderType"="Opaque"
			}

			HLSLPROGRAM

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			#pragma vertex vert
			#pragma fragment frag

			CBUFFER_START(UnityPerMaterial)

			float3 _Color;

			float3 _RimColor;
			float _RimPower;

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_END

			struct Attributes
			{
				float3 positionOS	: POSITION;
				float2 uv			: TEXCOORD;
				float3 normalOS		: NORMAL;
			};

			struct Varyings
			{
				float4 positionCS	: SV_POSITION;
				float2 uv			: TEXCOORD;
				float3 normalWS		: NORMAL;
				float3 viewDirWS	: TEXCOORD1;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;

				OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

				float3 positionWS = TransformObjectToWorld(IN.positionOS);
				OUT.positionCS = TransformWorldToHClip(positionWS);
				OUT.viewDirWS = normalize(GetWorldSpaceViewDir(positionWS));

				OUT.uv = IN.uv;

				return OUT;
			}

			float3 frag(Varyings IN) : SV_TARGET
			{
				float3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).rgb * _Color;

				half3 normalWS = normalize(IN.normalWS);
				half3 viewDirWS = normalize(IN.viewDirWS);

				// Lighting
				Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

				// Use half lambert for a more cartoonish look
				half lambert = dot(normalWS, lightDir) * 0.5 + 0.5;
				lambert = lambert * lambert;

				// Rim lighting
				half rim = saturate(1 - dot(normalWS, viewDirWS));
				rim = pow(rim, _RimPower);

				float3 finalColor = color * lambert + rim * _RimColor;

				return finalColor;
			}

			ENDHLSL
		}
	}    
}
Shader "Custom/LUT"
{
    Properties
    {
        _LutTex ("LUT", 3D) = "white" {}
    }
    SubShader
    {
		Pass
		{
			HLSLPROGRAM

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			#pragma vertex vert
			#pragma fragment frag

			CBUFFER_START(UnityPerMaterial)

			TEXTURE3D(_LutTex);
			SAMPLER(sampler_LutTex);

			CBUFFER_END

			TEXTURE2D(_BlitTexture);
			SAMPLER(sampler_BlitTexture);

			// Big tri that covers whole screen
			static float4 positions[] = {
				float4(-1, -1, 0, 1),
				float4(5, -1, 0, 1),
				float4(-1, 5, 0, 1),
			};

			static float2 uvs[] = {
				float2(0, 0),
				float2(3, 0),
				float2(0, -3),
			};

			struct Attributes
			{
				uint vertexID : SV_VERTEXID;
			};

			struct Varyings
			{
				float4 position	: SV_POSITION;
				float2 uv		: TEXCOORD;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;

				OUT.position = positions[IN.vertexID];
				OUT.uv = uvs[IN.vertexID];

				return OUT;
			}

			float3 frag(Varyings IN) : SV_TARGET
			{
				float3 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, IN.uv).rgb;

				// Flip Y because that's just how the texture is laid out
				float3 samplePos = float3(color.r, 1 - color.g, color.b);

				float3 sampledColor = SAMPLE_TEXTURE3D(_LutTex, sampler_LutTex, samplePos).rgb;

				return sampledColor;
			}

			ENDHLSL
		}
	}    
}

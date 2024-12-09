Shader "Custom/Star"
{
    Properties
    {
		_StarSpeed ("Rainbow Speed", Float) = 2
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

			float _StarSpeed;

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
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;

				OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

				float3 positionWS = TransformObjectToWorld(IN.positionOS);
				OUT.positionCS = TransformWorldToHClip(positionWS);

				OUT.uv = IN.uv;

				return OUT;
			}

			float3 Hue(float degrees)
			{
				float red = abs(6 * degrees - 3) - 1;
				float green = -abs(6 * degrees - 2) + 2;
				float blue = -abs(6 * degrees - 4) + 2;
				return saturate(float3(red, green, blue));
			}

			float3 frag(Varyings IN) : SV_TARGET
			{
				float3 color = Hue(fmod(_Time.y * _StarSpeed, 1));

				half3 normalWS = normalize(IN.normalWS);

				// Lighting
				Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

				// Use half lambert for a more cartoonish look
				half lambert = dot(normalWS, lightDir) * 0.5 + 0.5;
				lambert = lambert * lambert;

				float3 finalColor = color * lambert;

				return finalColor;
			}

			ENDHLSL
		}
	}    
}

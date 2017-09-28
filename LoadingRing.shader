Shader "Custom/LoadingRing" {

	Properties {
        _RingColor ("Ring Color", Color) = (1,1,1,1)
	}

	SubShader 
	{
		Tags
        { 
            "Queue"="Geometry" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
		
		Cull off
		Lighting Off
        ZWrite Off
        Fog { Mode Off }
        Blend srcAlpha OneMinusSrcAlpha

		Pass 
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                half2 texcoord  : TEXCOORD0;
            };
			
			v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                
                return OUT;
            }
			
			#define M_PI 3.1415

			float movingRing(float2 dot, float r1, float r2)
			{
				// значение радиуса в этой точке картинки
				float r = length(dot);

				// Большой непрозрачный круг радиусом r2
				float bigCircle = lerp(1.0, 0.0, smoothstep(0.9, 1.0, r/r2)); 
				// Малый непрозрачный круг радиусом r1
				float smallCircle = lerp(1.0, 0.0, smoothstep(0.9, 1.0, r/r1));
				
				// угол в радианах как арктангенс координат
				float angleOrAlpha = atan2(dot.y, dot.x);
				angleOrAlpha  = frac(1 - frac(_Time.y) + (0.5 - angleOrAlpha / (2 * M_PI)) );
				
				// сглаживание "головы" кольца
				angleOrAlpha -= max(angleOrAlpha - 1.0 + 1e-2, 0.0) * 1e2;
				
				// Возвращаем их разность - искомое кольцо
				// И конечно, домножим на значение полупрозрачности
				return angleOrAlpha * (bigCircle - smallCircle); 
			}
			
			fixed4 _RingColor;

			fixed4 frag(v2f IN) : SV_Target
            {
                // координаты текущей точки относительно координат картинки
				// от 0 до 1 по каждой стороне
				float2 uv = IN.texcoord;
				
				fixed4 c = _RingColor;
				
				// кольцо, радиусом от 0.4 до 0.5 половины длины картинки
				// определяется полупрозрачностью.
				// (0.5, 0.5) = центр изображения
				float alpha = movingRing(uv - float2(0.5, 0.5), 0.4, 0.5); 
				
				// переназначаем значение полупрозрачности для точки
				c.a = alpha;
				
				return c;
            }
        ENDCG
		}
	}
}

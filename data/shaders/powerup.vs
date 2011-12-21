#version 110

varying vec3 N;

uniform bool isRGBLinear;

vec4 lRGB_to_sRGB(vec4 lRGB)
{
	/* inexact */
	return vec4(pow(lRGB.rgb, vec3(1.0 / 2.2)), lRGB.a);
}

void main()
{
	vec4 c = gl_Color;
	if (!isRGBLinear) {
		c = lRGB_to_sRGB(c);
	}
	
	gl_FrontColor = c;
	
	gl_Position = ftransform();
	
	N = gl_NormalMatrix * gl_Normal;
}

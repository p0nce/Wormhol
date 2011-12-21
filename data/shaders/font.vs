#version 110

uniform bool isRGBLinear;

vec4 lRGB_to_sRGB(vec4 lRGB)
{
	/* inexact */
	return vec4(pow(lRGB.rgb, vec3(1.0 / 2.2)), lRGB.a);
}

void main()
{
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = ftransform();
	
	vec4 c = gl_Color;
	if (!isRGBLinear) {
		c = lRGB_to_sRGB(c);
	}
	
	gl_FrontColor = c;
}

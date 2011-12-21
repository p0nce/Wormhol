#version 110

vec4 lRGB_to_sRGB(vec4 lRGB)
{
	/* inexact */
	return vec4(pow(lRGB.rgb, vec3(1.0 / 2.2)), lRGB.a);
}

void main()
{
	gl_FrontColor = lRGB_to_sRGB(gl_Color);
	gl_Position = ftransform();
}

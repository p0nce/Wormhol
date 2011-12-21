#version 110
uniform sampler2D tex;


vec4 sRGB_to_lRGB(vec4 sRGB)
{
	/* inexact */
	return vec4(pow(sRGB.rgb, vec3(2.2)), sRGB.a);
}

void main()
{
	vec2 p = gl_TexCoord[0].xy;	
	gl_FragColor = gl_Color * sRGB_to_lRGB(texture2D(tex, p));
}

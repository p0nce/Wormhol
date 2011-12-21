#version 110
uniform sampler2D tex;
uniform sampler2D fill;
uniform bool isRGBLinear;

vec4 sRGB_to_lRGB(vec4 sRGB)
{
	return vec4(pow(sRGB.rgb, vec3(2.2)), sRGB.a );
}


void main()
{	
	vec2 p = gl_TexCoord[0].xy;
	
	
	vec4 letter = texture2D(tex, p);
	vec4 fillColor = sRGB_to_lRGB(texture2D(fill, p));
	
	if (isRGBLinear)
	{
		letter = sRGB_to_lRGB(letter);
		fillColor = sRGB_to_lRGB(fillColor);		
	}

	gl_FragColor = letter * fillColor * gl_Color;
}
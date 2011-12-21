#version 110
uniform sampler2D tex;
uniform sampler2D blurTex;

uniform float blurAmount;
uniform float PPAmount;
uniform float HFAmount;
uniform float blurbias;


uniform float gammaExp;

const vec3 LUMINANCE = vec3(0.27, 0.67, 0.06);
const vec3 GREY = vec3(1.0 / 3.0);

const float WHITEPOINT = 2.0;
const float EXPOSURE = 0.7;

vec3 toneMap(vec3 color, vec3 refColor)
{
	float avgLuminance = dot(LUMINANCE, refColor);
  	float luminance = dot(LUMINANCE, color);

  	float Lp = luminance * EXPOSURE / avgLuminance;

	float tmp = Lp * (1.0  + Lp / (WHITEPOINT * WHITEPOINT) ) / (1.0 + Lp);
	return color * tmp;
}

vec3 saturate(vec3 s)
{
	return smoothstep(0.0, 1.0, s );
}

const float blurBias = 1.0;

void main()
{
	vec2 p0 = gl_TexCoord[0].xy;
	vec2 p1 = gl_TexCoord[1].xy;
	
	

	vec3 blur6 = texture2D(blurTex, p1, 6.0 + blurBias).rgb;
	vec3 blur5 = texture2D(blurTex, p1, 5.0 + blurbias).rgb;
	vec3 blur4 = texture2D(blurTex, p1, 4.0 + blurbias).rgb;
	vec3 blur2 = texture2D(blurTex, p1, 2.0 + blurbias).rgb;
	vec3 blur0 = texture2D(blurTex, p1, 0.0 + blurbias).rgb;

	vec3 blur = blur0 * 0.30 + blur4 * 0.04 + blur5 * 0.08 + blur6 * 0.06;

	vec3 color = texture2D(tex, p0).rgb + blurAmount * blur;

	vec3 lofreq = blur2;	/* cutoff level */
	vec3 hifreq = color - blur2;
	
	vec3 finalColor = hifreq * HFAmount + saturate(toneMap(lofreq, blur6));

	vec3 finalColorMixed = mix(color, finalColor, PPAmount); /* * 0.001 + blur; */
	
	
	/* gamma correct */
	/* gl_FragColor = vec4(pow(finalColorMixed.rgb, vec3(gammaExp)), 1.0); */
	
	gl_FragColor = vec4(pow(finalColorMixed, vec3(gammaExp)), 1.0);
}


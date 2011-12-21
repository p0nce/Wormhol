#version 110
/*
	Total rip from the paper:
	"Dynamic Solid Textures for Real-Time Coherent Stylization" from Pierre Benard, Adrien Bousseau, Joelle Thollot
	Check it, it's brilliant.
*/


varying vec3 N;
varying vec4 hweight;
varying vec4 texCord;

const float TWO_PI = 6.283185307;

vec4 procTex(vec4 pos)
{	
	vec4 h1 = abs(sin(pos * TWO_PI));
	vec4 h2 = abs(sin(2.0 * pos * TWO_PI));
	vec4 h3 = abs(sin(4.0 * pos * TWO_PI));
	vec4 h4 = abs(sin(8.0 * pos * TWO_PI));
	h1 = vec4(h1.x * h1.y * h1.z);
	h2 = vec4(h2.x * h2.y * h2.z);
	h3 = vec4(h3.x * h3.y * h3.z);
	h4 = vec4(h4.x * h4.y * h4.z);	

	vec4 base = vec4(0.5);
	
	mat4 H = mat4(h1, h2, h3, h4);

	return base + H * hweight;
}


void main()
{
	
	vec4 texc = gl_Color * procTex(texCord);
	
	float f = 0.6 + 0.3 * dot(normalize(N), vec3(0.0,1.0,0.0));
	/* blending */
	gl_FragColor = f * texc;
}

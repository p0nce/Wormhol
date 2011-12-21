#version 110
/* 
	Total rip from the paper:
	"Dynamic Solid Textures for Real-Time Coherent Stylization" from Pierre Benard, Adrien Bousseau, Joelle Thollot  
	Check it, it's brilliant.
*/

varying vec4 hweight;
varying vec3 N;
varying vec4 texCord;
uniform mat4 invCameraMatrix;

const vec4 LEVEL_MIN = vec4(0.0, 1.0, 2.0, 3.0);
const vec4 LEVEL_MAX = vec4(1.0, 2.0, 3.0, 4.0);



void main(void)
{	
	vec4 posTransform = gl_ModelViewMatrix * gl_Vertex;
	
	float dist = abs(1e-10 + posTransform.z);
	float level = log2(dist);	
	
	hweight = vec4(0.5, 0.3, 0.2, 0.1) * ( vec4(1.0) - smoothstep(LEVEL_MIN, LEVEL_MAX, vec4(level)));
	
	N = normalize(gl_NormalMatrix * gl_Normal);

	gl_FrontColor = gl_Color;
		
	gl_Position = ftransform();
	texCord = (invCameraMatrix * posTransform) * 2.0;
}
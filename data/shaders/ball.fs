#version 110

varying vec3 N;

void main()
{
	vec3 n = normalize(N);
	float s = 0.8 + 0.5 * dot(n, vec3(0, 1, 0));
	gl_FragColor = gl_Color * vec4(s);
}

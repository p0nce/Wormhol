#version 120
uniform sampler2D tex;
uniform vec4 sizeInfo;
uniform float level;

/*
For horizontal blur, feed this with vec4f( 0.5 / tex.width, 0, -0.5 / tex-width, 0)
For vertical blur, feed this with vec4f( 0, 0.5 / tex.height, 0, -0.4 / tex-width)
*/

void main()
{
	vec2 p = gl_TexCoord[0].xy;

	vec4 a = texture2DLod(tex, p + sizeInfo.xy, level);
	vec4 c = texture2DLod(tex, p + sizeInfo.zw, level);

	gl_FragColor = vec4(0.5) * (a + c);
}

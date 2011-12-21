#version 110
void main()
{
	gl_FrontColor = gl_Color;
	gl_Position = ftransform();
}

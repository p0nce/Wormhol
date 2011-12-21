module res.bgcolor;

import res.settings;
import math.all;

vec4f getBackGroundColor()
{
	float gammaExp = (useHDR && usePostProcessing) ? 1.f : 1.f / 2.2f;
	vec4f DARK_BLUE = vec4f(0, 0, powf(0.006f, gammaExp), 1.f);	
	return DARK_BLUE;
}


vec4f getBackGroundColorNotCorrected()
{
	
	vec4f DARK_BLUE = vec4f(0, 0, 0.006f, 1.f);
	return DARK_BLUE;
}

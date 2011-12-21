module scene.torusgeometry;

import math.all;
import gl.all;

class TorusGeometry // elliptic torus geometry
{
    public
    {
        int m_slices, m_stacks;

        vec3f[] m_points;
        vec3f[] m_normals;
        
        float m_majorRadius, m_minorRadiusNorm, m_minorRadiusPlane;
        
        float m_normalFactor;

        void computeGeometry(int stacks, int slices)
        {
	        assert(stacks > 0);
	        assert(slices > 0);
            m_slices = slices;
            m_stacks = stacks;

            m_points.length = m_stacks * m_slices;
            m_normals.length = m_stacks * m_slices;

            for (int i = 0; i < m_stacks; ++i)
            {
                for (int j = 0; j < m_slices; ++j)
                {
                    float theta = (TWO_PI_F * i) / m_stacks;
                    float phi = (TWO_PI_F * j) / m_slices;
                    m_points[j + i * m_slices] = torus3f(m_majorRadius, m_minorRadiusNorm, m_minorRadiusPlane).point(theta, phi);
                    m_normals[j + i * m_slices] = m_normalFactor * torus3f(m_majorRadius, m_minorRadiusNorm, m_minorRadiusPlane).normal(theta, phi);
                }
            }
        }

        void pt(int i, int j)
        {
	        vec3f pos = m_points[j + i * m_slices];
	        vec3f normal = m_normals[j + i * m_slices];
	        
	        GL.normal(normal);
            GL.vertex(pos);            
        }
    }

    public
    {
        this(int stacks, int slices, float majorRadius, float minorRadiusNorm, float minorRadiusPlane, bool normalOutside)
        {
	        m_minorRadiusNorm = minorRadiusNorm;
	        m_minorRadiusPlane = minorRadiusPlane;
	        m_majorRadius = majorRadius;
	        m_normalFactor = normalOutside ? 1.f : -1.f;
	        
            computeGeometry(stacks, slices);
            
        } 

        void render()
        {
	        
	        for (int i = 0; i < m_stacks - 1; ++i)
            {
	            GL.begin(GL.QUADS);
	            
	            pt(i, 0);	 
	            pt(i + 1, 0);
	        	for (int j = m_slices - 1; j >= 0; --j)
	        	{
		        	pt(i, j);	
		        	pt(i + 1, j);
		        	 
	               	
	        	}
	        	
				
	        	GL.end();
            }
            
            
            GL.begin(GL.QUADS);
	        	for (int j = 0; j < m_slices; ++j)
	        	{
		        	pt(m_stacks - 1, j);	 
	               	pt(0, j);
	        	}
	        	pt(m_stacks - 1, 0);	 
				pt(0, 0);
        	GL.end();            
        }
    }

}

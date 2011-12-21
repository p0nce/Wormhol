module scene.spheregeometry;


import math.all;
import gl.all;

class SphereGeometry // unit Sphere Geometry
{
    public
    {
        int m_slices, m_stacks;

        vec3f m_top, m_bottom;
        vec3f[] m_points;
        vec3f m_size;
        vec4f m_color;
        float m_radius;
        float m_normalFactor;

        void computeGeometry(int stacks, int slices)
        {
            m_slices = slices;
            m_stacks = stacks;

            m_points.length = (m_stacks-1)  * m_slices;

            m_top = vec3f(0,0,+1);
            m_bottom = vec3f(0,0,-1);
			

            for (int i = 0; i < m_stacks - 1; ++i)
            {
                for (int j = 0; j < m_slices; ++j)
                {
                    float theta = PI_F * (- 0.5f + (i + 1.f) / (m_stacks + 1));
                    float phi = (TWO_PI_F * j) / m_slices;
                    m_points[j + i * m_slices] = sphereMap(theta, phi);
                }
            }
        }

        void vertex(vec3f p) // p should be normalized
        {
            GL.normal(p * m_normalFactor);
            GL.vertex(p * m_radius);
        }

        vec3f pt(int i, int j)
        {
            return m_points[j + i * m_slices];
        }
    }

    public
    {
        this(int stacks, int slices, float radius, bool normalOutside)
        {
            computeGeometry(stacks, slices);
            m_normalFactor = normalOutside ? 1.f : -1.f;
            m_radius = radius;
        }
        
          

        void render()
        {
	        
            // bottom
            GL.begin(GL.TRIANGLE_FAN);
                vertex(m_bottom);

                
                for (int j = 0; j < m_slices; ++j)
                {
                    vertex(pt(0, j));
                }
                vertex(pt(0, 0));
                

            GL.end();


            for (int i = 0; i < m_stacks - 2; ++i)
            {
                GL.begin(GL.QUAD_STRIP);

                for (int j = 0; j < m_slices; ++j)
                {
	                vertex(pt(i,j));
                    vertex(pt(i+1,j));                    
                }
				vertex(pt(i,0));
                vertex(pt(i+1,0));
                

                GL.end();
            }

            // top
            GL.begin(GL.TRIANGLE_FAN);
                vertex(m_top);
                vertex(pt(m_stacks - 2, 0));
                for (int j = m_slices - 1; j >= 0; --j)
                {
                    vertex(pt(m_stacks - 2, j));
                }
                
            GL.end();
            
        }
    }

}

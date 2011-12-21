module scene.powerupgeometry;

import math.all;
import gl.all;

class PowerupGeometry // unit Sphere Geometry
{
    public
    {
        int m_slices, m_stacks;

        vec3f m_top, m_bottom;
        vec3f[] m_points;
        vec3f m_size;
        vec4f m_color;
        float m_normalFactor;

        void computeGeometry(int stacks, int slices)
        {
            m_slices = slices;
            m_stacks = stacks;

            m_points.length = (m_stacks-1)  * m_slices;

            float getRadius(float theta, float phi)
            {
                //return 1.f + 0.5f * cos(theta) * sin(phi * 3);
                return 1.f;
            }

            m_top = vec3f(0,0,getRadius(+0.5f * PI_F, 0.f));
            m_bottom = vec3f(0,0,-getRadius(-0.5f * PI_F, 0.f));


            for (int i = 0; i < m_stacks - 1; ++i)
            {
                for (int j = 0; j < m_slices; ++j)
                {
                    float theta = PI_F * (- 0.5f + (i + 1.f) / (m_stacks + 1));
                    float phi = (TWO_PI_F * j) / m_slices;

                    float radius = getRadius(theta, phi);

                    m_points[j + i * m_slices] = radius * sphereMap(theta, phi);
                }
            }
        }

        void vertex(vec3f p) // p should be normalized
        {
            GL.normal(p);
            GL.vertex(p);
        }

        vec3f pt(int i, int j)
        {
            return m_points[j + i * m_slices];
        }
    }

    public
    {
        this(int stacks, int slices)
        {
            computeGeometry(stacks, slices);
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

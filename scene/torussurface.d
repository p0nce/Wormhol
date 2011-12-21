module scene.torussurface;

import math.all;
import scene.nonmeshsurface;
import scene.scenemanager;
import scene.gameobject;
import gl.all;
import scene.torusgeometry;
import sdl.all;
import misc.logger;


final class TorusSurface : NonMeshSurface
{
    private
    {
		TorusGeometry m_torusGeometry;
		float m_majorRadius, m_minorRadiusNorm, m_minorRadiusPlane;
    }

    public
    {
        this(SceneManager manager, mat4f transform, float majorRadius, float minorRadiusNorm, float minorRadiusPlane)
        {
            super(manager, transform);
            assert(majorRadius > 0);
            assert(minorRadiusNorm > 0);
            assert(minorRadiusPlane > 0);
            m_majorRadius = majorRadius;
            m_minorRadiusNorm = minorRadiusNorm;
            m_minorRadiusPlane = minorRadiusPlane;            
            
            m_torusGeometry = new TorusGeometry(10, 20, majorRadius, minorRadiusNorm, minorRadiusPlane, true);  
        }

 
        override bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
	        return false;
	        /*
	        torus3f t = torus3f(m_majorRadius, m_minorRadiusNorm, m_minorRadiusPlane);
            return t.hit(r, distance, point, normal);            
            */
        }

        override void recomputeBoundingBox()
        {
	        vec3f v = vec3f(m_majorRadius + m_minorRadiusPlane, m_majorRadius + m_minorRadiusNorm, m_minorRadiusNorm);
	        m_boundingBox = box3f(-v, v);
        }

        override void doRender(double t)
        {
            GL.color = vec4f(1, 1, 1, 1);

            GL.disable(GL.CULL_FACE);
            shader().use();            
            
            m_torusGeometry.render();
        }
    }
}


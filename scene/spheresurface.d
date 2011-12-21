module scene.spheresurface;

import math.all;
import scene.nonmeshsurface;
import scene.scenemanager;
import scene.gameobject;
import gl.all;
import scene.spheregeometry;
import sdl.all;
import misc.logger;

// A surface



final class SphereSurface : NonMeshSurface
{
    private
    {
		SphereGeometry m_sphereGeometry;        
    }

    public
    {
        this(SceneManager manager, mat4f transform)
        {
            super(manager, transform);
            m_sphereGeometry = new SphereGeometry(40, 80, 1.f, true);            
        }

 
        override bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            spheref s = spheref(vec3f(0), 1.f);
            return s.hit(r, distance, point, normal);
        }

        override void recomputeBoundingBox()
        {
	        m_boundingBox = box3f(vec3f(-1.f), vec3f(+1.f));
        }

        override void doRender(double t)
        {
            GL.color = vec4f(1, 1, 1, 1);

            shader.use();            
            
            m_sphereGeometry.render();
        }
    }
}


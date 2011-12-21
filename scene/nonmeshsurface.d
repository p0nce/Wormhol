module scene.nonmeshsurface;

import math.all;
import scene.surface;
import scene.scenemanager;
import scene.gameobject;
import gl.all;
import misc.logger;

// A non-mesh surface

class NonMeshSurface : Surface
{
    private
    {
        Shader m_surfaceShader;
    }

    protected
    {
        Shader shader()
        {
            return m_surfaceShader;
        }
    }

    public
    {
        this(SceneManager manager, mat4f transform)
        {
            super(manager, transform);
            m_surfaceShader = getShader("surface");
        }
    }
}


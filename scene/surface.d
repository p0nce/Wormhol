module scene.surface;

import math.all;
import scene.gameobject;
import scene.scenemanager;
import misc.logger;

// A surface

class Surface : GameObject
{
    private
    {
        mat4f m_matrix;
        mat4f m_invMatrix;
    }

    public
    {
        this(SceneManager manager, mat4f transform)
        {
            super(manager);
            m_matrix = transform;
            m_invMatrix = transform.inversed();
        }        

        override mat4f matrix()
    	{
            return m_matrix;
    	}
    	
    	override mat4f invMatrix()
        {
            return m_invMatrix;
        }
    }
}



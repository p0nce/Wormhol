module scene.powerup;

import scene.gameobject;
import scene.scenemanager;
import scene.powerupgeometry;
import math.all;
import gl.all;

class Powerup : GameObject
{
	private
	{
		
		PowerupGeometry m_geometry;
		vec3f m_pos, m_up, m_front, m_right;
		bool m_alive;
		vec3f m_color;	
		float m_size = 0.f;
	}
	
	public
	{
		static const RADIUS = 0.03f;
		
		this(SceneManager manager)
        {
            super(manager); 
            m_geometry = new PowerupGeometry(8, 16);
            m_pos = vec3f(0);
            m_alive = false;
            
            auto random = Random();                 
        }
        
        void renew(vec3f pos, vec3f up, vec3f front, vec3f right)
        {
			m_pos = pos;
			m_up = up;
			m_front = front;
			m_right = right;
			m_alive = true;
			m_size = 0.f;
			float x = Random().nextFloat();
			m_color = vec3f(1.8 - 0.8f * x, 0.1 + 0.5f * x, 0.1 + 0.1f * x);
        }
        
        vec3f pos()
        {
			return m_pos;
        }
        
        vec3f color() { return m_color; }
        
        void die()
        {
			m_alive = false;   
        }        
        
        bool alive() { return m_alive; }

		override bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            return false;
        }

        override void recomputeBoundingBox()
        {
	        m_boundingBox = box3f(vec3f(-RADIUS), vec3f(+RADIUS));
        }

        override void doRender(double t)
        {
            GL.color = m_color;
            GL.scale(vec3f(m_size));
            
            m_geometry.render();
        }
        
        void move(float dt)
        {
			  m_size = min(m_size + dt, 1.f);
        }
        
        override mat4f matrix()
        {
			return mat4f.translate(m_pos) * mat4f.scale(RADIUS);   
        }
		
		override mat4f invMatrix()
        {
			return  mat4f.scale(1.f / RADIUS) * mat4f.translate(-m_pos);   
        }
	}
	
}
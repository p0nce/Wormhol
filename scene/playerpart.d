module scene.playerpart;

import math.all;
import scene.scenemanager;
import scene.spheregeometry;
import scene.powerup;
import gl.all;
import misc.logger;
import res.settings;


struct PlayerPart
{
	public
	{
		const float RADIUS = 0.04f;
	}
	
	private
	{
		vec3f m_pos;	
        vec3f m_up, m_right, m_front;
		static bool geometryConstructed = false;
        static SphereGeometry[4] geometry;   
	}
	
	public
	{
		static PlayerPart opCall(vec3f pos, vec3f right, vec3f up, vec3f front)
		{
			PlayerPart res = void;
			res.m_pos = pos;
			res.m_right = right;
			res.m_up = up;
			res.m_front = front;
			
			if (!geometryConstructed) 
            {
	            geometry[0] = new SphereGeometry(20, 40, RADIUS, true);
	            geometry[1] = new SphereGeometry(10, 20, RADIUS, true);
	            geometry[2] = new SphereGeometry(5, 10, RADIUS, true);
	            geometry[3] = new SphereGeometry(3, 5, RADIUS, true);	   
	            geometryConstructed = true;         
            }	
            
			return res;
		}
		
		void render(double t)
        {
	        geometry[2].render();
        }
  /*      
       	override mat4f matrix()
        {
            return mat4f.translate(m_pos);
        }

        override void recomputeBoundingBox()
        {
	        m_boundingBox = box3f(-vec3f(m_radius), vec3f(m_radius));
        }

        override mat4f invMatrix()
        {
            return mat4f.translate(-m_pos);
        }
        
        override bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            return false;
        }
*/        
        vec3f pos() { return m_pos; }
        vec3f up() { return m_up; }
        vec3f right() { return m_right; }
        vec3f front() { return m_front; }        
        
        bool collides(PlayerPart* part)
        {
	        static const float SQRRADIUS4 = 4.f * RADIUS * RADIUS;
			return (m_pos - part.m_pos).squaredLength < SQRRADIUS4;
        }
        
        bool collides(Powerup pu)
        {
	        static const float SQRRADIUS = (RADIUS + Powerup.RADIUS) * (RADIUS + Powerup.RADIUS);
			return (m_pos - pu.pos).squaredLength < SQRRADIUS;
        }
	}
}

module scene.particle;

import gl.all;
import misc.logger;
import math.all;

// actually it does nothing to add final, but it's allowed by the compiler
// to be really shure it iz final
final final final final struct Particle 
{
	private
	{
		vec3f m_pos;
		vec3f m_mov;
		vec3f m_acc;
		vec3f m_color;
		float m_life;		
	}
	
	public
	{
		
		static Particle opCall(vec3f pos, vec3f mov, vec3f color, float life)
		{
			Particle pr = void;
			pr.m_pos = pos;
			pr.m_mov = mov;
			pr.m_acc = vec3f(0.f);
			pr.m_color = color;
			pr.m_life = life;
			return pr;
		}
		
		bool isDead()
		{
			return m_life <= 0;	
		}	
		
		bool isAlive()
		{
			return m_life > 0;	
		}			
		
		void move(float dt, float visco)
		{
			m_life -= dt;
		//	m_mov += dt * m_acc;
			m_pos += dt * m_mov;
			m_mov *= visco;
		}
		
		void draw(float g_alpha)
		{
			float alpha = min(1.f, m_life ) * g_alpha;
			GL.color = vec4f(m_color.x, m_color.y, m_color.z, alpha);		 // m_life is clamped
			GL.vertex(m_pos);
		}
	}
}

static assert(Particle.sizeof % 4 == 0);
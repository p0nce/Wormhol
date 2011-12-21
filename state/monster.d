module state.monster;

import gamecontext;
import math.all;
import gl.all;
import state.eye;


class Monster
{
	vec2f m_pos;
    vec2f m_destPos;
    vec2f m_vel;

    Texture2D m_tex;
    float m_size;
    Eye[] eyes;
    Random m_random;
    GameContext m_context;
    
    enum Which { LEFT, BOTTOM, RIGHT };
    
    Which m_which;
    vec2f noise;  
    vec2f vnoise;  

    this(GameContext context, Which which, Texture2D tex, vec2f pos, float size)
    {
        m_destPos = pos;
        m_pos = pos;
        m_tex = tex;
        m_size = size;
        m_random = Random();
        m_vel = vec2f(0);
        m_context = context;
       
        m_which = which;
        noise = vnoise = vec2f(0.f);
        
        if (which == Which.LEFT)
        {
        	addEye(vec2f(-0.098,0.9), 0.045 * 1.1f);
        	addEye(vec2f(0.77,0.555), 0.045 * 1.1f);
    	}
    	else if (which == Which.BOTTOM)
    	{
        	addEye(vec2f(-0.185,0.405), 0.08 * 1.1f);
        	addEye(vec2f(-0.29,0.5), 0.08 * 1.1f);
    	}
    	else if (which == Which.RIGHT)
    	{
        	addEye(vec2f(-0.682,0.255), 0.10 * 1.1f);
        	addEye(vec2f(-0.63,0.03), 0.10 * 1.1f);
    	}
    }

    void addEye(vec2f posRel, float size)
    {
	    Eye toFollow = null;
	    if (eyes.length > 0) toFollow = eyes[0];
        eyes ~= new Eye(m_context, posRel, size, toFollow);
    }

    void draw(float transition, float monsterCome)
    {
        vec2f where = m_pos + noise;
        float ratio = m_tex.ratio;

        Shader shader = m_context.shaderPool.getBlitShader();
		shader.use();
        shader.setSampler("tex", m_tex);
        

        GL.color = vec4f(1.2f, 1.2f, 1.2f, transition * transition);

        vec2f a = where + m_size * vec2f(-ratio, +1.f);
        vec2f b = where + m_size * vec2f(-ratio, -1.f);
        vec2f c = where + m_size * vec2f(+ratio, -1.f);
        vec2f d = where + m_size * vec2f(+ratio, +1.f);

        GL.begin(GL.QUADS);
            GL.texCoord(0, m_tex.smin, m_tex.tmin); GL.vertex(a);
            GL.texCoord(0, m_tex.smin, m_tex.tmax); GL.vertex(b);
            GL.texCoord(0, m_tex.smax, m_tex.tmax); GL.vertex(c);
            GL.texCoord(0, m_tex.smax, m_tex.tmin); GL.vertex(d);
        GL.end();

        foreach (Eye e;  eyes) 
        {
	        e.draw(where, m_size * vec2f(ratio, 1.f), transition);
        }
    }

    void move(float dt)
    {
	    
        foreach (Eye e;  eyes) 
        {
	        e.move(dt);
        }
        
        vec2f anoise = 0.2f * m_random.nextGauss2f();
		vnoise += anoise * dt;
		noise += vnoise * dt;
		vnoise *= exp(-dt * 2);
		noise *= exp(-dt * 2);
        
        /*
        vec2f m_acc = dt * (0.02 * m_random.nextGauss2f() + 15.f * (m_destPos - m_pos));
        m_vel += dt * m_random.nextGauss2f();
        m_vel *= exp(-dt * 5.f);
        m_pos += m_vel * dt;
*/
    }    
}
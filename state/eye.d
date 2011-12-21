module state.eye;

import gamecontext;
import res.shaderpool;
import math.all;
import gl.all;
import math.random;

class Eye
{
    private
    {
        float m_size;
        vec2f m_pos;
        GameContext m_context;
        Texture2D m_texture;
        double fearChangeTime;
        Random m_random;
        bool fear = true;
        float fearProgress = 1.f;
        Eye m_follow;      
        vec2f noise;  
        vec2f vnoise;  
    }

    public
    {
        this(GameContext context, vec2f pos, float size, Eye follow = null)
        {
            m_size = size;
            m_pos = pos;
            
            m_context = context;
            m_texture = context.textures.eye;
            m_random = Random();
            
            fearChangeTime = randomFearTime();
            m_follow = follow;
            noise = vnoise = vec2f(0.f, 0.f);
            
        }
        
        double randomFearTime()
        {
			return 0.5f + sqr(m_random.nextFloat()) * 6.f;
        } 

        void draw(vec2f parentPos, vec2f parentSize, float transition)
        {
            void drawEye(vec2f where, float radius)
            {
	            GL.begin(GL.QUADS);

                    GL.texCoord(0, 0, 0); GL.vertex(where + vec2f(-radius, radius));
                    GL.texCoord(0, 0, 1); GL.vertex(where + vec2f(-radius, -radius));
                    GL.texCoord(0, 1, 1); GL.vertex(where + vec2f(radius, -radius));
                    GL.texCoord(0, 1, 0); GL.vertex(where + vec2f(radius, radius));
                    
                GL.end();
            }

            Shader shader = m_context.shaderPool.getBlitShader();
            shader.use();
            shader.setSampler("tex", m_texture);

            vec2f rpos = parentPos + m_pos * parentSize;
            
            float fp = m_follow is null ? fearProgress : m_follow.fearProgress;
            vec2f noisePos = m_follow is null ? noise : m_follow.noise;
            
        //	vec2f noisePos = noise;
            vec2f dpos = (m_context.mousePos - rpos) * 0.05f * fp;
            if (dpos.length > m_size * 0.3)
            {
                dpos = m_size * 0.3 * dpos.normalized;
            }
            
            GL.color = vec4f(0.f, 0.f, 0.f, transition);
            drawEye(rpos + dpos + noisePos * m_size, parentSize.y * m_size * 0.5);           
        }
        
        void move(double dt)
        {
			fearChangeTime -= dt;
			
			if (fearChangeTime < 0.f)
			{
				fearChangeTime = randomFearTime();
				fear = !fear;
			}
			float fearDest = fear ? 1.f : 0.f;
			
			fearProgress += (fearDest - fearProgress) * (1.f - exp(-dt * 40.f));        
			
			vec2f anoise = 20.f * m_random.nextGauss2f();
			vnoise += anoise * dt;
			noise += vnoise * dt;
			vnoise *= exp(-dt * 60);
			noise *= exp(-dt * 60);
			
        }
    }
}
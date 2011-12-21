module scene.camera;

import math.all;

import gl.all;
import scene.scenemanager;
import scene.player;
import res.shaderpool;
import res.settings;
import res.bgcolor;
import misc.logger;
import sdl.all;
import bitmapfont;
import gamecontext;

class Camera
{
    private
    {
        box2i m_viewport, m_totalviewport;
        
        quatf m_rot;
        int m_index;
        SceneManager m_sceneManager;
        float m_FOV;
        
        vec3f m_pos;
        vec3f m_up;
        vec3f m_right;
        vec3f m_front;
        vec3f m_dest_up, m_dest_right, m_dest_front, m_dest_pos;
        float gone = 0.f;
        float allscreen = 0.f;
        
        bool m_inited = false;
        
        BitmapFont m_bitmapFont;
        
        GameContext m_context;
	}

    public
    {
        this(SceneManager sceneManager, int index, box2i viewport, box2i totalviewport, GameContext context)
        {
	        m_sceneManager = sceneManager;
            m_viewport = viewport;
            m_index = index;
            m_FOV = 60;
            m_context = context;
            m_totalviewport = totalviewport;
		}       
         
		mat4f getCameraMatrix()
		{
			
			return mat4f.lookAt(m_pos + m_up * 1.5f + m_front * 0.2, m_pos + m_front * 0.4f, m_front);
			//return mat4f.lookAt( vec3f(1.f + axis(0), 1.f + axis(1), -0.5f + 1.f * axis(3)), vec3f(0.f + axis(2),1.f,-0.5f),vec3f(0,1,0));
		}
		
		void render(double t, double transition)
		{
			assert(m_inited);
			
		    if (transition < 0.05) return;
		    
		    vec2f va = vec2f(m_viewport.xmin, m_viewport.ymin);
		    vec2f vb = vec2f(m_viewport.xmax, m_viewport.ymax);
		    va = va * (1.f - allscreen) + allscreen * vec2f(m_totalviewport.xmin, m_totalviewport.ymin);
		    vb = vb * (1.f - allscreen) + allscreen * vec2f(m_totalviewport.xmax, m_totalviewport.ymax);
		    
		    float open = transition * (1.f - gone);		    
		    
		    vec2f vc = (va + vb) * 0.5f;
		    vec2f va2 = vc + (va - vc) * open;
		    vec2f vb2 = vc + (vb - vc) * open;
		    box2i newvp = box2i(vec2i(round(va2.x), round(va2.y)), vec2i(round(vb2.x), round(vb2.y)));
		    
		    if ((newvp.width == 0) || (newvp.height == 0)) return;
		    
		    GL.viewport = newvp;
		
		    auto ratio = newvp.ratio;
		
		    GL.projectionMatrix = mat4f.perspective(m_FOV, ratio, 0.01 , 1e2);		    
		    
		    auto cameraMatrix = getCameraMatrix();
		    
		    GL.modelviewMatrix = cameraMatrix;
		    auto cameraMatrixInverse = cameraMatrix.inversed();
		
		    m_sceneManager.render(t, cameraMatrix, cameraMatrixInverse);
		    
		    // overlay
		    {
			    GL.projectionMatrix = mat4f.scale(1.f / ratio, 1.f, 1.f);
				GL.modelviewMatrix = mat4f.scale(1.0);
	
	            GL.enable(GL.BLEND, GL.ALPHA_TEST);
	            GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);
	
	            GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
	 			
	            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
			    
			    Player followed = m_sceneManager.player(m_index);
				auto YELLOW = vec4f(1.3f, 1.3f, 1.3f,transition);
				auto BLACK = vec4f(0.f, 0.f, 0.f,transition);
			/*	
			    if (followed.loser)
			    {
				    float a = 0.02f;
				   
				    m_context.font.drawString("you suck", 0, 0, 0.15 + 0.05 * sin(t * 3), YELLOW);    
				}
			*/	
			    if (followed.winner)
			    {
				    float a = 0.02f;
				    
				    m_context.font.drawString("You win", 0, 0, 0.3 + 0.2 * sin(t * 3), YELLOW);    
				}
			
			
				
			}
			
		    drawBorder(transition, ratio);
	    	
		}
        
      

        void move(double t, double dt)
        {
	        Player followed = m_sceneManager.player(m_index);
	        
	        if ((followed.loser)&& (followed.count == 0)) gone = minf(1.f, gone + dt * 1.7f);
	        if (followed.winner) allscreen = minf(1.f, allscreen + dt * 1.7f);
	        
	        if (followed.count > 0) // has a head
	        {
		        m_dest_up = followed.up;
		    	m_dest_right = followed.right;
		    	m_dest_front = followed.front;
				m_dest_pos = followed.pos;		        
	        }
			
			if (!m_inited)
	        {
		        m_up = m_dest_up;
			    m_pos = m_dest_pos;
			    m_right = m_dest_right;
			    m_front = m_dest_front;
		        m_inited = true;		        
	        }
	        else	        
	        {
		        float a = 1.f - exp(-dt * 8.f);
		        
		        m_up = mix(m_up, m_dest_up, vec3f(a));
			    m_pos = mix(m_pos, m_dest_pos, vec3f(a));
			    m_right = mix(m_right, m_dest_right, vec3f(a));
			    m_front = mix(m_front, m_dest_front, vec3f(a));		    
	        }
	        
        }
    }

    private
    {
        void drawBorder(float transition, float ratio)
        {
            GL.enable(GL.BLEND, GL.ALPHA_TEST);
            GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);


		    GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);

			GL.projectionMatrix = mat4f.identity;
			GL.modelviewMatrix = mat4f.scale(1.f / ratio, 1.f, 1.f);

			void border(double a, double b, vec4f ca, vec4f cb)
			{
			    ca.xyz = ca.xyz * 1.5f;
			    cb.xyz = cb.xyz * 1.5f;
                vec2f aa = vec2f(-ratio + a, -1.f + a);
                vec2f ab = vec2f(+ratio - a, -1.f + a);
                vec2f ac = vec2f(+ratio - a, +1.f - a);
                vec2f ad = vec2f(-ratio + a, +1.f - a);
                vec2f ba = vec2f(-ratio + b, -1.f + b);
                vec2f bb = vec2f(+ratio - b, -1.f + b);
                vec2f bc = vec2f(+ratio - b, +1.f - b);
                vec2f bd = vec2f(-ratio + b, +1.f - b);
                
                auto smin = m_sceneManager.textures.borders.smin;
				auto tmin = m_sceneManager.textures.borders.tmin;
				auto smax = m_sceneManager.textures.borders.smax;
				auto tmax = m_sceneManager.textures.borders.tmax;

                void vertex(vec2f v)
                {
                    GL.vertex(v);
                    GL.texCoord(0, v.x * 0.5f, v.y * 0.5f); // texture is square, no worry
                }

                GL.begin(GL.QUAD_STRIP);
                    GL.color = ca;
                    vertex(aa);
                    GL.color = cb;
                    vertex(ba);

                    GL.color = ca;
                    vertex(ab);
                    GL.color = cb;
                    vertex(bb);

                    GL.color = ca;
                    vertex(ac);
                    GL.color = cb;
                    vertex(bc);

                    GL.color = ca;
                    vertex(ad);
                    GL.color = cb;
                    vertex(bd);

                    GL.color = ca;
                    vertex(aa);
                    GL.color = cb;
                    vertex(ba);
                GL.end();

                auto cbt = vec4f(cb.xyz, 0.f);

                GL.begin(GL.TRIANGLES);

                    GL.color = cb;
                    vertex(ba);
                    GL.color = cbt;
                    auto S = b + 0.115f;
                    vertex(vec2f(-ratio + S, -1.f + b));
                    vertex(vec2f(-ratio + b , -1.f + S));

                    GL.color = cb;
                    vertex(bb);
                    GL.color = cbt;
                    vertex(vec2f(+ratio - S, -1.f + b));
                    vertex(vec2f(+ratio - b , -1.f + S));

                    GL.color = cb;
                    vertex(bc);
                    GL.color = cbt;
                    vertex(vec2f(+ratio - S, +1.f - b));
                    vertex(vec2f(+ratio - b , +1.f - S));

                    GL.color = cb;
                    vertex(bd);
                    GL.color = cbt;
                    vertex(vec2f(-ratio + S, +1.f - b));
                    vertex(vec2f(-ratio + b , +1.f - S));
                GL.end();
			}

			Shader shader = m_sceneManager.shaderPool.getBlitShader();
			shader.use();
            shader.setSampler("tex", m_sceneManager.textures.borders);

            vec4f tsp = vec4f(PLAYER_COLOR[m_index].xyz, 0.f);
            vec4f bblack = vec4f(0.f,0.f,0.f,1.f);
            vec4f pc = vec4f(PLAYER_COLOR[m_index].xyz, transition);
            vec4f white = vec4f(1.0f,1.0f,1.0f, transition);

            border(0, 0.02, bblack, pc);
            border(0.02, 0.04, pc, white);
            border(0.04, 0.06, white, pc);
            border(0.06, 0.08, pc, tsp);
        }
    }
}


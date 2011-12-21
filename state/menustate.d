module state.menustate;

import state.state;
public
{
    import state.menuitem;
}
import gamecontext;
import bitmapfont;
import math.all;
import gl.all;
import res.textures;
import misc.logger;
import state.monster;
import sdl.state;
import sound;

final class MenuState : State
{
	private
	{
		MenuItem[] m_items;
		int m_currentChoice = 0;
		Random random;
		char[] m_title;

		Monster monster[3];
		Shader m_putShader;//, m_blitSRGBShader;
		Texture2D m_eyeTexture;
	}

	public
	{
		this(char[] title, GameContext gameContext, MenuItem[] items)
		{
		    super(gameContext);

			m_items = items;
			m_title = title;

			m_eyeTexture = textures.eye;

			random = Random();

            monster[0] = new Monster(gameContext, Monster.Which.LEFT, textures.lefti, vec2f(-0.89, 0.2), 0.7f);
            monster[1] = new Monster(gameContext, Monster.Which.BOTTOM, textures.bottomi, vec2f(-0.1,-0.70), 0.4f);
            monster[2] = new Monster(gameContext, Monster.Which.RIGHT, textures.righti, vec2f(+0.9, 0.1), 0.6f);           
		}

		static float monsterCome = 0.f;
    
		string getText(int i)
		{
		    string s = m_items[i].text;
		    
		    if (items[i].action !is null)
		    {
				if ((i == m_currentChoice) && (items[i].enabled))
				{
					s = "< " ~ s ~ " >";
				}
			}
		    return s;
		}
		
		float getSizeFactor(int i)
		{
		    return m_items[i].sizeFactor;
		}
		
		vec2f posTitle()
		{
		    return vec2f(0, 0.8f);
		}

		vec2f posText(int i)
		{
			float totalLength = 0;
			float y = 0.f;
			// assumes at least one item
			for (int j = 0; j < m_items.length; ++j)
			{
				float s = 0.2f * getSizeFactor(i);
				if (j < i) y += s;
				totalLength += s;				
			}
			
		    return vec2f(0, 0.1f + totalLength * mix(+0.5f, -0.5f, y / totalLength));
		}

		box2f getItemBounds(int i)
		{
		    string s = getText(i); //m_items[i].text;

            vec2f c = posText(i);
            vec2f si = font.getStringSize(s, 0.2f);
            box2f res = box2f(c - si * 0.5f, c + si * 0.5f);
            return res;
		}

        override void draw(double elapsedTime, float transition)
        {
            GL.viewport = viewport;
            monsterCome = max(transition, monsterCome);

			GL.projectionMatrix = mat4f.scale(1.f / gameContext.viewport.ratio, 1.f, 1.f);
			GL.modelviewMatrix = mat4f.scale(1.0);

            GL.enable(GL.BLEND, GL.ALPHA_TEST);
            GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);

            GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);


            float hohoho = (1.f - monsterCome);

            monster[0].draw(transition, monsterCome);
            monster[1].draw(transition, monsterCome);
            monster[2].draw(transition, monsterCome);

            auto YELLOW = vec4f(0.5f, 0.5f, 0.2f,transition);
			auto BEIGE = vec4f(1.0f, 0.33f, 0.2f,transition);

			// title
			{
				vec2f posT = posTitle();
				font.drawString(m_title, posT.x, posT.y, 0.2, vec4f(1.0f, 0.33f, 0.2f,transition));
			}
            
	        for (int i = 0; i < m_items.length; ++i)
	        {
				vec2f posT = posText(i);
				
				vec4f color = void;
				
				if (items[i].action !is null)
				{										
					color = m_currentChoice == i ? YELLOW : vec4f(1.0, 0.5, 0.5, transition);
				}				
				else
				{
					color = vec4f(1.5 + 0.5 * -1.f, 0.5 * 0.44f, 0.f, transition);
				}
				
				if(!items[i].enabled)
				{
					color = vec4f(0.3f, 0.3f, 0.3f, transition);	
				}
				
				font.drawString(getText(i), posT.x, posT.y, 0.2 * getSizeFactor(i), color);
	        }
	        
	        drawMouse(transition);

            HFAmount = mixf(HFAmount, 2.5f, transition);
            PPAmount = mixf(PPAmount, 0.5f, transition);
            blurAmount = mixf(blurAmount, 1.0f, transition);
        }

		override void move(double elapsedTime, double dt, float transition)
		{
		    monster[0].move(dt);
            monster[1].move(dt);
            monster[2].move(dt);

		}

		void previousChoice()
		{
			int nextChoice = m_currentChoice - 1;
			if (nextChoice < 0) nextChoice += m_items.length;
			setCurrentChoice(nextChoice);
		}

		void nextChoice()
		{
			int nextChoice = m_currentChoice + 1;
			if (nextChoice >= m_items.length) nextChoice = 0;
			setCurrentChoice(nextChoice);
		}

		void setCurrentChoice(int n)
		{
            if (n !=  m_currentChoice)
            {
				gameContext.soundManager.playSound(FX.MENU);  
            }
            m_currentChoice = n;
		}

		MenuItem currentItem()
		{
		    return m_items[m_currentChoice];
		}

		MenuItem lastItem()
		{
		    return m_items[m_items.length - 1];
		}

		MenuItem[] items()
		{
            return m_items;
		}
		
		void drawMouse(float alpha)
		{
			GL.viewport = gameContext.viewport;
			GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);
			GL.enable(GL.ALPHA_TEST, GL.BLEND);
			
			Shader blit = gameContext.shaderPool.getBlitShader();

			void drawCircle(vec2f where, float radius)
			{
				
				
				blit.use();
            	blit.setSampler("tex", m_eyeTexture);
			
            	GL.begin(GL.QUADS);

                GL.texCoord(0, 0, 0); GL.vertex(where + vec2f(-radius, radius));
                GL.texCoord(0, 0, 1); GL.vertex(where + vec2f(-radius, -radius));
                GL.texCoord(0, 1, 1); GL.vertex(where + vec2f(radius, -radius));
            	GL.texCoord(0, 1, 0); GL.vertex(where + vec2f(radius, radius));
                    
            	GL.end();
			}
			
            GL.projectionMatrix = mat4f.scale(1.f / gameContext.viewport.ratio, 1.f, 1.f);
			GL.modelviewMatrix = mat4f.scale(1.0);
			
		    GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			        GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);
 			        
 			blit.use();
 			
 			Texture2D mouseTex = gameContext.mouseDown ? gameContext.textures.mouse2 : gameContext.textures.mouse1;
            blit.setSampler("tex", mouseTex);
            
            auto ratio = gameContext.viewport.ratio;
            float s = 0.17f;
            
	        vec2f bias = vec2f(0, -s * 0.4);
	        vec2f mpos = (gameContext.mousePos + bias) * vec2f(ratio, 1.f);
            
            GL.begin(GL.QUADS);
            {
	            if (gameContext.mouseDown)
	            {
	                GL.color = vec4f(vec3f(5.f, 5.f, 7.f) * 0.2f, alpha);
	            } 
	            else 
	            {
	                GL.color = vec4f(vec3f(5.f, 5.f, 5.f) * 0.2f, alpha);
	            }
	            
	            GL.texCoord(0, mouseTex.smin, mouseTex.tmax); GL.vertex(mpos + vec2f(-s, -s));
	            GL.texCoord(0, mouseTex.smax, mouseTex.tmax); GL.vertex(mpos + vec2f(+s, -s));
	            GL.texCoord(0, mouseTex.smax, mouseTex.tmin); GL.vertex(mpos + vec2f(+s, +s));
	            GL.texCoord(0, mouseTex.smin, mouseTex.tmin); GL.vertex(mpos + vec2f(-s, +s));
            }
            GL.end;

            // eye
           
            GL.color = vec4f(1.0f, 1.0f, 1.0f, alpha);

            vec2f where2 = mpos + s * vec2f(-0.05,-0.45);
            vec2f vel = gameContext.mouseVel;

            GL.color = vec4f(1.0f, 1.0f, 1.0f, alpha);
            drawCircle(where2, s * 0.10);
            GL.color = vec4f(-0.1f, -0.1f, -0.1f, alpha);
            drawCircle(vel + where2, s * 0.06); 
            GL.disable(GL.BLEND);                  
		}
	}	
}


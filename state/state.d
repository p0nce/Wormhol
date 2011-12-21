module state.state;

import math.all;
import math.vec2;

import gamecontext;
import res.shaderpool;
import gl.all;
import res.textures;
import bitmapfont;
import misc.logger;
import sound;


class State
{
	private
	{
		GameContext m_gameContext;
	}

	protected
	{

		final ShaderPool shaderPool() { return m_gameContext.shaderPool; }
		final Shader getShader(string name) { return shaderPool.getShader(name); }
		final GameContext gameContext() { return m_gameContext; }

		final double ratio() { return m_gameContext.ratio; }

		float blurAmount(float ba)
		{
            return m_gameContext.blurAmount = ba;
		}

		float PPAmount(float ppa)
		{
            return m_gameContext.PPAmount = ppa;
		}

		float HFAmount(float hfa)
		{
            return m_gameContext.HFAmount = hfa;
		}

        float blurAmount()
		{
            return m_gameContext.blurAmount;
		}

		float PPAmount()
		{
            return m_gameContext.PPAmount;
		}

		float HFAmount()
		{
            return m_gameContext.HFAmount;
		}

		vec2f mousePos()
		{
		    return m_gameContext.mousePos;
        }

        Textures textures()
		{
            return m_gameContext.textures;
		}

		BitmapFont font()
		{
            return m_gameContext.font;
		}
		
		SoundManager soundManager()
		{
			return m_gameContext.soundManager;
		}

		box2i viewport()
		{
		    return box2i(0, 0, m_gameContext.width, m_gameContext.height);
        }
	}

	public
	{
		this(GameContext gameContext)
		{
			m_gameContext = gameContext;
		}
		
		abstract void draw(double elapsedTime, float transition);
		abstract void move(double elapsedTime, double dt, float transition);



	}

}

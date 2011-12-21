module gamecontext;

import res.shaderpool;
import res.textures;
import postprocessing;
import math.vec2;
import math.box2;
import bitmapfont;
import misc.logger;
import sound;

/**
 * Game information needed by states.
 */

class GameContext
{
    private
    {
        PostProcessing m_postProcessing;
        vec2i m_size;
        ShaderPool m_shaderPool;
        SoundManager m_soundManager;
        Textures m_textures;
        BitmapFont m_font;
        box2i m_viewport;
        vec2f m_mousePos;
        vec2f m_mouseVel;
        bool m_mouseDown = false;
    }

    public
    {
        this(PostProcessing postProcessing, vec2i size, ShaderPool shaderPool, Textures textures,
             BitmapFont font, box2i viewport, SoundManager soundManager)
        {
            info(">GameContext.this");
            m_postProcessing = postProcessing;
            m_size = size;
            m_shaderPool = shaderPool;
            m_textures = textures;
            m_font = font;
            m_viewport = viewport;
            m_soundManager = soundManager;
            info("<GameContext.this");
        }


        Textures textures() { return m_textures; }

        int width() { return m_size.x; }
        int height() { return m_size.y; }

        float blurAmount(float ba) { return m_postProcessing.blurAmount = ba; }
        float PPAmount(float ppa) { return m_postProcessing.PPAmount = ppa; }
        float HFAmount(float hfa) { return m_postProcessing.HFAmount = hfa; }
        float blurAmount() { return m_postProcessing.blurAmount; }
        float PPAmount() { return m_postProcessing.PPAmount; }
        float HFAmount() { return m_postProcessing.HFAmount; }
        ShaderPool shaderPool() { return m_shaderPool; }
        BitmapFont font() { return m_font; }

        box2i viewport()
        {
            return m_viewport;
        }

        double ratio()
        {
            return m_viewport.width / m_viewport.height;
        }

        bool mouseDown()
        {
            return m_mouseDown;
        }

        bool mouseDown(bool b)
        {
            return m_mouseDown = b;
        }

        vec2f mousePos()
        {
            return m_mousePos;
        }

        vec2f mousePos(vec2f pos)
        {
            return m_mousePos = pos;
        }

        vec2f mouseVel()
        {
            return m_mouseVel;
        }

        vec2f mouseVel(vec2f vel)
        {
            return m_mouseVel = vel;
        }

        SoundManager soundManager()
        {
            return m_soundManager;
        }

    }
}

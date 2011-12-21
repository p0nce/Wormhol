module res.shaderpool;

import gl.all;
import std.string;
import misc.logger;
import res.settings;

final class ShaderPool
{
    private
    {

        Shader[string] m_loadedShaders;

        // utility : load a texture in one line
        static Shader loadShader(string name)
        {
            return new Shader(format("data/shaders/%s.vs", name), format("data/shaders/%s.fs", name));
        }

        Shader m_blitsrgbShader;
        Shader m_blitShader;

        Shader m_putShader;
        Shader m_putSRGBShader;
    }


    public
    {
        this()
        {
            m_blitShader = getShader("blit");
            m_blitsrgbShader = getShader("blitsrgb");
            m_putShader = getShader("put");
            m_putSRGBShader = getShader("putsrgb");
            getShader("font");
            getShader("hvblur");
            getShader("surface");
            getShader("powerup");
            getShader("ball");
            getShader("final");
        }

        Shader getShader(string name) // load a texture and cache it (or use cache instead)
        {
            if (! (name in m_loadedShaders))
            {
                info(format(">load shader %s", name));
                Shader m = loadShader(name);
                m_loadedShaders[name] = m;
                info(format("<load shader %s", name));
            }
            Shader res = m_loadedShaders[name];
            assert(res !is null);
            return res;
        }

        Shader getBlitShader() // load a texture and cache it (or use cache instead)
        {
            if (useHDR && usePostProcessing)
            {
                return m_blitsrgbShader;
            }
            else
            {
                return m_blitShader;
            }
        }

        Shader getPutShader() // load a texture and cache it (or use cache instead)
        {
            if (useHDR && usePostProcessing)
            {
                return m_putSRGBShader;
            }
            else
            {
                return m_putShader;
            }
        }

        void updateShaders()
        {
            string[] names = m_loadedShaders.keys;

            foreach(string name; names)
            {
                m_loadedShaders[name].reload(format("data/shaders/%s.vs", name), format("data/shaders/%s.fs", name));
            }
        }
    }

}

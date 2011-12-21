module postprocessing;

import math.all;
import gl.all;
import res.shaderpool;
import gaussianblur;
import misc.logger;
import sdl.all;

import derelict.opengl.extension.ext.gpu_shader4;

import res.settings;

// Handle the post-processing

final class PostProcessing
{
    private
    {
        box2i m_viewport;

        Shader m_finalShader;

        Texture2D m_mainBuffer;
        float m_blurAmount;
        float m_PPAmount;
        float m_HFAmount;

        GaussianBlur m_gaussianBlur;

        FBO m_defaultFBO;
    }

    public
    {
        this(FBO defaultFBO, ShaderPool shaderPool, Texture2D mainBuffer, box2i viewport)
        {
            info(">PostProcessing.this()");
            m_viewport = viewport;
            m_mainBuffer = mainBuffer;
            m_defaultFBO = defaultFBO;

            try
            {
                if (!EXTGpuShader4.isEnabled)
                {
                    throw new GaussianBlurError("nice blur is not possible on this card, fallback to ugly blur");
                }
                m_gaussianBlur = new GaussianBlur(shaderPool, mainBuffer, 1);
                canBlurQuality = true;
            } catch(GaussianBlurError e)
            {
                m_gaussianBlur = null;
                warn(e.msg);
                blurQuality = false;
                canBlurQuality = false;
            }

            m_blurAmount = 2.f;
            m_PPAmount = 1.f;
            m_HFAmount = 1.5f;

            m_finalShader = shaderPool.getShader("final");

            info("<PostProcessing.this()");

        }

        void HDRchanged()
        {
            if (m_gaussianBlur !is null) m_gaussianBlur.recreateBuffers;
        }

        void render()
        {
            debug(2) crap(">PostProcessing.render");

            GL.disable(GL.DEPTH_TEST, GL.ALPHA_TEST, GL.CULL_FACE, GL.BLEND);


            GL.viewport = box2i(0, 0, m_viewport.width, m_viewport.height);

            bool quality = canBlurQuality && blurQuality;



            if (quality)
            {
                try
                {
                    m_mainBuffer.minFilter = Texture.Filter.LINEAR_MIPMAP_NEAREST;
                    m_mainBuffer.generateMipmaps();
                    m_gaussianBlur.render();
                }
                catch(GaussianBlurError e)
                {
                    warn(e.msg);
                    blurQuality = false;
                    canBlurQuality = false;
                }
            }

            if (!quality)
            {

                m_mainBuffer.generateMipmaps();
                m_mainBuffer.minFilter = Texture.Filter.LINEAR_MIPMAP_NEAREST;
            }

            m_defaultFBO.use();

            GL.viewport = m_viewport;

             GL.disable(GL.DEPTH_TEST, GL.ALPHA_TEST, GL.CULL_FACE, GL.BLEND);

            m_finalShader.use();

            m_finalShader.setSampler("tex", m_mainBuffer);


            Texture2D blurTexture = void;

            if (quality)
            {
                blurTexture = m_gaussianBlur.output;
            }
            else
            {
                blurTexture = m_mainBuffer;
            }

            m_finalShader.setSampler("blurTex", blurTexture);

            m_finalShader.set1f("PPAmount", m_PPAmount);
            m_finalShader.set1f("HFAmount", m_HFAmount);
            //m_finalShader.set1f("blurbias", m_quality ? 1.f : 1.f);
            m_finalShader.set1f("blurAmount", m_blurAmount);

            float gammaExp = void;
            if (useHDR)
            {
                gammaExp = (1.0f / 2.2f) / GAMMA_VALUES[gammaModifier];
            }
            else
            {
                gammaExp = 1.0f / GAMMA_VALUES[gammaModifier];
            }

            m_finalShader.set1f("gammaExp", gammaExp);



            float ratio = m_viewport.width / cast(float)(m_viewport.height);
            GL.projectionMatrix = mat4f.identity;
            GL.modelviewMatrix = mat4f.scale(1.f / ratio, 1.f, 1.f);

            GL.begin(GL.QUADS);
                auto smin = m_mainBuffer.smin;
                auto tmin = m_mainBuffer.tmin;
                auto smax = m_mainBuffer.smax;
                auto tmax = m_mainBuffer.tmax;
                auto smin2 = blurTexture.smin;
                auto tmin2 = blurTexture.tmin;
                auto smax2 = blurTexture.smax;
                auto tmax2 = blurTexture.tmax;

                GL.texCoord(0, smin, tmin);
                GL.texCoord(1, smin2, tmin2);
                GL.vertex(-ratio,-1);
                GL.texCoord(0, smax, tmin);
                GL.texCoord(1, smax2, tmin2);
                GL.vertex(+ratio,-1);
                GL.texCoord(0, smax, tmax);
                GL.texCoord(1, smax2, tmax2);
                GL.vertex(+ratio,+1);
                GL.texCoord(0, smin, tmax);
                GL.texCoord(1, smin2, tmax2);
                GL.vertex(-ratio,+1);
            GL.end();

    //        if (!quality)
    //        {
                m_mainBuffer.minFilter = Texture.Filter.LINEAR;
    //        }

            debug(2) crap("<PostProcessing.render");
        }


        float blurAmount(float ba) { return m_blurAmount = ba; }
        float PPAmount(float ppa) { return m_PPAmount = ppa; }
        float HFAmount(float hfa) { return m_HFAmount = hfa; }

        float blurAmount() { return m_blurAmount; }
        float PPAmount() { return m_PPAmount; }
        float HFAmount() { return m_HFAmount; }
    }
}


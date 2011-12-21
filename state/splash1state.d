module state.splash1state;

import state.state;
import gamecontext;
import gl.all;
import math.all;
import res.textures;
import misc.logger;
import state.eye;
import res.settings;

final class Splash1State : State
{
    private
    {
        Texture2D m_logo, m_eyeTex;
        double a = 0;

        void drawCircle(Shader blit, vec2f where, float radius)
        {
            blit.use();
            blit.setSampler("tex", m_eyeTex);

            GL.begin(GL.QUADS);

                GL.texCoord(0, 0, 0); GL.vertex(where + vec2f(-radius, radius));
                GL.texCoord(0, 0, 1); GL.vertex(where + vec2f(-radius, -radius));
                GL.texCoord(0, 1, 1); GL.vertex(where + vec2f(radius, -radius));
                GL.texCoord(0, 1, 0); GL.vertex(where + vec2f(radius, radius));

            GL.end();
        }

        Eye[2] m_eye;
    }

    public
    {
        this(GameContext gameContext)
        {
            super(gameContext);

            m_eyeTex = textures.eye;


            m_logo = textures.wormholLogo;

            m_eye[0] = new Eye(gameContext, vec2f(-0.165f, 0.202f), 0.045f);
            m_eye[1] = new Eye(gameContext, vec2f(-0.205f, 0.195f), 0.045f, m_eye[0]);

        }

        override void draw(double elapsedTime, float transition)
        {
            auto lratio = m_logo.ratio;
            GL.viewport = viewport;

            GL.projectionMatrix = mat4f.scale(1.f / gameContext.viewport.ratio, 1.f, 1.f);
            GL.modelviewMatrix = mat4f.scale(1.0);
            GL.enable(GL.BLEND, GL.ALPHA_TEST);
            GL.disable(GL.DEPTH_TEST);
            GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
                         GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);



            double event1 = mixd(0.03, 1.0, smoothStepd(0.25, 0.5, elapsedTime));
            double event2 = smoothStepd(0.4, 0.6, elapsedTime);
            double event3 = smoothStepd(0.5, 1.0, elapsedTime);
    //        if (!hdr) transition *= event3;

            auto a = (lratio < ratio) ? lratio * ratio : 1.f;
            auto b = (lratio < ratio) ? 1.f * ratio : 1 / lratio;



            a *= sqr(event1) * transition;
            b *= sqr(event2) * transition;

            Shader blit = gameContext.shaderPool.getBlitShader();

            {

                blit.use();
                blit.setSampler("tex", m_logo);

                GL.begin(GL.QUADS);
                    GL.color = vec4f(vec3f(0.95f, 0.95f, 0.95f) * 0.7f, 1.f);

                    GL.texCoord(0, m_logo.smin, m_logo.tmin); GL.vertex(-a, +b);
                    GL.texCoord(0, m_logo.smax, m_logo.tmin); GL.vertex(+a, +b);
                    GL.texCoord(0, m_logo.smax, m_logo.tmax); GL.vertex(+a, -b);
                    GL.texCoord(0, m_logo.smin, m_logo.tmax); GL.vertex(-a, -b);
                    GL.color = vec4f(0.0f, 0.0f, 0.0f, transition);
                    GL.texCoord(0, m_logo.smin, m_logo.tmin); GL.vertex(-a * 1.1f - 0.2, -b * 1.1f- 0.3);
                    GL.texCoord(0, m_logo.smax, m_logo.tmin); GL.vertex(+a * 1.1f + 0.2, -b * 1.1f - 0.3);
                    GL.color = vec4f(0.05f, 0.05f, 0.05f, transition);
                    GL.texCoord(0, m_logo.smax, m_logo.tmax); GL.vertex(+a, -b - 0.1);
                    GL.texCoord(0, m_logo.smin, m_logo.tmax); GL.vertex(-a, -b - 0.1);
                GL.end();
            }

    //        GL.enable(GL.POLYGON_SMOOTH);


            vec2f where2 = vec2f(-a * 0.165, b * 0.202);

            GL.color = vec4f(0.f, 0.f, 0.f, transition);
            drawCircle(blit, where2, b * 0.060f);

            float fear = amplifyN(0.75 + sin(elapsedTime * 2.3) + sin(elapsedTime * 1.f), 10);
            fear = 0.5f + 0.5f * fear;

            if (elapsedTime > 1.5)
            {
                GL.color = vec4f(1.f, 1.f, 1.f, transition);
                drawCircle(blit, where2, b * 0.032f);
            }

            vec2f where1 = vec2f(-a * 0.205, b * 0.195);

            GL.color = vec4f(0.f, 0.f, 0.f, transition);
            drawCircle(blit, where1, b * 0.060f);

            if (elapsedTime > 1.5)
            {
                GL.color = vec4f(1.f, 1.f, 1.f, transition);
                drawCircle(blit, where1, b * 0.032f);
            }

            m_eye[0].draw(vec2f(0.f, 0.f), vec2f(a, b), transition);
            m_eye[1].draw(vec2f(0.f, 0.f), vec2f(a, b), transition);

       //     GL.disable(GL.POLYGON_SMOOTH);


          /*  if (hdr)
            {
                HFAmount = mixf(-1.f, 4.5f, event3);
            }
            else
            {
            */    HFAmount = mixf(0.5f, 4.5f, event3);
           // }
            PPAmount = mixf(2.f, 0.3f, event3);
            blurAmount = 1 + pulsed(1.5, 2.5, elapsedTime) * 5.0 * sqr(1.0 - stepd(1.5, 2.5, elapsedTime));

        }

        override void move(double elapsedTime, double dt, float transition)
        {
            m_eye[0].move(dt);
            m_eye[1].move(dt);

            a += dt;
        }
    }


}

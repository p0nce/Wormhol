module scene.particlesystem;

import gl.all;
import scene.particle;
import math.all;
import misc.logger;
import res.shaderpool;

final class ParticleSystem
{
    private
    {
        Texture2D m_pointTexture;
        ShaderPool m_shaderPool;

        Particle[] m_particles;
        int m_count;
        float m_viscosity_force;
        Random m_random;
    }

    public
    {
        this(int maxParticle, ShaderPool shaderPool, Texture2D texture)
        {
            m_pointTexture = texture;

            m_particles.length = maxParticle;
            m_count = 0;
            m_shaderPool = shaderPool;

            m_viscosity_force = 1.f;

            m_random = Random();
        }

        float viscosityForce() { return m_viscosity_force; }
        float viscosityForce(float f) { return m_viscosity_force = f; }

        void addParticle(vec3f pos, vec3f mov, vec3f color, float life)
        {
            if (m_count < m_particles.length)
            {
                if (m_count * 2 > m_particles.length)
                {
                    if (m_random.nextBool()) return;
                }
                m_particles[m_count++] = Particle(pos, mov, color, life);
            }
        }

        void draw(float pointSizeInPixels, float globalAlpha = 1.f)
        {

            GL.pointSize = pointSizeInPixels;

            Shader shader = m_shaderPool.getPutShader();


            GL.enable(GL.BLEND);
            GL.enable(GL.POINT_SMOOTH);
            GL.hint(GL.POINT_SMOOTH_HINT, GL.NICEST);
            GL.alphaFunc(GL.GREATER, 0.05f);

            GL.begin(GL.POINTS);
            for (int i    = 0; i < m_count; ++i)
            {
                m_particles[i].draw(globalAlpha);
            }
            GL.end();

        }

        void move(float dt)
        {
            auto visco_factor = exp(-dt * m_viscosity_force);

            for (int i    = 0; i < m_count; ++i)
            {
                m_particles[i].move(dt, visco_factor);
            }
            cleanDeadParticles();

        }

        void cleanDeadParticles()
        {
            int i = 0;
            while (i < m_count)
            {
                if (m_particles[i].isDead())
                {
                    m_particles[i] = m_particles[--m_count];
                }
                else
                {
                    i++;
                }
            }

        }
    }
}


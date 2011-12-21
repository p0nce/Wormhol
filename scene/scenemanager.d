module scene.scenemanager;


import scene.gameobject;
import scene.octree;
import scene.surface;
import scene.player;
import scene.powerup;

import math.all;
import res.shaderpool;
import res.textures, res.settings;
import misc.logger;
import gl.all;
import sound;
import scene.particlesystem;
import gamecontext;
final class SceneManager
{

    private
    {
        const MAX_POWERUPS = 100;

        //GameObject[] m_objects; // all objects
        Octree m_octree;
        ShaderPool m_shaderPool;
        SoundManager m_soundManager;
        ParticleSystem m_particleSystem;
        Textures m_textures;
        Surface[] m_surfaces;
        Player[] m_players;
        Powerup[] m_powerups;
        int n_powerups;

        box3f m_allSurfacesBoundingBox;
        Random random;
        GameContext m_gameContext;


    }


    public
    {
        this(GameContext gameContext, /*ShaderPool shaderPool, SoundManager soundManager, Textures textures,*/ int nPlayers, int nIA)
        {
            m_octree = new Octree(vec3f(0), 10);
            m_shaderPool = gameContext.shaderPool;
            m_soundManager = gameContext.soundManager;
            m_gameContext = gameContext;
            m_textures = gameContext.textures;

            m_powerups.length = MAX_POWERUPS;

            for (int i = 0; i < MAX_POWERUPS; ++i)
            {
                m_powerups[i] = new Powerup(this);
            }
            n_powerups = 0;

            random = Random();

            m_particleSystem = new ParticleSystem(1000, shaderPool, textures.eye);
        }

        void addSurface(Surface s)
        {
            m_surfaces ~= s;
            s.recomputeBoundingBox();
            m_allSurfacesBoundingBox = allSurfacesBoundingBox();
        }


        void addPlayer(Player p)
        {
            m_players ~= p;
            //p.recomputeBoundingBox();
        }

        void addPowerup()
        {
            if (n_powerups >= MAX_POWERUPS) return;

            vec3f posi, right, front, up;
            randomPosition(Powerup.RADIUS, posi, right, front, up);
            m_powerups[n_powerups].renew(posi, up, front, right);
            n_powerups++;

        }

        SoundManager soundManager()
        {
            return m_soundManager;
        }

        void deletePowerup(int n)
        {
            assert(n >= 0);
            assert(n < n_powerups);
            assert(n_powerups > 0);

            swap(m_powerups[n], m_powerups[n_powerups - 1]);
            m_powerups[n_powerups - 1].die();
            n_powerups--;
        }

       /*
        void cleanPowerups() // delete dead powerups
        {
            int i = 0;
            for (int j = 0; j < MAX_POWERUPS; ++j)
            {
                if (m_powerups[j].alive)
                {
                    swap(m_powerups[i] = m_powerups[j];
                    i++;
                }
                else m_
            }

            n_powerups = i;
        }
*/
        void move(double t, double dt)
        {
            // add powerups

            box3f bb = m_allSurfacesBoundingBox.enlarge(0.1f);
            float worldVolume = powf(bb.width * bb.height * bb.depth, 2.f / 3.f);
            int desiredPowerups = 5 + round(0.5 * worldVolume);
            if (n_powerups < desiredPowerups ) addPowerup();

            // move powerups

            for (int i = 0; i < n_powerups; ++i)
            {
                m_powerups[i].move(dt);
            }


            foreach (Player p; m_players)
            {
                p.move(t, dt);
            }

            foreach (Player p; m_players)
            {
                p.recomputeBoundingBox;
            }

            foreach (Player p; m_players)
            {
                p.move2(t, dt);
            }

            m_particleSystem.move(dt);

            setWinner(); // set winner and loser flag



//            cleanPowerups();
        }

        void render(double t, mat4f cameraMatrix, mat4f cameraMatrixInverse)
        {
            m_shaderPool.getShader("surface").setMat4f("invCameraMatrix", cameraMatrixInverse);//.transposed);

            GL.enable(GL.DEPTH_TEST, GL.CULL_FACE);
            GL.disable(GL.BLEND, GL.ALPHA_TEST);
            GL.depthFunc(GL.LEQUAL);

            foreach(Surface s; m_surfaces) s.render(t);

            // render particles
            m_particleSystem.draw(10.f * m_gameContext.width / 1024.f);

            // draw powerups
            {
                Shader shader = m_shaderPool.getShader("powerup");
                bool isRGBLinear = useHDR && usePostProcessing;
                shader.set1b("isRGBLinear", isRGBLinear);
                shader.use();

                // draw powerups
                for (int i = 0; i < n_powerups; ++i)
                {
                    assert(m_powerups[i].alive);
                    m_powerups[i].render(t);
                   }
            }

            foreach(Player p; m_players) p.render(t);

            // render rays (debug)
            // to show surfaces normals
           /*
            debug
            {
                Random random = Random(4);
                m_shaderPool.getPutShader().use;
                GL.begin(GL.LINES);
                GL.color = vec4f(1,0,0,1);

                for (int i = 0; i < 1000; ++i)
                {

                    vec3f orig = random.nextGauss3f() * 10.f;
                    vec3f dest = random.nextGauss3f() * 3.f;

                    rayf r = rayf(orig, (dest-orig).normalized);
                    float d;
                    vec3f p, n;
                    if (null !is hitSurface(r, d, p, n))
                    {
                        GL.vertex(p, p + n * 0.2f);
                    }
                }

                GL.end();
            }
            */


            // render all scene bounding box

            /*
            {
                m_shaderPool.getPutShader().use;
                GL.color = vec4f(5, 0, 0, 1);
                box3f bb = m_allSurfacesBoundingBox.enlarge(0.3f);
                GL.begin(GL.LINES);
                    GL.vertex(bb.xyz);
                    GL.vertex(bb.xyZ);
                    GL.vertex(bb.xYz);
                    GL.vertex(bb.xYZ);
                    GL.vertex(bb.Xyz);
                    GL.vertex(bb.XyZ);
                    GL.vertex(bb.XYz);
                    GL.vertex(bb.XYZ);
                    GL.vertex(bb.xyz);
                    GL.vertex(bb.Xyz);
                    GL.vertex(bb.xYz);
                    GL.vertex(bb.XYz);
                    GL.vertex(bb.xyZ);
                    GL.vertex(bb.XyZ);
                    GL.vertex(bb.xYZ);
                    GL.vertex(bb.XYZ);
                    GL.vertex(bb.xyz);
                    GL.vertex(bb.xYz);
                    GL.vertex(bb.xyZ);
                    GL.vertex(bb.xYZ);
                    GL.vertex(bb.Xyz);
                    GL.vertex(bb.XYz);
                    GL.vertex(bb.XyZ);
                    GL.vertex(bb.XYZ);

                GL.end();
            }

            */
        }

        ShaderPool shaderPool()
        {
            return m_shaderPool;
        }

        Textures textures()
        {
            return m_textures;
        }

        /**
         * Cast a ray, return the intersected GameObject (or null)
         */
        Surface hitSurface(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            // TODO use octree ? AABB ?

            Surface bestFit = null;
            distance = float.infinity;

            foreach(Surface s; m_surfaces)
            {
                float d;
                vec3f p, n;

                if (s.hit(r, d, p, n))
                {
                    if (d < distance)
                    {
                        distance = d;
                        point = p;
                        normal = n;
                        bestFit = s;
                    }
                }
            }

            return bestFit;
        }

        bool hitsSurface(rayf r, float limit)
        {
            vec3f point = void;
            vec3f normal = void;
            float distance = void;
            Surface s = hitSurface(r, distance, point, normal);
            return (s !is null) && (distance < limit);
        }

        Player player(int i)
        {
            return m_players[i];
        }

        Player[] players()
        {
            return m_players;
        }

        int alivePlayers()
        {
             int res = 0;
             foreach (Player p; m_players)
             {
                 //if (p.isAlive()) res++;
                 if (p.count() > 0) res++;
             }
             return res;
        }


        void setWinner()
        {
            int alive = alivePlayers();
            // null if no winner
            if (alivePlayers() <= 1)
            {
                foreach (Player p; m_players)
                {
                    if (p.isAlive)
                    {
                        p.winner = true;
                    }
                    else
                    {
                        if (!p.winner)
                        {
                            p.loser = true;
                        }
                    }
                }
            }
        }


        Surface[] surface()
        {
            return m_surfaces;
        }

        Powerup powerup(int i)
        {
            return m_powerups[i];
        }

        int powerupsCount()
        {
            return n_powerups;
        }

        box3f allSurfacesBoundingBox()
        {
            assert(m_surfaces.length > 0); // at least one surface...

            box3f res = m_surfaces[0].boundingBoxParent();

            for (int i = 1; i < m_surfaces.length; ++i)
            {
                res = res.combine(m_surfaces[i].boundingBoxParent());
            }

            return res;
        }

        void addParticle(vec3f pos, vec3f mov, vec3f color, float life)
        {
             m_particleSystem.addParticle(pos, mov, color, life);
        }

        // find a random place for something of a given radius, just above a surface
        void randomPosition(float radius, out vec3f pos, out vec3f right, out vec3f front, out vec3f up)
        {
            box3f bb = m_allSurfacesBoundingBox.enlarge(radius + 1e-3);

            void randomPosDir(out vec3f pos, out vec3f dir)
            {
                float u = random.nextFloat;
                float v = random.nextFloat;
                int r = random.nextRange(0, 6);
                assert(r >= 0);
                assert(r < 6);

                float xf, yf, zf;
                switch(r)
                {
                    case 0: xf = 0; yf = u; zf = v; break;
                    case 1: xf = 1; yf = u; zf = v; break;
                    case 2: xf = v; yf = 0; zf = u; break;
                    case 3: xf = v; yf = 1; zf = u; break;
                    case 4: xf = u; yf = v; zf = 0; break;
                    case 5:
                    default: xf = u; yf = v; zf = 1; break;
                }

                pos = vec3f(mix(bb.xmin, bb.xmax, xf), mix(bb.ymin, bb.ymax, yf), mix(bb.zmin, bb.zmax, zf));

                vec3f bias = vec3f(0.5f - xf, 0.5f - yf, 0.5f - zf);

                dir = bias + vec3f(random.nextFloat2, random.nextFloat2, random.nextFloat2);
                if (dir.length != 0) dir.normalize();
            }

            bool suitablePosition(vec3f pos, float radius)
            {
                for (int k = 0; k <= 7; ++k)
                {
                    for (int j = 0; j < 8; ++j)
                    {
                        float theta = PI_F * (-0.5f + 1.f) * (k / 7.f);
                        float phi = TWO_PI_F * j / 8.f;

                        vec3f dir = sphereMap(theta, phi);
                        vec3f normal, impact;
                        float distance;
                        rayf ra = rayf(pos, dir);

                        Surface s = hitSurface(ra, distance, impact, normal);

                        if (s !is null)
                        {
                            if (distance < radius)
                            {
                                return false; // unproper position
                            }
                        }
                    }
                }
                return true;

            }


            while(true) //for (int i = 0; i < 500; ++i)
            {
                vec3f randStart;
                vec3f randDir;
                randomPosDir(randStart, randDir);
                rayf randRay = rayf(randStart, randDir);

                vec3f p, n;
                float d;
                Surface s = hitSurface(randRay, d, p, n);
                if (s is null)
                {
                }
                else if ( suitablePosition(p + n * (radius + 1e-4), radius - 1e-4) )
                {
                    pos = p + n * (radius + 1e-4f);
                    up = n;
                    front = random.nextPerpendicularVec3f(n).normalized();
                    right = vec3f.cross(front, up);
                    return;
                }
            }
        /*
            warn("Incorrect starting position");
            // incorrect, i'm sorry
            pos = randomOutPos();
            front = -pos.normalized(); // towards (0, 0, 0)
            up = random.nextPerpendicularVec3f(front).normalized();
            right = vec3f.cross(front, up);
            return;*/
        }
    }
}

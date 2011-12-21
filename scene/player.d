module scene.player;

import math.all;
import scene.gameobject;
import scene.scenemanager;
import scene.spheregeometry;
import scene.powerup;
import gl.all;
import scene.playerpart;
import misc.logger;
import scene.surface;
import sdl.all;
import res.settings;
import sound;

final class Player : GameObject
{

    private
    {
        Shader m_shader;

        enum PlayerState
        {
            ALIVE, DEAD
        }

        PlayerState m_state;

        const int MAX_PARTS = 2048;
        const int MAX_PARTS_MASK = 2047;

        int m_partCount;
        int m_index;
        int m_toExtend;

        double m_stepAccum;
        float m_timeAccum;

        const STEP_DELAY = 0.025;
        const DESTROY_DELAY = 0.025;
        const STEP_SIZE = 0.02;

        float m_turn;

        float m_turnAmountSmoothed = 0.f;

        float m_speed = 0.01;

        PlayerPart[] m_parts; // circular buffer
        int n_parts_start = 0; // indexes
        int n_parts_stop = 0;


        SphereGeometry m_eye;
        bool m_winner = false;
        bool m_loser = false;

        Random m_random;

        void pushLast(PlayerPart part)
        {
            int nextIndex = (n_parts_stop + 1) & MAX_PARTS_MASK;
            if (nextIndex == n_parts_start) return; // full, do not push further

            m_parts[nextIndex] = part;
            n_parts_stop = nextIndex;
        }

        PlayerPart popLast()
        {
            assert(n_parts_start !is n_parts_stop);   // empty !
            int lastIndex = (n_parts_stop - 1 + MAX_PARTS) & MAX_PARTS_MASK;
            n_parts_stop = lastIndex;
            return m_parts[lastIndex];
        }

        void pushFront(PlayerPart part)
        {
            int previousIndex = (n_parts_start - 1 + MAX_PARTS) & MAX_PARTS_MASK;
            assert(previousIndex !is n_parts_stop); // full, should not happen (pop last first !)
            n_parts_start = previousIndex;
            m_parts[previousIndex] = part;
        }

        PlayerPart popFront()
        {
            assert(n_parts_start !is n_parts_stop);   // empty !
            int nextIndex = (n_parts_start + 1) & MAX_PARTS_MASK;
            PlayerPart res = m_parts[n_parts_start];
            n_parts_start = nextIndex;
            return res;
        }
    }

    public
    {
        this(SceneManager manager, int index )
        {
            super(manager);

            m_index = index;
            m_stepAccum = 0.0;
            m_state = PlayerState.ALIVE;
            m_parts.length = MAX_PARTS;

            vec3f pos;// = vec3f(0, 1 + PlayerPart.RADIUS, 0.f);
            vec3f up;// = vec3f(0, 1, 0.f);
            vec3f right;// = vec3f(1, 0, 0.f);
            vec3f front;// = vec3f(0, 0, -1.f);

            manager.randomPosition(PlayerPart.RADIUS, pos, right, front, up);

            m_state = PlayerState.ALIVE;
            m_toExtend = 4;
            m_turn = 0.f;
//            m_speedBoost = 0.f;

            pushFront(PlayerPart(pos, right, up, front));

            m_random = Random();

            m_eye = new SphereGeometry(7, 12, 1.f, true);
        }

        // number of PlayerPart in the circular buffer
        int count()
        {
            return ((n_parts_stop - n_parts_start) + MAX_PARTS) & MAX_PARTS_MASK;
        }

        bool winner() { return m_winner; }
        bool winner(bool b) { return m_winner = b; }

        bool loser() { return m_loser; }
        bool loser(bool b) { return m_loser = b; }

        PlayerPart* head()
        {
            if (n_parts_stop is n_parts_start) assert(false); // makes no sense

            return &m_parts[n_parts_start];
        }

        PlayerPart* part(int i)
        {
            assert(i >= 0);
            assert(i < count());

            return &m_parts[(n_parts_start + i) & MAX_PARTS_MASK];
        }

        override bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            return false;
        }

        override void doRender(double t)
        {
            // draw body

            Shader shader = manager.shaderPool.getShader("ball");

            bool isRGBLinear = useHDR && usePostProcessing;
            shader.set1b("isRGBLinear", isRGBLinear);

            GL.color = PLAYER_COLOR[m_index] * 1.2f;

            int nparts = count();
            for (int i = 0; i < nparts; i += 2)
            {
                PlayerPart* p = part(i);
                GL.pushMatrix;
                GL.translate(p.pos);
                p.render(t);
                GL.popMatrix;
            }

            if (isAlive()) drawEyes();

            // debug: draw axis
            /*
            GL.begin(GL.LINES);

            for (int i = 0; i < count(); i ++)
            {
                PlayerPart * p = part(i);
                GL.color = vec3f(1.f, 0.f, 0.f);
                GL.vertex(p.pos, p.pos + p.up * 0.2f);
                GL.color = vec3f(0.f, 1.f, 0.f);
                GL.vertex(p.pos, p.pos + p.right * 0.2f);
                GL.color = vec3f(0.f, 0.f, 1.f);
                GL.vertex(p.pos, p.pos + p.front * 0.2f);
            }

            GL.end();
            */
        }

         const int NRAY = 64;


        float getAngle(int i)
        {
            return PI_F * (-0.499f + (0.998f * i) / (NRAY - 1));
        }

        float getTurnAmount()
        {
            float res = 0.f;
            if (SDL.instance.keyboard.isPressed(playerLeftKey[m_index])) res -= 1.f;
            if (SDL.instance.keyboard.isPressed(playerRightKey[m_index])) res += 1.f;
            return res;
        }

        bool suitablePosition(vec3f pos, out vec3f outNormal)
        {

            float minDistance = float.infinity;

            bool inSpace = true;

            for (int k = 0; k <= 9; ++k)
            {
                for (int j = 0; j < 8; ++j)
                {
                    float theta = PI_F * (-0.5f + 1.f) * (k / 9.f);
                    float phi = TWO_PI_F * j / 8.f;

                    vec3f dir = sphereMap(theta, phi);
                    vec3f normal, impact;
                    float distance;
                    rayf ra = rayf(pos, dir);

                    Surface s = manager.hitSurface(ra, distance, impact, normal);

                    if (s !is null)
                    {
                        if (distance < PlayerPart.RADIUS + 1e-4) return false;

                       // if (distance < 1.f * PlayerPart.RADIUS)
                        {
                            inSpace = false;
                            if (distance < minDistance)
                            {
                                minDistance = distance;
                                outNormal = normal;
                            }
                        }
                    }
                }
            }

            return !inSpace;
        }

        void move(double t, double dt)
        {
            m_stepAccum += dt;
            if (m_state == PlayerState.ALIVE)
            {
                assert(count() > 0);

                // searching for a good position and progressing

                //dt *= 0.1;

          //      int count = 0;

                int maxStepRemaining = 10;

                m_turnAmountSmoothed += (getTurnAmount() - m_turnAmountSmoothed) * (1.f - exp(-dt * 20));

                while ((m_stepAccum > STEP_DELAY) && (maxStepRemaining > 0))
                {
                    m_stepAccum -= STEP_DELAY;
                    maxStepRemaining--;

                    // progress speed
                    {
                        if (SDL.instance.keyboard.isPressed(playerLeftKey[m_index]))
                        {
                            m_speed += (STEP_SIZE * 0.65f - m_speed) * (1.f - exp(-STEP_DELAY * 15));
                        }
                        else if (SDL.instance.keyboard.isPressed(playerRightKey[m_index]))
                        {
                            m_speed += (STEP_SIZE * 0.65f - m_speed) * (1.f - exp(-STEP_DELAY * 15));
                        }
                        else
                        {
                            m_speed += (STEP_SIZE * 1.0f - m_speed) * (1.f - exp(-STEP_DELAY * 10));
                        }
                    }

                    // compute step size
                    float thisStepSize = void;
                    {
                        int vsize = maxi(5, count);
                        float expFact = powf(1.1f, -vsize);
                        thisStepSize = m_speed;// * (1.f + 0.4f * expFact * sin(0.4 + t * 0.03 * pow(1.1,  t * 0.03 * expFact)));
                    }

                    // search a suitable place for the new head

                    float phi = -0.15f * getTurnAmount();
                    vec3f rotFront = (cos(phi) * head.front + sin(phi) * head.right).normalized;
                    vec3f rotRight = (cos(phi) * head.right - sin(phi) * head.front).normalized;

                    bool foundSurface = false;
                    vec3f newFront, newUp, newRight, newPos;


                    for (int i = 0; i < NRAY; ++i)
                    {
                        vec3f startRay = head.pos;
                        float theta = getAngle(i);
                        vec3f dir = cos(theta) * rotFront + sin(theta) * head.up;

                        // trivial eviction test, prevent lots of rays
                        if (!manager.hitsSurface(rayf(head.pos, dir), thisStepSize + PlayerPart.RADIUS))
                        {
                            vec3f testPos = head.pos + dir * thisStepSize;
                            vec3f nml = vec3f(0.f);
                            if (suitablePosition(testPos, nml))
                            {
                                newPos = testPos;
                                newFront = (testPos - head.pos).normalized;

                                newRight = rotRight;

                                newUp = nml;
                                newRight = vec3f.cross(newFront, newUp).normalized;
                                newFront = vec3f.cross(newUp, newRight).normalized;
                                newUp = vec3f.cross(newRight, newFront).normalized;

                                foundSurface = true;
                                break;
                            }
                        }
                    }

                    if (!foundSurface) // no Surface ? go down (should not arrive ! but still arrives)
                    {

                        newFront = rotFront;
                        newUp = head.up;
                        newRight = rotRight;
                        newPos = head.pos + thisStepSize * head.front;
                        /*
                        newFront = (rotFront - head.up * 0.3f).normalized;

                        newUp = (head.up + rotFront).normalized;
                        newRight = vec3f.cross(newFront, newUp).normalized;
                        newUp = vec3f.cross(newRight, newFront).normalized;
                        newFront = vec3f.cross(newUp, newRight).normalized;

                        newPos = head.pos + thisStepSize * newFront;
                        */
                    }

                    if (m_toExtend > 0)
                    {
                        m_toExtend--;
                    }
                    else
                    {
                        popLast;
                    }

                    pushFront(PlayerPart(newPos, newRight, newUp, newFront));
                }
            }
            else  // m_state == PlayerState.DEAD
            {
                while (m_stepAccum > DESTROY_DELAY)
                {
                    m_stepAccum -= DESTROY_DELAY;
                    if (count() > 0)
                    {
                        void explosion(vec3f where)
                        {
                            // mandatory particle explosion
                            int nEmitted = 10 + m_random.nextRange(20);
                            for (int j = 0; j < nEmitted; ++j)
                            {
                                vec3f pos = where;
                                vec3f mov = m_random.nextPointOnSpheref() * (sqr(m_random.nextFloat) + 0.1f);
                                vec3f color = PLAYER_COLOR[m_index].xyz * 1.2f;
                                float life = 1.f + sqr(m_random.nextFloat);
                                manager.addParticle(pos, mov, color, life);
                            }
                        }

                        PlayerPart first = popFront();
                        explosion(first.pos);

                        if (count() > 0)
                        {
                            PlayerPart last = popLast();
                            explosion(last.pos);
                        }

                        if (m_random.nextFloat < 0.2f)
                        {
                            manager.soundManager.playSound(FX.EXPLODE);
                        }
                    }
                }
            }
        }

        void die()
        {
            m_state = PlayerState.DEAD;
            if (!winner)
            {
                loser = true;
            }
        }

        bool isAlive()
        {
            return m_state != PlayerState.DEAD;
        }

        void move2(double t, double dt)
        {
            if (m_state == PlayerState.DEAD) return;

            // check collisions with powerups
            int index = 0;
            while (index < manager.powerupsCount())
            {
                Powerup p = manager.powerup(index);
                assert(p.alive);

                if (head.collides(p))
                {
                    manager.deletePowerup(index);

                    if (count() < 8) m_toExtend += 4;
                    else if (count < 10) m_toExtend += 4;
                    else if (count < 13) m_toExtend += 6;
                    else if (count < 16) m_toExtend += 3;
                    else if (count < 22) m_toExtend += 8;
                    else if (count < 27) m_toExtend += 8;
                    else if (count < 32) m_toExtend += 10;
                    else if (count < 42) m_toExtend += 10;
                    else if (count < 53) m_toExtend += 12;
                    else if (count < 64) m_toExtend += 12;
                    else m_toExtend += 14;

                    // sound

                    FX fx = cast(FX) (cast(int)FX.AVALE1 + m_random.nextRange(0, 3));
                    manager.soundManager.playSound(fx);

                    // mandatory particle explosion *
                    int nEmitted = 120 + m_random.nextRange(60);
                    for (int j = 0; j < nEmitted; ++j)
                    {
                        vec3f pos = head.pos;
                        vec3f mov = m_random.nextPointOnSpheref() * (sqr(m_random.nextFloat) + 0.1f);
                        vec3f color = p.color;
                        float life = 1.f + sqr(m_random.nextFloat);

                        manager.addParticle(pos, mov, color, life);
                    }

                    m_speed = STEP_SIZE * 1.8f;
                }
                else
                {
                    index++;
                }
            }

            // check collisions with players
            Player[] players = manager.players;
    /*
            for (int i = 0; i < players.length; ++i)
            {
                if ((players[i] !is this) && (players[i].isAlive()))
                {
                    if (head.collides(players[i].head))
                    {
                        players[i].die();
                    }
                }
            }            */

            // collision with others

            for (int i = 0; i < players.length; ++i)
            {
                if (players[i].isAlive())
                {
                    int start = (players[i] is this) ? 12 : 0;
                    for (int j = start; j < players[i].count(); j += 2)
                    {
                        if (head.collides(players[i].part(j)))
                        {
                            die();
                            manager.soundManager.playSound(FX.DIE);
                            return;
                        }
                    };
                }
            }
        }



        override mat4f matrix()
        {
            return mat4f.identity;
        }

        override void recomputeBoundingBox()
        {
            /+
                assert(m_parts.length > 0);

                head.recomputeBoundingBox();
                box3f res = p.boundingBox() + p.pos;

                for (int i = 1; i < m_parts.length; ++i)
                {
                    m_parts[i].recomputeBoundingBox();
                    PlayerPart pi = part(i);
                    res = res.combine(pi.boundingBox() + pi.pos);
                }
                return res;
                +/
                // TODO
        }

        override mat4f invMatrix()
        {
            return mat4f.identity;
        }

           vec3f pos() { return head.pos; }
        vec3f up() { return head.up; }
        vec3f right() { return head.right; }
        vec3f front() { return head.front; }

        int index()
        {
            return m_index;
        }
    }


    private
    {
         void drawEyes()
        {
            vec3f centerEye2 = head.pos + PlayerPart.RADIUS * (head.up * 0.7f - head.front * 0.1f);
            vec3f eye12 = centerEye2 + PlayerPart.RADIUS * head.right * -0.7f;
            vec3f eye22 = centerEye2 + PlayerPart.RADIUS * head.right * 0.7f;

            GL.pushMatrix();
                GL.translate(eye12);
                GL.scale(vec3f(0.022f));
                m_eye.render();
            GL.popMatrix();
            GL.pushMatrix();
                GL.translate(eye22);
                GL.scale(vec3f(0.022f));
                m_eye.render();
            GL.popMatrix();

            Shader put = manager.shaderPool.getPutShader();
            put.use();

            GL.color = vec4f(1, 1, 1, 1);

            vec3f centerEye = head.pos + PlayerPart.RADIUS * (head.up * 0.7f + head.front * 0.2f);
            vec3f eye1 = centerEye + PlayerPart.RADIUS * head.right * -0.7f;
            vec3f eye2 = centerEye + PlayerPart.RADIUS * head.right * 0.7f;

            GL.pushMatrix();
                GL.translate(eye1);
                GL.scale(vec3f(0.02f));
                m_eye.render();
            GL.popMatrix();
            GL.pushMatrix();
                GL.translate(eye2);
                GL.scale(vec3f(0.02f));
                m_eye.render();
            GL.popMatrix();

            float phi = -1.0f * m_turnAmountSmoothed;
            vec3f rotFront = (cos(phi) * head.front + sin(phi) * head.right);
            vec3f puppil1 = eye1 + rotFront * 0.01f + head.up * 0.002f;
            vec3f puppil2 = eye2 + rotFront * 0.01f + head.up * 0.002f;

            GL.color = vec4f(0, 0, 0, 1);

            GL.pushMatrix();
                GL.translate(puppil1);
                GL.scale(vec3f(0.013f));
                m_eye.render();
            GL.popMatrix();
            GL.pushMatrix();
                GL.translate(puppil2);
                GL.scale(vec3f(0.013f));
                m_eye.render();
            GL.popMatrix();
        }
    }
}

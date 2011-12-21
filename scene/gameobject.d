module scene.gameobject;

import math.all;
import scene.scenemanager;
import gl.all;
import misc.logger;
import res.shaderpool;
import sdl.all;

// GameObjects are game objects

class GameObject
{
    private
    {
        SceneManager m_manager;

    }

    protected
    {
        box3f m_boundingBox;
        debug
        {
            Shader m_BBshader;

            void drawBoundingBox(box3f bb)
            {
                m_manager.shaderPool.getPutShader.use;
                GL.color = vec4f(1, 0, 0, 1);

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
        }
    }

    public
    {
        this(SceneManager manager)
        {
            m_manager = manager;


        }

        /**
         * Matrix that transforms this node to parent space.
         */
        abstract mat4f matrix();

        /**
         * Matrix that transforms parent space to this node space.
         * Can be redefined for good.
         */
        mat4f invMatrix()
        {
            return matrix.inversed();
        }


        final SceneManager manager()
        {
            return m_manager;
        }

        final ShaderPool shaderPool()
        {
            return m_manager.shaderPool;
        }

        final Shader getShader(char[] name)
        {
            return m_manager.shaderPool.getShader(name);
        }

        /**
         * Returns the bounding box in object space.
         */
        final box3f boundingBox()
        {
            return m_boundingBox;
        }

        /**
         * Returns the bounding box in parent space.
         */
        final box3f boundingBoxParent()
        {
            return matrix() * m_boundingBox;
        }

        /**
         * Intersect with a ray in parent space.
         */
        final bool hit(rayf r, out float distance, out vec3f point, out vec3f normal)
        {
            vec3f p, n;
            float d;

            mat4f invModel = invMatrix();

            rayf tranformedRay = r.transform(invModel);

            bool b = doHit(tranformedRay, d, p, n);

            if (!b)
            {
                return false;
            }
            else
            {
                mat4f model = matrix();
                mat4f invModelTr = invModel.transposed();

                // retransform pos in parent space
                vec4f tmp = model * vec4f(p, 1.f);
                // assumes no perspective change
                point = tmp.xyz / tmp.w;

                // world length
                distance = (r.start - point).length;

                vec4f tmp2 = invModelTr * vec4f(n, 0.f);
                normal = tmp2.xyz.normalized; // renormalize
                return true;
            }
        }


        const float A = 1.00000000001f - 1.f;
        static assert(A != 0);


        /**
         * Intersect with a ray in object space.
         */
        abstract bool doHit(rayf r, out float distance, out vec3f point, out vec3f normal);

        /**
         * Render
         */
        abstract void doRender(double t);

        void render(double t)
        {

            debug
            {
    //            drawBoundingBox(boundingBoxParent());
            }

            GL.pushMatrix;
            GL.multMatrix(matrix());


            // render bounding box
            debug
            {
    //            drawBoundingBox(m_boundingBox);
            }

             doRender(t);

            GL.popMatrix;
        }

        // to update the Octree next frame
        abstract void recomputeBoundingBox();
   /*
        {
            for (int i = 0; i < m_childrens.length; ++i)
            {
                m_childrens[i].recomputeBoundingBox();
            }

            m_boundingBox = computeBoundingBox(); // it's up to the object to implement AABB fusion.
        }
        */

    }
}


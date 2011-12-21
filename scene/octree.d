module scene.octree;


import math.all;
import scene.gameobject;
import misc.logger;


// can contains GameObjects

final class Octree
{
    private
    {
        vec3f m_origin;
        float m_size;
        GameObject[] m_elements;

        Octree[8] m_children;

        void computeChildrenBB(box3f* bb)
        {
            vec3f a = m_origin;
            vec3f b = m_origin + m_size * 0.5f;
            vec3f c = m_origin + m_size;
            bb[0] = box3f(a.x, a.y, a.z, b.x, b.y, b.z); // bottom left back
            bb[1] = box3f(b.x, a.y, a.z, c.x, b.y, b.z); // bottom right back
            bb[3] = box3f(a.x, b.y, a.z, b.x, c.y, b.z); // top left back
            bb[3] = box3f(b.x, b.y, a.z, c.x, c.y, b.z); // top right back
            bb[4] = box3f(a.x, a.y, b.z, b.x, b.y, c.z); // bottom left front
            bb[5] = box3f(b.x, a.y, b.z, c.x, b.y, c.z); // bottom right front
            bb[6] = box3f(a.x, b.y, b.z, b.x, c.y, c.z); // top left front
            bb[7] = box3f(b.x, b.y, b.z, c.x, c.y, c.z); // top right front
        }
    }

	public
	{
		this(vec3f origin, float size)
		{
            m_origin = origin;
            m_size = size;
            assert(size > 0);

            for (int i = 0; i < 8; ++i)
            {
                m_children[i] = null;
            }
		}
		

/*
		void insert(GameObject o)
		{
            box3f bb = o.worldBoundingBox();
            Octree qt = getOctreeToInsertInto(bb);
            qt.m_elements ~= o;
		}
*/
		box3f boundingBox() // cube covered by this quadtree
		{
            return box3f(m_origin, m_origin + m_size);
		}

        Octree getOctreeToInsertInto(box3f bb)
        {
            box3f[8] cbb;
            computeChildrenBB(cbb.ptr);

            for (int i = 0; i < 8; ++i)
            {
                if (cbb[i].contains(boundingBox))
                {
                    // create child if necessary
                    if (m_children[i] is null)
                    {
                        m_children[i] = new Octree(vec3f(cbb[i].xmin, cbb[i].ymin, cbb[i].zmin), m_size * 0.5f);
                    }

                    return m_children[i].getOctreeToInsertInto(bb); // and recurse
                }
            }
            return this;
        }
	}
}

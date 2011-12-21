module res.textures;

import misc.singleton;
import gl.all;
import sdl.sdlimage;
import math.all;
import misc.logger;
import res.simplex3;


final class Textures
{
    private
    {
        Texture2D m_wormholLogo;
        Texture2D m_lefti;
        Texture2D m_righti;
        Texture2D m_bottomi;
        Texture2D m_mouse1;
        Texture2D m_mouse2;
        Texture2D m_borders;
        Texture3D m_noise3D;
        Texture2D m_eye;
    }

    public
    {
        this()
        {
	        info(">Textures.this()");
            m_wormholLogo = loadTexture2D("data/gfx/wormhollogo.jpg", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_lefti = loadTexture2D("data/gfx/lefti.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_righti = loadTexture2D("data/gfx/righti.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_bottomi = loadTexture2D("data/gfx/bottomi.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_mouse1 = loadTexture2D("data/gfx/mouse1.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_mouse2 = loadTexture2D("data/gfx/mouse2.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
            m_borders = loadTexture2D("data/gfx/border.jpg", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);
			                       
			m_eye = loadTexture2D("data/gfx/eye.png", Texture.IFormat.RGBA8,
			                       Texture.Filter.LINEAR_MIPMAP_LINEAR, Texture.Filter.LINEAR,
			                       Texture.Wrap.CLAMP_TO_EDGE, true, false, false);			                       
/*
            info(">Creating 3D noise");

            float[] rcoef, gcoef, bcoef;
            const int LEVELS = 6;
            rcoef.length = LEVELS;
            gcoef.length = LEVELS;
            bcoef.length = LEVELS;

            Random random = Random();
            vec3f color = vec3f(0.5f, 0.5f, 0.5f);
            rcoef[0] = color.x;
            gcoef[0] = color.y;
            bcoef[0] = color.z;
            for (int i = 1; i < LEVELS; ++i)
            {
                float r = 1.f * powf(2.f, -(i+1));
                rcoef[i] = color.x * (r * (1 + random.nextGaussf * 0.5f));
                gcoef[i] = color.y * (r * (1 + random.nextGaussf * 0.5f));
                bcoef[i] = color.z * (r * ( 1 + random.nextGaussf * 0.5f));
            }
            //rcoef[1] *= 0.1f;
            gcoef[1] *= 0.1f;
            bcoef[1] *= 0.1f;
            //rcoef[2] *= 0.3f;
            gcoef[2] *= 0.3f;
            bcoef[2] *= 0.3f;
            m_noise3D = create3DTexture(LEVELS, rcoef, gcoef, bcoef, 0.1f * vec3f(0.5f,0.4f,0.05f));
            info("<Creating 3D noise");
            */
            info("<Texture.this()");
        }
        
        // utility : load a texture in one line
        static Texture2D loadTexture2D(char[] filename, Texture.IFormat iFormat, Texture.Filter minfilter, Texture.Filter magfilter, Texture.Wrap wrap,
                                       bool mipmap, bool compress, bool sRGB)
        {
            assert(!sRGB);
            
            scope auto img = new SDLImage(filename);
            
            info(format(">Loading texture %s", filename));
            Texture2D res = new Texture2D(img.width, img.height, iFormat, true, compress, sRGB);
            
            res.minFilter = minfilter;
            res.magFilter = magfilter;
            res.wrapS = wrap;
            res.wrapT = wrap;
            
            img.lock();
            res.setSubImage(0, 0, 0, img.width, img.height, Texture.Format.RGBA, Texture.Type.UBYTE, img.data);
            res.generateMipmaps;
            img.unlock();
            info(format("<Loading texture %s", filename));
            return res;
        }

        Texture2D wormholLogo()
        {
            return m_wormholLogo;
        }

        Texture2D lefti()
        {
            return m_lefti;
        }

        Texture2D righti()
        {
            return m_righti;
        }

        Texture2D bottomi()
        {
            return m_bottomi;
        }

        Texture2D mouse1()
        {
            return m_mouse1;
        }

        Texture2D mouse2()
        {
            return m_mouse2;
        }

        Texture2D borders()
        {
            return m_borders;
        }
        
        Texture2D eye()
        {
            return m_eye;
        }
/*
        Texture3D noise3D()
        {
            return m_noise3D;
        }
 */
    }

    private
    {
        // additive synthesis

        Texture3D create3DTexture(int levels,
                                  float[] rcoef, float[] gcoef, float[] bcoef,
                                  vec3f wnoise)
        {
            assert(levels > 0);
            int size = 1 << levels;

            Texture3D tex = new Texture3D(Texture.IFormat.I8, false, true);
            tex.wrapS = Texture.Wrap.REPEAT;
            tex.wrapT = Texture.Wrap.REPEAT;
            tex.wrapR = Texture.Wrap.REPEAT;
            tex.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
            tex.magFilter = Texture.Filter.LINEAR;

            float[] texData3D;
            texData3D.length = 4 * size * size * size;
            int index = 0;
            Random random = Random();

            // randomize phase
            vec3f[] rphase;
            vec3f[] gphase;
            vec3f[] bphase;
            rphase.length = levels;
            gphase.length = levels;
            bphase.length = levels;
            for (int l = 0; l < levels; ++l)
            {
                rphase[l] = vec3f(random.nextFloat, random.nextFloat, random.nextFloat) * TWO_PI_F;

                gphase[l] = vec3f(random.nextFloat, random.nextFloat, random.nextFloat) * TWO_PI_F;
                bphase[l] = vec3f(random.nextFloat, random.nextFloat, random.nextFloat) * TWO_PI_F;

                // increase coherency
                rphase[l] += (gphase[l] - rphase[l]) * 0.5f;
                bphase[l] += (gphase[l] - bphase[l]) * 0.5f;
            }



            for (int i = 0; i < size; ++i)
            {
                for (int j = 0; j < size; ++j)
                {
                    for (int k = 0; k < size; ++k)
                    {
                        float R = rcoef[0];
                        float G = gcoef[0];
                        float B = bcoef[0];

                        for (int l = 1; l < levels; ++l)
                        {
                            float lphasei = i * TWO_PI_F * (1 << (l - 1)) / size;
                            float lphasej = j * TWO_PI_F * (1 << (l - 1)) / size;
                            float lphasek = k * TWO_PI_F * (1 << (l - 1)) / size;
                            {
                                float xp = cos(rphase[l].x + lphasei);
                                float yp = cos(rphase[l].y + lphasej);
                                float zp = cos(rphase[l].z + lphasek);
                                R += rcoef[l] * (xp * yp * zp);
                            }
                            {
                                float xp = cos(gphase[l].x + lphasei);
                                float yp = cos(gphase[l].y + lphasej);
                                float zp = cos(gphase[l].z + lphasek);
                                G += gcoef[l] * (xp * yp * zp);
                            }
                            {
                                float xp = cos(bphase[l].x + lphasei);
                                float yp = cos(bphase[l].y + lphasej);
                                float zp = cos(bphase[l].z + lphasek);
                                B += bcoef[l] * (xp * yp * zp);
                            }
                        }

                        float no = random.nextFloat - 0.5f;
                        R += no * wnoise.x;
                        no = random.nextFloat - 0.5f;
                        G += no * wnoise.y;
                        no = random.nextFloat - 0.5f;
                        B += no * wnoise.z;

                        R = 0.5 + 0.5 * amplify(-1 + 2.f * R);
                        G = 0.5 + 0.5 * amplify(-1 + 2.f * G);
                        B = 0.5 + 0.5 * amplify(-1 + 2.f * B);
                        texData3D[index++] = R;
                //        texData3D[index++] = G;
                //        texData3D[index++] = B;
                    }
                }
            }

            tex.setImage(0, size, size, size, Texture.Format.INTENSITY, Texture.Type.FLOAT, texData3D.ptr, true);
            GL.check();
			return tex;
        }
    }
}


module bitmapfont;

import gl.all;
import math.all;
import sdl.sdlimage;
import misc.image;
import misc.colors;
import res.shaderpool;
import res.settings;

final class BitmapFont
{

	public
	{
		Texture2D fillTexture()
		{
			return m_fillTex;
		}
	}

	private
	{
		Texture2D m_tex; // the letters
		Texture2D m_fillTex; // filling
		ShaderPool m_shaderPool;
		int m_widths[256];		// width of each character


		void drawChar(float x, float y, float factor, char a, vec4f color)
		{
			float cw = cellWidth;
			float ch = cellHeight;
			auto xmin = x ;
			auto xmax = x + cw * factor;
			auto ymin = y ;
			auto ymax = y + ch * factor;

	/*		auto prout = 0.005f;
			auto xmin2 = x - prout ;
			auto xmax2 = x + cw * factor + prout;
			auto ymin2 = y - prout;
			auto ymax2 = y + ch * factor + prout;
	*/

			auto xmid = (xmin + xmax) * 0.5f;
			auto ymid = (ymin + ymax) * 0.5f;

			ubyte b = cast(ubyte) a; // assume ASCII-compatible utf-8 !!!


			int ligne = (b / 16);
			int col = (b & 15);

		    float s = col * (1.0f / 16.0f) + 0.01f / 16.f;
		    float s2 = s + (0.98f / 16.0f);

		    float t = ligne * (1.0f / 16.0f) + 0.01f / 16.f;
		    float t2 = t + (0.98f / 16.0f);

			GL.color(color);
			GL.texCoord(0, s, t);	GL.vertex(xmin, ymax);
			GL.texCoord(0, s2, t);  GL.vertex(xmax, ymax);
			GL.texCoord(0, s2, t2); GL.vertex(xmax, ymin);
			GL.texCoord(0, s, t2);  GL.vertex(xmin, ymin);

		}
	}

	public
	{
		this(ShaderPool shaderPool, char[] file, char[] file2)
		{

			{
				// load text texture
				scope auto img = new SDLImage(file);
				m_tex = new Texture2D(img.width, img.height, Texture.IFormat.RGBA8, true, false, true);
				m_tex.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
				m_tex.magFilter = Texture.Filter.LINEAR;
				m_tex.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
				m_tex.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
				
				img.lock();
				m_tex.setSubImage(0, 0, 0, img.width, img.height, Texture.Format.RGBA, Texture.Type.UBYTE, img.data);
				m_tex.generateMipmaps();
				
				img.unlock();

				// load filling texture
				scope auto img2 = new SDLImage(file2);
				m_fillTex = new Texture2D(img2.width, img2.height, Texture.IFormat.RGBA8, true, false, true);
				m_fillTex.minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
				m_fillTex.magFilter = Texture.Filter.LINEAR;
				m_fillTex.wrapS = Texture.Wrap.REPEAT;
				m_fillTex.wrapT = Texture.Wrap.REPEAT;
				
				img2.lock();
				m_fillTex.setSubImage(0, 0, 0, img2.width, img2.height, Texture.Format.RGBA, Texture.Type.UBYTE, img2.data);
				m_fillTex.generateMipmaps();
				img2.unlock();


				// analysis to find the width of each character
				auto scope image = new Image(img);

				for (int i = 0; i < 256; ++i)
				{
					int ligne = (i / 16);
					int col = (i & 15);

					int bx = cellWidth() * col;
					int by = cellHeight() * ligne;

					m_widths[i] = cellWidth() >> 1;

					for (int x = cellWidth() - 1; x >= 0; --x)
					{
						for (int y = 0; y < cellHeight(); ++y)
						{
							uint c = image.getPixel(bx + x, by + y);

							if (Avalue(c) > 0)
							{
								m_widths[i] = x;
								goto end_of_loops;
							}
						}
					}

					end_of_loops: ;

				}

			}

			m_shaderPool = shaderPool;
			


		}

		int cellWidth()
		{
			return m_tex.width / 16;
		}

		int cellHeight()
		{
			return m_tex.height / 16;
		}

		int charWidth(char a)
		{
			ubyte b = cast(ubyte) a;
			return m_widths[b];
		}

		int charHeight()
		{
			return cellHeight();
		}


		void drawString(char[] s, float x, float y, float height, vec4f color)
		{
			float factor = height / charHeight();


			if (s == "") return;

	//		GL.pushAttrib(GL.ENABLE_BIT);
			
			GL.disable( GL.DEPTH_TEST, GL.CULL_FACE );
		    GL.enable(GL.BLEND, GL.ALPHA_TEST);
		    GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			         GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);


			Shader shader = m_shaderPool.getShader("font");
			shader.use();
		    shader.setSampler("tex", m_tex);
			shader.setSampler("fill", m_fillTex);
			
	        bool isRGBLinear = useHDR && usePostProcessing;
	        shader.set1b("isRGBLinear", isRGBLinear);

		    float bx = x - getStringWidth(s) * factor * 0.5f;


		    GL.begin(GL.QUADS);
				for (int i = 0; i < s.length; ++i)
				{
					float t = i / cast(float)s.length;
					float t2 = (i+1) / cast(float)s.length;
					float cy = y - factor * (charHeight() * 0.5f);

					drawChar(bx, cy, factor, s[i], color);
					bx += charWidth(s[i]) * factor;
				}
			GL.end();

	//		GL.popAttrib(GL.ENABLE_BIT);
		}

		int getStringWidth(char[] s)
		{
			int w = 0;
			for (int i = 0; i < s.length; ++i)
			{
				w += charWidth(s[i]) + 2;
			}
			return w;
		}

		int getStringHeight(char[] s)
		{
			return charHeight();
		}

		vec2f getStringSize(char[] s, float height)
		{
		    float factor = height / charHeight();

		    float w = getStringWidth(s) * factor;
		    float h = getStringHeight(s) * factor;
		    return vec2f(w, h);
		}

	}
}

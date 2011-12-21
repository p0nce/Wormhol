module gaussianblur;

import math.all;
import gl.all;
import res.shaderpool;
import gaussianblur;
import misc.logger;
import gl.textureunit;
import res.settings;

// Handle the demo post-processing

class GaussianBlurError : object.Exception
{
	this(char[] msg)
	{
		super(msg);
	}
}

final class GaussianBlur
{
	private
	{
		box2i m_viewport;

		//Shader m_copyShader;
		Shader m_hvblurShader;
		Texture2D m_sourceBuffer;


		int m_baseLevel; // 0 => no initial downsample
		                 // 1 => the blur work on 1/2 reduced image
		                 // 2 => the blur work on 1/4 reduced image
		int m_levels; // 0 => initial downsample

		Texture2D[2] m_tempBuffers;

		FBO[] m_fbos;

		vec2i size(int level)
		{
		    int width = max(1, m_sourceBuffer.width >> level);
		    int height = max(1, m_sourceBuffer.height >> level);
            return vec2i(width, height);
		}
	}

	public
	{
		void recreateBuffers()
		{
		 	info("*Create temp buffers");
			for (int i = 0; i < 2; ++i)
            {
	            try
				{
	                m_tempBuffers[i] = new Texture2D(size(m_baseLevel).x, size(m_baseLevel).y, useHDR ? Texture.IFormat.RGBA16F : Texture.IFormat.RGBA8, true, false, false);
	      
	                m_tempBuffers[i].minFilter = Texture.Filter.LINEAR_MIPMAP_LINEAR;
	      
	                m_tempBuffers[i].magFilter = Texture.Filter.LINEAR;
	      
	                m_tempBuffers[i].wrapS = Texture.Wrap.CLAMP_TO_EDGE;
	      
	                m_tempBuffers[i].wrapT = Texture.Wrap.CLAMP_TO_EDGE;
	      
	        //        m_tempBuffers[i].setImage(0, size(m_baseLevel).x, size(m_baseLevel).y,
	        //                                  Texture.Format.RGBA, Texture.Type.FLOAT, null, true);
					
	      		} catch(OpenGLError e)
                {
	                crap("stop now");
	                assert(false);//throw new GaussianBlurError("The gaussian blur couldn't be created");
                }
			}
			
			info("*Create FBOs");
			
			m_fbos.length = m_levels;

			for (int i = 0; i < m_levels; ++i)
			{
				try
				{
					m_fbos[i] = new FBO();
					m_fbos[i].setWrite(FBO.Component.COLORS);
					m_fbos[i].color[0].setTarget(m_tempBuffers[0], i);
					m_fbos[i].color[1].setTarget(m_tempBuffers[1], i);
	                m_fbos[i].check();
	                
                } catch(OpenGLError e)
                {
	                assert(false);//throw new GaussianBlurError("The gaussian blur couldn't be created");
                }
			}
		}
		
		
		this(ShaderPool shaderPool, Texture2D sourceBuffer, int baseLevel)
		{
			info(">GaussianBlur.this()");
		    assert(baseLevel >= 0);
		    m_baseLevel = baseLevel;
			m_sourceBuffer = sourceBuffer;
			
			try
			{
				//m_copyShader = shaderPool.getShader("blit");

            	m_hvblurShader = shaderPool.getShader("hvblur");
        	} 
        	catch(OpenGLError e)
            {
                assert(false);//throw new GaussianBlurError("The gaussian blur couldn't be created");
            }

            // find out the max level
            info("*Find out the max level");
            int levels = 0;
            while (true)
            {
                vec2i s = size(m_baseLevel + levels);
                if ((s.x == 1) && (s.y == 1))
                {
                    break;
                }
                else levels++;
            }

            m_levels = levels;

           
            
			recreateBuffers();

			
			info("<GaussianBlur.this()");
		}

		Texture2D output()
		{
            return m_tempBuffers[1];
		}

		void render()
		{
	//		info(">GaussianBlur.render");

            m_tempBuffers[0].minFilter = Texture.Filter.LINEAR_MIPMAP_NEAREST;
			m_tempBuffers[1].minFilter = Texture.Filter.LINEAR_MIPMAP_NEAREST;

            for (int i = 0; i < m_levels; ++i)
			{
                auto sizeOutput = size(i + m_baseLevel);

                float ratio = sizeOutput.x / cast(float)(sizeOutput.y);

                void quad(float smin, float smax, float tmin, float tmax)
                {

                    GL.begin(GL.QUADS);
                        GL.color = vec4f(1,1,1,1);
                        GL.texCoord(0, smin, tmin); GL.vertex(-ratio,-1);
                        GL.texCoord(0, smax, tmin); GL.vertex(+ratio,-1);
                        GL.texCoord(0, smax, tmax); GL.vertex(+ratio,+1);
                        GL.texCoord(0, smin, tmax); GL.vertex(-ratio,+1);
                    GL.end();
                }

                GL.viewport = box2i(vec2i(0), sizeOutput);
                GL.projectionMatrix = mat4f.identity;
                GL.modelviewMatrix = mat4f.scale(1.f / ratio, 1.f, 1.f);
                // downsample the source buffer
                
                
                m_fbos[i].use();
                m_fbos[i].setDrawBuffers(0);
                

				Texture2D tex = (i == 0) ? m_sourceBuffer : m_tempBuffers[1];
				int level = (i == 0) ? m_baseLevel : i - 1;
				 
                m_hvblurShader.setSampler("tex", tex);
                m_hvblurShader.set1f("level", level);
                m_hvblurShader.set4f("sizeInfo",  0.5f / sizeOutput.x, 0, -0.5f / sizeOutput.x, 0);
                m_hvblurShader.use();

                //else m_hvblurShader.set4f("sizeInfo",  0.6f / sizeOutput.x, 0, -0.6f / sizeOutput.x, 0);
                
                quad(tex.smin(level), tex.smax(level), tex.tmin(level), tex.tmax(level));

              //  m_fbos[i].use();
                m_fbos[i].setDrawBuffers(1);
                

                Texture2D tex2 = m_tempBuffers[0];
                level = i;
                
                m_hvblurShader.setSampler("tex", tex2);
                m_hvblurShader.set1f("level", level);
                m_hvblurShader.set4f("sizeInfo",   0, 0.5f / sizeOutput.y, 0, -0.5f / sizeOutput.y);
                m_hvblurShader.use();

				quad(tex2.smin(level), tex2.smax(level), tex2.tmin(level), tex2.tmax(level));

			}

			m_tempBuffers[1].minFilter = Texture.Filter.LINEAR_MIPMAP_NEAREST;


	//		info("<GaussianBlur.render");
		}
	}
}


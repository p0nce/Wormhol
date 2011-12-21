module wormholprogram;

import sdl.all;
import misc.all;
import math.all;
import gl.all;
import game;
import misc.logger;


final class WormholProgram : SDLApp
{
	private
	{
		box2i m_view;
		Game m_game;
	}

	public
	{
		this(int asked_width, int asked_height, double ratio, bool fullscreen, int fsaa)
		{
			info(">WormholProgram.this");
			FSAA aa = void;
			if (fsaa == 2) aa = FSAA.FSAA2X;
			else if (fsaa == 4) aa = FSAA.FSAA4X;
			else if (fsaa == 8) aa = FSAA.FSAA8X;
			else if (fsaa == 16) aa = FSAA.FSAA16X;
			else aa = FSAA.OFF;


			super(asked_width, asked_height, fullscreen, false, "Wormhol", "data/icon.bmp", aa, 0, OpenGLVersion.Version20, true);
			title = "Wormhol";
			GL.check();

			SDL_ShowCursor(SDL_DISABLE);

			if (abs(ratio) < 0.0001) // auto ratio
			{
				ratio = cast(double)width / height;
				if (ratio < 5.0 / 4.0) ratio = 5.0 / 4.0;
				if (ratio > 16.0 / 9.0) ratio = 16.0 / 9.0;
			}
			
			// adjust viewport according to ratio
			m_view = box2i(0, 0, width, height).subRectWithRatio(ratio);
			GL.check();

			GL.disable(GL.DEPTH_TEST, GL.LINE_SMOOTH, GL.POLYGON_SMOOTH, GL.POINT_SMOOTH, GL.BLEND,
			          GL.FOG, GL.LIGHTING, GL.NORMALIZE, GL.STENCIL_TEST, GL.CULL_FACE,
			          GL.AUTO_NORMAL);
			          
			GL.hint(GL.PERSPECTIVE_CORRECTION_HINT, GL.NICEST);
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.NICEST);
			
			GL.check();
			
			GL.clampColors(false, false, false);
			
			GL.check();
			
			GL.clearColor = vec4f(0.0,0.0,0.0,1.0);
			GL.clear(true, true, true);
			
			GL.depthFunc(GL.LEQUAL);
			
			m_game = new Game(m_view, width, height);	
			
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
				
			info("<WormholProgram.this");
		}

		~this()
		{
			info(">WormholProgram.~this");
			delete m_game;
			info("<WormholProgram.~this");
		}

		override void onRun()
		{
			
		}

	    override void onRender(double elapsedTime)
	    {
		    //GL.viewport = m_view;
		    m_game.draw(elapsedTime);		    
		}

	    override void onMove(double elapsedTime, double dt)
	    {
		    if (m_game.move(elapsedTime, dt))
			{
				terminate();				
			}
		}

		override void onKeyUp(int key, int mod, wchar ch)
	    {
			m_game.keyUp(key, mod, ch);
		}

	    override void onFrameRateChanged(float frameRate)
	    {
	        string s = format("Wormhol | FPS = %s | joyaxis = %s %s %s %s",
		         frameRate, axis(0), axis(1), axis(2), axis(3));
		    debug
		    {
			    title = s;
		    }
//		    info(s);
		}

	    override void onKeyDown(int key, int mod, wchar ch)
	    {
		    m_game.keyDown(key, mod, ch);
		}

	    override void onMouseMove(int x, int y, int dx, int dy)
	    {
	        m_game.onMouseMove(x, y, dx, dy);
		}

	    override void onMouseDown(int button)
	    {
	        button &= (SDL_BUTTON_LMASK | SDL_BUTTON_MMASK | SDL_BUTTON_RMASK);
	        if (button != 0) m_game.onMouseDown(button);
		}

		override void onMouseUp(int button)
		{
		    button &= (SDL_BUTTON_LMASK | SDL_BUTTON_MMASK | SDL_BUTTON_RMASK);
	        if (button != 0) m_game.onMouseUp(button);
		}

	    override void onReshape(int width, int height)
	    {
		}
    }
}




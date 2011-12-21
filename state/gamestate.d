module state.gamestate;

import state.state;
import gamecontext;
import scene.all;
import scene.scenemanager;
import math.all;
import gl.all;
import res.settings;
import misc.logger;
import sdl.state;
import res.bgcolor;
import bitmapfont;
import std.gc;


final class GameState : State
{
	private
	{
        Camera[] m_cameras;
        SceneManager m_sceneManager = null;
        Random m_random;
	}

	public
	{
		this(GameContext gameContext)
		{
		    super(gameContext);
		    m_random = Random();
		}

		void newGame(int nPlayers, int nIA)
		{
			info(">newGame");
			
			if (nPlayers < 1) nPlayers = 1;
			if (nPlayers > 4) nPlayers = 4;
			
			if (nIA < 0) nIA = 0;
			if (nIA > 8) nIA = 8;
			
			m_cameras = new Camera[nPlayers];

			m_sceneManager = new SceneManager(gameContext, nPlayers, nIA);
			
			BitmapFont font = gameContext.font();

            if (nPlayers == 1)
			{
                m_cameras[0] = new Camera(m_sceneManager, 0, viewport, gameContext.viewport, gameContext);
			}
			else if (nPlayers == 2)
			{
			    box2i left = box2i(viewport.xmin, viewport.ymin, viewport.centerX, viewport.ymax);
			    box2i right = box2i(viewport.centerX, viewport.ymin, viewport.xmax, viewport.ymax);
                m_cameras[0] = new Camera(m_sceneManager, 1, left, gameContext.viewport, gameContext);
                m_cameras[1] = new Camera(m_sceneManager, 0, right, gameContext.viewport, gameContext);
			}
			else if (nPlayers == 3)
			{
			    box2i uleft = box2i(viewport.xmin, viewport.centerY, viewport.centerX, viewport.ymax);
			    
			    box2i lleft = box2i(viewport.xmin, viewport.ymin, viewport.centerX, viewport.centerY);
			    
			    box2i mright = box2i(viewport.centerX, (viewport.ymin + viewport.centerY) >> 1, viewport.xmax, (viewport.centerY + viewport.ymax) >> 1);
			    
			    
                m_cameras[0] = new Camera(m_sceneManager, 1, uleft, gameContext.viewport, gameContext);
                m_cameras[1] = new Camera(m_sceneManager, 0, mright, gameContext.viewport, gameContext);
                m_cameras[2] = new Camera(m_sceneManager, 2, lleft, gameContext.viewport, gameContext);
			}
			else if (nPlayers == 4)
			{
                box2i uleft = box2i(viewport.xmin, viewport.centerY, viewport.centerX, viewport.ymax);
			    box2i uright = box2i(viewport.centerX, viewport.centerY, viewport.xmax, viewport.ymax);
			    box2i lleft = box2i(viewport.xmin, viewport.ymin, viewport.centerX, viewport.centerY);
			    box2i lright = box2i(viewport.centerX, viewport.ymin, viewport.xmax, viewport.centerY);
                m_cameras[0] = new Camera(m_sceneManager, 1, uleft, gameContext.viewport, gameContext);
                m_cameras[1] = new Camera(m_sceneManager, 3, uright, gameContext.viewport, gameContext);
                m_cameras[2] = new Camera(m_sceneManager, 2, lleft, gameContext.viewport, gameContext);
                m_cameras[3] = new Camera(m_sceneManager, 0, lright, gameContext.viewport, gameContext);
			}
			
			initLevel(m_random.nextRange(4));
			
	        for (int i = 0; i < nPlayers; ++i)
            {
            	m_sceneManager.addPlayer(new Player(m_sceneManager, i));
        	}
        	std.gc.fullCollect;
			std.gc.minimize;
			info("<newGame");
		}
		
		void initLevel(int lvl)
		{
			switch(lvl)
			{
				// small sphere
				case 0:
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(0.8f,0.8f, 0.8f) ));
					break;					
				
					
				// pizza
				case 1:
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(1.f,1.f,0.2f) ));
					break;
					
				case 2:
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.translate(0.f,0.f,0.0f) * mat4f.scale(0.2,1.6,0.2) ));
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.translate(0.f,-1.2f,0.0f) * mat4f.scale(0.8,0.8,0.8) ));
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.translate(0.f,1.2f,0.0f) * mat4f.scale(0.8,0.8,0.8) ));
					
		//			m_sceneManager.addSurface(new TorusSurface(m_sceneManager, mat4f.translate(1.f,1.f,1.f), 1.0, 0.25, 0.25 ));
					
					break;
					 //this(SceneManager manager, mat4f transform, float majorRadius, float minorRadiusNorm, float minorRadiusPlane)
        
					
				// smallish sphere with peaks sphere
				case 3:				
				default:
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(0.7f)));
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(0.3f,0.3f,2.f)));
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(0.3f,2.f,0.3f)));
					m_sceneManager.addSurface(new SphereSurface(m_sceneManager, mat4f.scale(2.f,0.3f,0.3f)));
					break;
			}
					
		}

		override void draw(double elapsedTime, float transition)
		{
			
		    if (transition <= 0.001) return;

            // clear with background

			GL.projectionMatrix = mat4f.scale(1.f, 1.f, 1.f);
			GL.modelviewMatrix = mat4f.scale(1.f);
            GL.enable(GL.BLEND, GL.ALPHA_TEST);
            GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);
		    GL.blend(GL.BlendMode.ADD, GL.BlendFactor.SRC_ALPHA, GL.BlendFactor.ONE_MINUS_SRC_ALPHA,
 			            GL.BlendMode.MAX, GL.BlendFactor.ONE, GL.BlendFactor.ONE);

			gameContext.shaderPool.getPutShader.use();
			
			vec4f bgcolor = getBackGroundColorNotCorrected();
			bgcolor.w = transition;

            GL.begin(GL.QUADS);
                GL.color = bgcolor.xyz;
				GL.vertex(-ratio,-1);
				GL.vertex(+ratio,-1);
				GL.vertex(+ratio,+1);
				GL.vertex(-ratio,+1);
			GL.end();

            // render and overlays
           
		    for(int i = 0; i < m_cameras.length; ++i)
            {
                m_cameras[i].render(elapsedTime, transition);
            }

            GL.viewport = viewport();

            HFAmount = mixf(HFAmount, 1.f, transition);
            PPAmount = mixf(PPAmount, 0.7f, transition);
            blurAmount = mixf(blurAmount, 1.f, transition);
		}

		override void move(double elapsedTime, double dt, float transition)
		{
			assert(	m_sceneManager !is null);
			
			// move the scene
			m_sceneManager.move(elapsedTime, dt);

			// move the camera
			foreach(Camera cam; m_cameras)
			{
				cam.move(elapsedTime, dt);
			}
		}
	}
}

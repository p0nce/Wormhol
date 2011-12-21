module game;

import state.all;
import gl.all;
import sdl.all;
import math.all;
import res.shaderpool;
import math.random;
import bitmapfont;
import postprocessing;
import misc.logger;
import res.textures;
import gamecontext;
import sound;
import res.settings;
import state.eye;
import res.bgcolor;


final class Game
{
	private
	{
	    // states
        State m_currentState, m_lastState;

        Splash1State m_splash1state;
        MenuState m_mainmenu, m_playmenu, m_settingsMenu, m_graphicsMenu, m_soundMenu;
        GameState m_gameState;
        GameContext m_context;

        // final rendering viewport
		box2i m_viewport;

		BitmapFont m_font;

		ShaderPool m_shaderPool;

		bool m_stateChanged;
		double m_lastTimeStateChanged, m_lastTimeStateChangedLast;

		PostProcessing m_postProcessing;
		Texture2D m_mainTexture;
		//RenderBuffer m_mainDepthBuffer;
		Texture2D m_mainDepthBuffer;
		
		FBO m_mainFBO, m_defaultFBO;
		
		int m_windowWidth, m_windowHeight;
		bool m_mouseDown = false;
		

		Textures m_textures;
		SoundManager m_soundManager; 
		double m_stateTransition = 1.0;
		
		void setState(State state)
		{
			// if in a transition, deny
		    if (m_stateTransition < 0.99) return;

		    m_lastState = m_currentState;
			m_currentState = state;

			if ((m_lastState !is m_currentState) && (m_lastState !is null))
			{
                m_stateTransition = 0.f;
			}

			m_stateChanged = true;
		}

		bool m_terminated = false;

		void terminate()
		{
			m_terminated = true;
		}

		vec2i m_size;

		void createMenus()
		{
			const float TITLE_SIZE = 1.1f;
			const float NORMAL_ITEM_SIZE = 1.0f;
			const float SMALL_ITEM_SIZE = 0.7f;
			
		    assert(m_context !is null);
            MenuItem[] playmenuItems =
             [ new MenuItem("Start", new StartAGameAction(), NORMAL_ITEM_SIZE),
               new MenuItem("Players: ", new ChangePlayersSettingsAction(), NORMAL_ITEM_SIZE),
  //             new MenuItem("IA: ", new ChangeIASettingsAction(), NORMAL_ITEM_SIZE),
               new MenuItem("Back", null, NORMAL_ITEM_SIZE) ];

            m_playmenu = new MenuState("GAME", m_context, playmenuItems);
            
            MenuItem[] graphicsMenuItems =
             [ new MenuItem("", new ChangeResolutionSettingsAction(), SMALL_ITEM_SIZE),
               new MenuItem("", new ChangeFullscreenSettingsAction(), SMALL_ITEM_SIZE),
               new MenuItem("HDR: ", new ChangeHDRSettingsAction(), SMALL_ITEM_SIZE),
               new MenuItem("Post-FX: ", new ChangePostProcessingSettingsAction(), SMALL_ITEM_SIZE),
               new MenuItem("Gamma: ", new ChangeGammaSettingsAction(), SMALL_ITEM_SIZE),               
			   new MenuItem("Blur: ", new ChangeBlurQualitySettingsAction(), SMALL_ITEM_SIZE),
               new MenuItem("", null, NORMAL_ITEM_SIZE) ];
               
            m_graphicsMenu = new MenuState("GRAPHICS", m_context, graphicsMenuItems);
            
            MenuItem[] soundMenuItems =
             [ new MenuItem("Vol. FX ", new ChangeFXVolumeSettingsAction(m_soundManager), NORMAL_ITEM_SIZE),
               new MenuItem("Vol. Mus. ", new ChangeMusicVolumeSettingsAction(m_soundManager), NORMAL_ITEM_SIZE),
      //         new MenuItem("Change music", new ChangeMusicAction(m_soundManager), NORMAL_ITEM_SIZE),
               new MenuItem("Back", null, NORMAL_ITEM_SIZE) ];
               
            
            m_soundMenu = new MenuState("SOUND", m_context, soundMenuItems);
            
            
            MenuItem[] settingsMenuItems =
             [ new MenuItem("Graphics", new GotoMenuAction(m_graphicsMenu), NORMAL_ITEM_SIZE),
               new MenuItem("Sound", new GotoMenuAction(m_soundMenu), NORMAL_ITEM_SIZE),
               //new MenuItem("Controls", null, NORMAL_ITEM_SIZE),
               new MenuItem("Back", null, NORMAL_ITEM_SIZE) ];
               
            m_settingsMenu = new MenuState("SETTINGS", m_context, settingsMenuItems);
            

            MenuItem[] m_mainmenuItems =
                [ new MenuItem("Play", new GotoMenuAction(m_playmenu), NORMAL_ITEM_SIZE),
                  new MenuItem("Settings", new GotoMenuAction(m_settingsMenu), NORMAL_ITEM_SIZE),
                  new MenuItem("Quit", new ExitGameAction(), NORMAL_ITEM_SIZE) ];


			m_mainmenu = new MenuState("WORMHOL", m_context, m_mainmenuItems);

			m_playmenu.items[$-1].action = new GotoMenuAction(m_mainmenu);
			m_settingsMenu.items[$-1].action = new GotoMenuAction(m_mainmenu);
			m_graphicsMenu.items[$-1].action = new GotoMenuActionOrRestartApp(m_settingsMenu);
			m_soundMenu.items[$-1].action = new GotoMenuAction(m_settingsMenu);
		}

        // mod = 0  ENTER or click
        // mod = 1  LEFT
        // mod = 2  RIGHT
		void executeMenuAction(MenuAction item, int mod)
		{
			if (item is null) return;
			
			if (auto a = cast(GotoMenuAction)item)
            {
                if (mod == 0) 
                {
	                m_soundManager.playSound(FX.PLOP);
	                setState(a.dest);
                }
            }
            else if(auto a = cast(GotoMenuActionOrRestartApp)item)
            {
	            if (mod == 0) 
	            {
		            m_soundManager.playSound(FX.PLOP);
		            
					// restart app if graphics settings have changed   
		            if (graphicsSettingsHaveChanged())
		            {
			            
						mustRestartApp = true;
						terminate();
		            }
		            else
		            {
			            setState(a.dest);
		            }
	            }
            }
            else if (auto a = cast(ExitGameAction)item)
            {
                if (mod == 0) 
                {
	                m_soundManager.playSound(FX.PLOP);
	                terminate();
                }
            }
            else if (auto a = cast(ChangeValueAction)item)
            {
                if ((mod == 0) || (mod == 2))
                {
	                m_soundManager.playSound(FX.MENU2);
	                a.next();
                }
                if (mod == 1) 
                {
	                m_soundManager.playSound(FX.MENU2);
	                a.previous();
                }
                
            } else if (auto a = cast(StartAGameAction)item)
            {
                if (mod == 0)
                {
					m_soundManager.playSound(FX.PLOP);
                    m_gameState.newGame(selectedPlayers, selectedIA);
                    setState(m_gameState);
                }
            }
		}
		
		void recreateMainTexture(bool hdr)
		{
		//	Texture2D oldMain = m_mainTexture;
			info("> create mainTexture");
			
			m_mainTexture = new Texture2D(m_size.x, m_size.y, hdr ? Texture.IFormat.RGBA16F : Texture.IFormat.RGBA8, true, false, false);
			m_mainTexture.minFilter = Texture.Filter.LINEAR;
			m_mainTexture.magFilter = Texture.Filter.LINEAR;
			m_mainTexture.wrapS = Texture.Wrap.CLAMP_TO_EDGE;
			m_mainTexture.wrapT = Texture.Wrap.CLAMP_TO_EDGE;
			//m_mainTexture.setImage(0, m_size.x, m_size.y, Texture.Format.RGBA, useHDR ?  Texture.Type.FLOAT : Texture.Type.UBYTE, null, false);
//			m_mainTexture.clear(0, 0.f, 0.f, 0.f, 1.f);
			
			GL.check;
			info("< create mainTexture");
			
			info("> create mainDepthBuffer");
	//		m_mainDepthBuffer = new RenderBuffer(RenderBuffer.Format.DEPTH, m_size.x, m_size.y);
			m_mainDepthBuffer = new Texture2D(m_size.x, m_size.y, Texture.IFormat.DEPTH, false, false, false);
			
			info("< create mainDepthBuffer");
			
			info("> create main FBO");
			m_mainFBO = new FBO();
			
			m_mainFBO.color[0].setTarget(m_mainTexture, 0);
			
			m_mainFBO.depth.setTarget(m_mainDepthBuffer, 0);	
//			m_mainFBO.depth.setTarget(m_mainDepthBuffer);	
			
			m_mainFBO.setWrite(FBO.Component.COLORS_AND_DEPTH);	
			
			m_mainFBO.setDrawBuffers(0);		
			
			m_mainFBO.check();
			
			m_mainFBO.use();
			GL.clear();
			
			GL.check;
			info("< create main FBO");
//			if (m_mainTexture !is null) delete m_mainTexture;
			
		//	m_mainTexture.generateMipmaps;		
			
		}
	}

	public
	{
		this(box2i viewport, int windowWidth, int windowHeight)
		{
			info(format(">Game.this(%s, %s, %s)", viewport, windowWidth, windowHeight));
		    m_viewport = viewport;
            m_windowWidth = windowWidth;
            m_windowHeight = windowHeight;
            
            void* getHWND()
			{
				SDL_SysWMinfo info;
				SDL_VERSION(&info.ver); 
				
				if (SDL_GetWMInfo(&info))
				{
					return info.window;	
				}
				else return null;
			}

			m_soundManager = new SoundManager(getHWND());

            m_size = vec2i(viewport.width, viewport.height);
            info(format("viewport = %s", viewport));


            // load all textures
            info(">load Textures");
            m_textures = new Textures();
            info("<load Textures");

			// load all shaders

			m_shaderPool = new ShaderPool();
			
			recreateMainTexture(useHDR);
			
			m_defaultFBO = new FBO(true);
			
			info("<create main FBO");

            GL.check();

            info(">create postProcessing");
			m_postProcessing = new PostProcessing(m_defaultFBO, m_shaderPool, m_mainTexture, viewport);
            info("<create postProcessing");

            // create states
            info(">create font");
			m_font = new BitmapFont(m_shaderPool, "data/gfx/font.png", "data/gfx/fill.png");
			info("<create font");

			m_context = new GameContext(m_postProcessing, m_size, m_shaderPool, m_textures, m_font, m_viewport, m_soundManager);
            m_context.mousePos = vec2f(-2, 2);
		    m_context.mouseVel = vec2f(0, 0);

			m_splash1state = new Splash1State(m_context);

            m_gameState = new GameState(m_context);
            
            createMenus();

			setState(m_splash1state);
			
			info("*play music");
            info("<Game.this()");
		}

		~this()
		{
			info(">Game.~this()");
			info("<Game.~this()");
		}

		bool move(double timeElapsed, double dt)
		{
			m_soundManager.nextMusicIfNeeded();
			
			if (m_stateChanged)
		    {
		        m_lastTimeStateChangedLast = m_lastTimeStateChanged;
		        m_lastTimeStateChanged = timeElapsed;
                m_stateChanged = false;
		    }

		    m_stateTransition = mind(1.0, m_stateTransition + dt * 3.0);

            if (m_lastState !is null)
            {
                m_lastState.move(timeElapsed - m_lastTimeStateChangedLast, dt, 1.f - m_stateTransition);
            }

            m_currentState.move(timeElapsed - m_lastTimeStateChanged, dt, m_stateTransition);

			m_context.mouseVel = m_context.mouseVel * exp3(-dt * 4);
            
			return m_terminated;			
		}
		
		void draw(double timeElapsed)
		{   
			
/+
			if (useHDRchanged)
			{
				useHDRchanged = false;
				recreateMainTexture(useHDR);
				
				if (m_postProcessing !is null) m_postProcessing.HDRchanged();
			}
+/			
			
			if (usePostProcessing) 
            {
	            m_mainFBO.use();
            }
            else 
            {
	            m_defaultFBO.use;
            }
            
            GL.clearColor = getBackGroundColor();
			GL.clear(true, true, true);
			GL.disable(GL.DEPTH_TEST, GL.CULL_FACE);
			GL.enable(GL.ALPHA_TEST);
			GL.alphaFunc(GL.GREATER, 0.0038f);
			if (m_lastState !is null)
            {
                m_lastState.draw(timeElapsed - m_lastTimeStateChangedLast, 1.f - m_stateTransition);
            }
            m_currentState.draw(timeElapsed - m_lastTimeStateChanged, m_stateTransition);
            
            GL.viewport = box2i(0, 0, m_size.x, m_size.y);
            
            if (usePostProcessing)
            {
	            m_postProcessing.render();            
            }
		}

		void keyUp(int key, int mod, wchar ch)
	    {
	    	
		}

		void keyDown(int key, int mod, wchar ch)
		{
			debug
			{
				if ((ch == 'p') || (ch == 'P'))
				{
					usePostProcessing = !usePostProcessing;	
				}
			}

		    if (auto gs = cast(GameState) m_currentState)
			{
                if (key == SDLK_ESCAPE)
				{
					setState(m_playmenu);
				}
				
				if ((key == SDLK_RETURN) || (key == SDLK_SPACE))
				{	
					m_soundManager.playSound(FX.PLOP);
                    m_gameState.newGame(selectedPlayers, selectedIA);
				} 
			}
			else if (m_currentState is m_splash1state)
			{
				setState(m_mainmenu);
			}
			else if (auto menu = cast(MenuState) m_currentState)
			{
				if (key == SDLK_UP)
				{
					menu.previousChoice();					
				}
				else if (key == SDLK_DOWN)
				{
					menu.nextChoice();
				}
				else if ((key == SDLK_RETURN) || (key == SDLK_SPACE))
				{
					MenuItem item = menu.currentItem;
					if (item.enabled) executeMenuAction(item.action, 0);
				} 
				else if (key == SDLK_LEFT)
				{
					
				    MenuItem item = menu.currentItem;
				    if (item.enabled) executeMenuAction(item.action, 1);
				} 
				else if (key == SDLK_RIGHT)
				{
				    MenuItem item = menu.currentItem;
				    if (item.enabled) executeMenuAction(item.action, 2);
				}
				else if (key == SDLK_ESCAPE)
				{
                    MenuItem item = menu.lastItem;
                    executeMenuAction(item.action, 0);
				}
			}
		}

		double ratio()
		{
			return m_viewport.width / m_viewport.height;
		}


		void onMouseMove(float x, float y, float dx, float dy)
	    {
            // transform to viewport
            double xr = cast(double)m_windowWidth / m_viewport.width;
            double yr = cast(double)m_windowHeight / m_viewport.height;

            double mx = remapd(x, 0, m_windowWidth, -xr, xr);
            double my = remapd(y, 0, m_windowHeight, +yr, -yr);

            double mdx = remapd(dx, 0, m_windowWidth, 0, +ratio * xr);
            double mdy = remapd(dy, 0, m_windowHeight, 0, -ratio * yr);
	        m_context.mousePos = vec2f(mx, my);
	        m_context.mouseVel = m_context.mouseVel + vec2f(mdx, mdy) * 0.03;

	        float l = m_context.mouseVel.length();
            if (l > 0.07f * 0.17f)
            {
                m_context.mouseVel = m_context.mouseVel * (0.07f * 0.17f / l);
            }

            if (auto menu = cast(MenuState) m_currentState)
			{

                for (int i = 0; i < menu.items.length; ++i)
                {
                    box2f r = menu.getItemBounds(i);
                    if (r.contains(m_context.mousePos))
                    {
                        menu.setCurrentChoice(i);
                        break;
                    }
                }
			}
		}


        void onMouseDown(int button)
	    {
	        m_context.mouseDown = true;

	        // splash 1
			if (m_currentState is m_splash1state)
			{
				setState(m_mainmenu);
			}
			else if (auto menu = cast(MenuState) m_currentState)
			{

                for (int i = 0; i < menu.items.length; ++i)
                {
                    box2f r = menu.getItemBounds(i);
                    if (r.contains(m_context.mousePos))
                    {
                        executeMenuAction(menu.items[i].action, 0);
                        break;
                    }
                }
			}
		}

		void onMouseUp(int button)
		{
		    m_context.mouseDown = false;
		}
	}
}

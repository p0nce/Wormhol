module sound;

import sdl.all;
import misc.singleton;
import math.common;
import misc.logger;
import bass.all;
import res.settings;

enum FX
{
	AVALE1, AVALE2, AVALE3, EXPLODE, MENU, MENU2, PLOP, DIE
}

final class SoundManager
{
	private
	{		
		const int MUSIC_NUM = 3;
		BASSSystem m_system;
		BASSStream[MUSIC_NUM] m_music;
		BASSSample[FX.max + 1] m_fxs;
		int m_index = -1;
		
		static const char[][MUSIC_NUM] musicFiles = 
		[	
			"data/music/maf_-_inspace.mp3",
			"data/music/maf_-_lego_gland.mp3",
			"data/music/maf_-_81.mp3"
		];
		
		static const char[][FX.max + 1] fxFiles = 
		[	
			"data/fx/avale1.wav",
			"data/fx/avale2.wav",
			"data/fx/avale3.wav",
			"data/fx/explode.wav",
			"data/fx/menu.wav",
			"data/fx/menu2.wav",
			"data/fx/plop.wav",
			"data/fx/die.wav"
		];
		
		static const char[][MUSIC_NUM] musicNames = 
		[	
			"maF - inspace",
			"maF - lego gland",
			"maF - 81"
		];
		
		static const float[MUSIC_NUM] musicVolumes = 
		[
			//0.3f,
			0.5f,
			0.5f,
			0.5f,
		];
	}
	
	public
	{
		
		this(HWND hwnd)
		{	
			info(">SoundManager.this");	
			
			try
			{
				m_system = new BASSSystem(hwnd);				
			} catch(BASSError e)
			{
				warn(e.msg);
				info("Sound is now disabled.");
				m_system = null; // no sound	
				info("<SoundManager.this");
				return;				
			}		
			
			info("*loading musics");
			
			for (int i = 0; i < MUSIC_NUM; ++i)
			{
				try
				{
					m_music[i] = new BASSStream(m_system, musicFiles[i]);
				}
				catch(BASSError e)
				{
					warn(e.msg);
					info("Sound will be disabled.");
					m_system = null; // no sound for now
					info("<SoundManager.this");
					return;
				}					
			}	
			
			info("*loading fx sounds");	
			
			for (FX f = FX.min; f <= FX.max; ++f)
			{
				try
				{
					m_fxs[f] = new BASSSample(m_system, fxFiles[f]);
				} catch(BASSError e)
				{
					warn(e.msg);
					info("Sound will be disabled.");
					m_system = null; // no sound for now
					info("<SoundManager.this");
					return;
				}
			}
			
			setMusicVolume(musicVolume);
			
			info("<SoundManager.this");
		}
		
		~this()
		{
			
		}
		
		void playMusic(int index)
		{
			try
			{
				m_music[index].play(true);					
				info(format("Now playing: %s", musicNames[index]));
			} 
			catch(BASSError e)
			{
				warn(e.msg);
			}
		}
	}
	
	public
	{		
		void nextMusicIfNeeded()
		{			
			bool needNewMusic = (m_index == -1) || (!m_music[m_index].isPlaying);
			
			if (needNewMusic)
			{
				nextMusic();
			}			
		}	
		
		void nextMusic()
		{
			m_index++;
			if (m_index >= MUSIC_NUM) m_index = 0;
			
			playMusic(m_index);
		}	
		
		void previousMusic()
		{
			m_index--;
			if (m_index < 0) m_index = MUSIC_NUM - 1;
			
			playMusic(m_index);
		}
		
		void setMusicVolume(int volume) // between 0 and 1
		{
			float volumeCorrected = sqr(volume * 0.1f);
			for (int i = 0; i < MUSIC_NUM; ++i)
			{
				m_music[i].setVolume(volumeCorrected);				
			}			
		}
		
		void playSound(FX fx, float volume = 1.f)
		{
			float correctedVolume = sqr(volume * soundFXVolume * 0.09f);
			m_fxs[fx].play(correctedVolume);
		}
	}
}


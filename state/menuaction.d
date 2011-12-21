module state.menuaction;

import state.menustate;

import res.settings;
import std.string;
import sound;

abstract class MenuAction
{
    public
    {
        string textExt()
        {
            return "";
        }

        bool enabled()
        {
            return true;
        }
    }
}


final class StartAGameAction : MenuAction
{

}

/*
final class DoNothingAction : MenuAction
{
}
*/

final class GotoMenuAction : MenuAction
{
    private
    {
        MenuState m_menuState;
    }

    public
    {
        this(MenuState menuState)
        {
            m_menuState = menuState;
        }

        MenuState dest() { return m_menuState; }
    }
}

final class GotoMenuActionOrRestartApp : MenuAction
{
    private
    {
        MenuState m_menuState;
    }

    public
    {
        this(MenuState menuState)
        {
            m_menuState = menuState;
        }

        MenuState dest() { return m_menuState; }

        string textExt()
        {
            if (graphicsSettingsHaveChanged())
            {
                return "Apply";
            }
            else
            {
                return "Back";
            }
        }
    }
}




final class ExitGameAction : MenuAction
{
}


abstract class ChangeValueAction : MenuAction
{
   public
    {
        abstract void previous();

        abstract void next();

  //      abstract int currentIndex();

    //    abstract string currentValue();

        abstract string textExt();
    }
}

class ChangeResolutionSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            selectedResolution--;
            if (selectedResolution < 0) selectedResolution += MAX_RESOLUTION_CHOICE;
        }

        override void next()
        {
            selectedResolution++;
            if (selectedResolution >= MAX_RESOLUTION_CHOICE) selectedResolution = 0;
        }

     //   override int currentIndex() { return selectedResolution; }

 //       override string currentValue() { return getResolutionString(selectedResolution); }

        override string textExt()
        {
            return getResolutionString(selectedResolution);
        }

    }
}

class StdChangeValueAction : ChangeValueAction
{
    private
    {
        string[] m_values;
        int m_current;
    }

    public
    {
        this(string[] values, int current = 0)
        {
            m_values = values;
            m_current = current;
        }

        override void previous()
        {
            m_current--;
            if (m_current < 0) m_current += m_values.length;
        }

        override void next()
        {
            m_current++;
            if (m_current >= m_values.length) m_current = 0;
        }

        int currentIndex() { return m_current; }

 //       override string currentValue() { return m_values[m_current]; }

        override string textExt()
        {
            return m_values[m_current];
        }
    }
}

class ChangeFullscreenSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            selectedFullscreen = !selectedFullscreen;
        }

        override void next()
        {
            selectedFullscreen = !selectedFullscreen;
        }

        override string textExt()
        {
            return selectedFullscreen ? "Fullscreen" : "No fullscreen";
        }
    }
}

class ChangePlayersSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            selectedPlayers--;
            if (selectedPlayers < MIN_PLAYERS) selectedPlayers = MAX_PLAYERS;
        }

        override void next()
        {
            selectedPlayers++;
            if (selectedPlayers > MAX_PLAYERS) selectedPlayers = MIN_PLAYERS;
        }

        override string textExt()
        {
            return std.string.toString(selectedPlayers);
        }
    }
}

class ChangeIASettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            selectedIA--;
            if (selectedIA <= MIN_IA) selectedIA = MAX_IA;
        }

        override void next()
        {
            selectedIA++;
            if (selectedIA > MAX_IA) selectedIA = MIN_IA;
        }

        override string textExt()
        {
            return std.string.toString(selectedIA);
        }
    }
}



class ChangeMusicVolumeSettingsAction : ChangeValueAction
{
    private
    {
        SoundManager m_soundManager;
    }

    public
    {
        this(SoundManager soundManager)
        {
            m_soundManager = soundManager;
        }

        override void previous()
        {
            musicVolume--;
            if (musicVolume < MIN_MUSIC_VOLUME) musicVolume = MAX_MUSIC_VOLUME;
            m_soundManager.setMusicVolume(musicVolume);
        }

        override void next()
        {
            musicVolume++;
            if (musicVolume > MAX_MUSIC_VOLUME) musicVolume = MIN_MUSIC_VOLUME;
            m_soundManager.setMusicVolume(musicVolume);
        }

        override string textExt()
        {
            return std.string.toString(musicVolume) ~ "/10";
        }
    }
}

class ChangeFXVolumeSettingsAction : ChangeValueAction
{
    private
    {
        SoundManager m_soundManager;
    }

    public
    {
        this(SoundManager soundManager)
        {
            m_soundManager = soundManager;
        }

        override void previous()
        {
            soundFXVolume--;
            if (soundFXVolume < MIN_MUSIC_VOLUME) soundFXVolume = MAX_MUSIC_VOLUME;
        }

        override void next()
        {
            soundFXVolume++;
            if (soundFXVolume > MAX_MUSIC_VOLUME) soundFXVolume = MIN_MUSIC_VOLUME;
        }

        override string textExt()
        {
            return std.string.toString(soundFXVolume) ~ "/10";
        }
    }
}

class ChangeMusicAction : ChangeValueAction
{
    private
    {
        SoundManager m_soundManager;
    }

    public
    {
        this(SoundManager soundManager)
        {
            m_soundManager = soundManager;
        }

        override void previous()
        {
            m_soundManager.previousMusic;
        }

        override void next()
        {
            m_soundManager.nextMusic;
        }

        override string textExt()
        {
            return "";
        }
    }
}

class ChangeHDRSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            selectedUseHDR = !selectedUseHDR;
        //    useHDRchanged = true;
        }

        override void next()
        {
            selectedUseHDR = !selectedUseHDR;
        //    useHDRchanged = true;
        }

        override string textExt()
        {
            return selectedUseHDR ? "on" : "off";
        }
    }
}

class ChangePostProcessingSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            usePostProcessing = !usePostProcessing;
        }

        override void next()
        {
            usePostProcessing = !usePostProcessing;
        }

        override string textExt()
        {
            return usePostProcessing ? "on" : "off";
        }
    }
}

class ChangeBlurQualitySettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            if (!canBlurQuality)
            {
                blurQuality = false;
            }
            else
            {
                blurQuality = !blurQuality;
            }
        }

        override void next()
        {
            if (!canBlurQuality)
            {
                blurQuality = false;
            }
            else
            {
                blurQuality = !blurQuality;
            }
        }

        override string textExt()
        {
            return blurQuality ? "nice" : "ugly";
        }

        override bool enabled()
        {
            return usePostProcessing && canBlurQuality;
        }
    }
}

class ChangeGammaSettingsAction : ChangeValueAction
{
    public
    {
        override void previous()
        {
            gammaModifier--;
            if (gammaModifier < MIN_GAMMA_MODIFIER) gammaModifier = MAX_GAMMA_MODIFIER;
        }

        override void next()
        {
            gammaModifier++;
            if (gammaModifier > MAX_GAMMA_MODIFIER) gammaModifier = MIN_GAMMA_MODIFIER;
        }

        override string textExt()
        {
            return std.string.toString(gammaModifier) ~ "/10";
        }

        override bool enabled()
        {
            return usePostProcessing;
        }
    }
}

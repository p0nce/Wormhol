module res.settings;

import math.vec2;
import math.vec4;
import misc.colors;
import misc.inifile;
import derelict.sdl.keysym;

// TODO: should not be globals :(

vec4f[4] PLAYER_COLOR;

vec4f IA_COLOR;

static this()
{
    PLAYER_COLOR[0] = vec4f(0x8e / 255.f, 0xe9 / 255.f, 0xf4 / 255.f, 1.f);
    PLAYER_COLOR[1] = vec4f(0xff / 255.f, 0x77 / 255.f, 0xe4 / 255.f, 1.f);
    PLAYER_COLOR[2] = vec4f(0x8e / 255.f, 0xf4 / 255.f, 0x97 / 255.f, 1.f);
    PLAYER_COLOR[3] = vec4f(0xf1 / 255.f, 0xd9 / 255.f, 0x6c / 255.f, 1.f);
    IA_COLOR = vec4f(0xa6 / 255.f, 0x6b / 255.f, 0x57 / 255.f, 1.f);
}

const int MAX_RESOLUTION_CHOICE = 13;

const int MIN_PLAYERS = 2;
const int MAX_PLAYERS = 4;

const int MIN_IA = 0;
const int MAX_IA = 8;

const int MIN_MUSIC_VOLUME = 0;
const int MAX_MUSIC_VOLUME = 10;

const int MIN_SOUND_VOLUME = 0;
const int MAX_SOUND_VOLUME = 10;


const int MIN_GAMMA_MODIFIER = 0;
const int MAX_GAMMA_MODIFIER = 10;

const float GAMMA_VALUES[MAX_GAMMA_MODIFIER + 1] = [ 0.5f, 0.6f, 0.7f, 0.8f, 0.9f, 1.0f, 1.1f, 1.2f, 1.3f, 1.4f, 1.5f];

bool usePostProcessing = true;
bool useHDR = false;
bool useHDRchanged = false;

bool blurQuality = true; //EXTGpuShader4.isEnabled();
bool canBlurQuality = true;
bool selectedUseHDR = true;

const char[][MAX_RESOLUTION_CHOICE] resString =
[
    "Auto res.", "640 x 480", "800 x 600", "1024 x 768", "1280 x 720",
    "1280 x 800", "1280 x 1024", "1368 x 768", "1440 x 900",
    "1600 x 1200", "1680 x 1050", "1920 x 1080", "1920 x 1200"
];

private const int[MAX_RESOLUTION_CHOICE] resWidth =
[
    -1, 640, 800, 1024, 1280, 1280, 1280, 1368, 1440, 1600, 1680, 1920, 1920
];

private const int[MAX_RESOLUTION_CHOICE] resHeight =
[
    -1, 480, 600, 768, 720, 800, 1024, 768, 900, 1200, 1050, 1080, 1200
];

vec2i getResolution(int x)
{
    return vec2i(resWidth[x], resHeight[x]);
}

char[] getResolutionString(int x)
{
    return resString[x];
}

int selectedIA = 3;
int selectedPlayers = 2;
int selectedResolution = 0;
bool selectedFullscreen = true;
int musicVolume = 7;
int soundFXVolume = 7;

int currentResolution;
bool currentFullscreen;
bool mustRestartApp = false;
int gammaModifier = 2;

SDLKey[4] playerLeftKey;
SDLKey[4] playerRightKey;

bool graphicsSettingsHaveChanged()
{
    return (currentResolution != selectedResolution) || (currentFullscreen != selectedFullscreen) || (useHDR != selectedUseHDR);
}

const char[] INI_FILENAME = "wormhol.ini";



void loadSettings()
{
    auto scope iniFile = new IniFile(INI_FILENAME);


    selectedResolution = iniFile.readInt("graphics", "resolution", 0);
    if ((selectedResolution < 0) || (selectedResolution >= MAX_RESOLUTION_CHOICE))
    {
        selectedResolution = 0;
    }

    selectedFullscreen = iniFile.readBool("graphics", "fullscreen", true);
    musicVolume = iniFile.readInt("sound", "music", 7);
    soundFXVolume = iniFile.readInt("sound", "soundfx", 7);

    selectedPlayers = iniFile.readInt("game", "humans", 2);
    selectedIA = iniFile.readInt("game", "ia", 3);

    playerLeftKey[0] = iniFile.readInt("controls", "player0left", SDLK_LEFT);
    playerRightKey[0] = iniFile.readInt("controls", "player0right", SDLK_RIGHT);
    playerLeftKey[1] = iniFile.readInt("controls", "player1left", SDLK_a);
    playerRightKey[1] = iniFile.readInt("controls", "player1right", SDLK_d);
    playerLeftKey[2] = iniFile.readInt("controls", "player2left", SDLK_j);
    playerRightKey[2] = iniFile.readInt("controls", "player2right", SDLK_l);
    playerLeftKey[3] = iniFile.readInt("controls", "player3left", SDLK_KP4);
    playerRightKey[3] = iniFile.readInt("controls", "player3right", SDLK_KP6);

    usePostProcessing = iniFile.readBool("graphics", "usePostProcessing", true);
    selectedUseHDR = iniFile.readBool("graphics", "useHDR", true);
    blurQuality = iniFile.readBool("graphics", "blurQuality", true);
    gammaModifier = iniFile.readInt("graphics", "gammaModifier", 2); // defaults to LCD
}

void saveSettings()
{
    auto scope iniFile = new IniFile();

    iniFile.writeInt("graphics", "resolution", selectedResolution);
    iniFile.writeBool("graphics", "fullscreen", selectedFullscreen);

    iniFile.writeInt("sound", "music", musicVolume);
    iniFile.writeInt("sound", "soundfx", soundFXVolume);

    iniFile.writeInt("game", "humans", selectedPlayers);
    iniFile.writeInt("game", "ia", selectedIA);

    iniFile.writeInt("controls", "player0left", playerLeftKey[0]);
    iniFile.writeInt("controls", "player0right", playerRightKey[0]);

    iniFile.writeInt("controls", "player1left", playerLeftKey[1]);
    iniFile.writeInt("controls", "player1right", playerRightKey[1]);

    iniFile.writeInt("controls", "player2left", playerLeftKey[2]);
    iniFile.writeInt("controls", "player2right", playerRightKey[2]);

    iniFile.writeInt("controls", "player3left", playerLeftKey[3]);
    iniFile.writeInt("controls", "player3right", playerRightKey[3]);

    iniFile.writeBool("graphics", "usePostProcessing", usePostProcessing);
    iniFile.writeBool("graphics", "useHDR", selectedUseHDR);
    iniFile.writeBool("graphics", "blurQuality", blurQuality);

    iniFile.writeInt("graphics", "gammaModifier", gammaModifier);
    iniFile.save(INI_FILENAME);
}


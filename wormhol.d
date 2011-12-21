import misc.logger;
import std.stdio, std.file, std.path, sdl.all, std.conv, std.gc, std.string;
import std.c.stdlib;
import sdl.all;
import std.c.windows.windows;

import wormholprogram;
import misc.logger;
import res.settings;
import math.vec2;

version(Windows)
{
	import std.c.windows.windows;		
}

int mainProcedure(char[][] args)
{
	chdir(getDirName(args[0]));
	

	do {
		loadSettings();
		saveSettings(); // to save defaults and allow changing options manually
		vec2i res = getResolution(selectedResolution);
		bool fullscreen = selectedFullscreen;
		
		currentResolution = selectedResolution;
		currentFullscreen = selectedFullscreen;
		useHDR = selectedUseHDR;
		mustRestartApp = false;


		
		{
			auto scope app = new WormholProgram(res.x, res.y, 0.0, fullscreen, 1); // auto-detect ratio
			std.gc.fullCollect;
			std.gc.minimize;
			app.run();
		}
		std.gc.fullCollect;				
		
		saveSettings();
		
		// because it doesn't work		
		if (mustRestartApp)
		{
			mustRestartApp = false;
			
			//info("Restart the app for enjoying your new settings.");
			/*version(Windows) // warn the user
			{
				MessageBoxA(null, toStringz("Restart Wormhol for your new settings."), toStringz("Wormhol"), MB_OK);
			}*/
		}
		
	} while(mustRestartApp); 
	
	return 0;
}

version(Windows)
{
	debug
	{		
		int main(char[][] args)
		{
			return mainProcedure(args);
		}
	}
	else
	{
		import std.string;
		import std.stream;
		import std.math;
		import std.c.stdlib;
		import std.c.windows.windows;
	  	import std.string;

		extern (C)
		{
			void gc_init();
			void gc_term();
			void _minit();
			void _moduleCtor();
		}

		extern (Windows) public int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
		{
			int result;
			gc_init();
			_minit();
			try
			{
				_moduleCtor();
				char exe[4096];
				GetModuleFileNameA(null, exe.ptr, 4096);
				char[][1] prog;
				prog[0] = std.string.toString(exe.ptr);
				result = mainProcedure(prog ~ std.string.split(std.string.toString(lpCmdLine)));
			}
			catch (Object o)
			{
				result = EXIT_FAILURE;
			}
			gc_term();
			return result;
		}
	}
}
else
{
	
	int main(char[][] args)
	{
		return mainProcedure(args);
	}
	
}

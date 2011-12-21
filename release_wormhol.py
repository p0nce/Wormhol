# This Python 2.6 script extract useful files for a standalone Msgdll app
# release wormhol

from shutil import *
import os
import glob

source_folder = "D:/adinpsz/d/wormhol/"

destination_folder = "D:/adinpsz/d/wormhol/release/"



print "Deleting " + destination_folder
rmtree(destination_folder, True) # ignore errors


def createDir(dirname):    
    try:
        print "Creating filder " + dirname
        os.makedirs(dirname)
    except OSError:
        if os.path.exists(dirname):
            # We are nearly safe
            pass
        else:
            # There was an error on creation, so make sure we know about it
            raise
        

createDir(destination_folder)
createDir(destination_folder + "data/")
createDir(destination_folder + "data/shaders")
createDir(destination_folder + "data/gfx/")
createDir(destination_folder + "data/music/")
createDir(destination_folder + "data/fx/")

def outputFiles(source_dir, dest_dir, filename_with_wildcards):

    def outputFile(source_dir, dest_dir, filename):    
        src = source_folder + source_dir + filename
        dst = destination_folder + dest_dir + filename
        print "Copying " + src + " to " + dst
        copyfile(filename, dst)
        return

    def find(filename_with_wildcards):
        s = glob.glob(filename_with_wildcards)
        if len(s) == 0:
            print "WARNING: no file found for " + filename_with_wildcards
            print "supposedly in '" + source_dir + "'\n"
#            exit(1)
        return s    

    os.chdir(source_folder + source_dir)
    filenames = find(filename_with_wildcards);

    
    for f in filenames:
        outputFile(source_dir, dest_dir, f)
        
        
outputFiles("", "", "data/shaders/*.fs")
outputFiles("", "", "data/shaders/*.vs")
outputFiles("", "", "data/music/*.mp3")
outputFiles("", "", "data/fx/*.wav")
outputFiles("", "", "data/icon.bmp")
outputFiles("", "", "data/gfx/*.png")
outputFiles("", "", "data/gfx/*.jpg")
outputFiles("", "", "wormhol.exe")
outputFiles("", "", "wormhol.nfo")
outputFiles("", "", "*.dll")

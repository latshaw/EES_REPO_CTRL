# JAL 9/21/23
# Parse through the supplied Quartus TCL files, and find all source files with paths
# and dump these to a file_list.d file. This can be used to grab all source files 
# and place into a folder.

import argparse
import shutil
import os

parser = argparse.ArgumentParser(description='Take in a Quartus tcl file and find all file names/paths')
parser.add_argument('-f', '--file', help='Provide a tcl file that you would like to parse and gather source names')
parser.add_argument('-s', '--save', help='Save file_list.d', action='store_true')
parser.add_argument('-c', '--copy', help='Copy over files to a new folder, /sources', action='store_true')
args = parser.parse_args()

f = open(str(args.file), "r")

ext = ['.vhd', '.ip', '.v', '.stp', '.sdc', '.qip'] #order does matter, make sure to have .v after .vhd
file_list = []
for line in f:
    found = 0
    for e in ext:
        if found == 0:
            index = line.find(e)
            if index == -1:
                index2 = line.lower().find(e)
                if index2 >=0:
                    index = index2
            if index >= 0: #file type found
                temp = line[line.find("_FILE"):]
                p2f = temp[temp.find(" ")+1:]
                #print(p2f) #path to file, including the file name
                file_list.append(p2f)
                found = 1
f.close()

#display some useful information to user
n = len(file_list)
if n == 0:
    print('No source files found...')
else:
    print('Number of sources found: '+str(n))
    if args.save:
        print('Generating file_list.d')

        f2 = open("file_list.d", "w")
        f2.close()

        f3 = open("file_list.d", "a")
        for file in file_list:
            f3.write(file)
        f3.close()
   
#If copy argument is passed, copy over source directory, creating new folders if they don't exist
print("Making git_repo directory if it does not exist...")
os.makedirs(os.path.dirname('./git_repo/test.txt'), exist_ok=True) #create ./git_repo if it does not currently exist

exceptions = 0
if args.copy:
    tree = []
    print("Copying files over to ./git_repo/...")
    for file in file_list:
        file = file[:-1] #remove new line hidden character from the end
        #just grab the file in case if the the path has one or more folders in it...
        index = 1
        original = file
        #while(index>=0):
        #    index = file.find('/')
        #    if index >= 0:
        #        file = file[(index+1):]
        #print('./sources/'+str(file))
        #if file.find('/') >= 0: #is a bath
        #    original = './'+original
        try:
            #os.makedirs(os.path.dirname('./git_repo/'+str(file)), exist_ok=True) #create path if it does not exist (folders)
            if original.find('/') >= 0: #if true, then this is a path
                index = file.find('/')
                original = './'+file[:index] #grab folder name
                temp = file[:index]
                match = 0
                for t in tree: # tree is a list of folders already copied
                    if t==temp: #see if current name matches one in this list
                        match = 1
                if match == 0: #if no matches found, this is a new one
                    tree.append(file[:index]) # add it to the list and copy the folder over
                    #print('notes:', original)
                    shutil.copytree(original, './git_repo/'+str(file[:index]), dirs_exist_ok=True) #copy all folders and sub folders
                    print('COPY FOLDER: ' + str(original) +' to '+ './git_repo/'+str(file[:index]))
            else:
                shutil.copy2(str(original), './git_repo/'+str(file)) #copy over this single file
                print('COPY FILE: ', str(original), ' to ', './git_repo/'+str(file))
        except:
            print("WARNING FILE NOT FOUND, COULD NOT COPY: "+ str(original) + ' to ' + './git_repo/'+str(file))
            exceptions+=1
#explain the error message:
if exceptions >= 1:
    print('WARNING: There were files called out in your TCL file that were not found. Please make sure that you still want these in your project.')
    
    
    
print('DONE! :)')
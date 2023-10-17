# EES_REPO_CTRL
Welcome to the JSA Repository Page. This is a public repository page contianing information needed to properly use github repos. We can use this as a playground in which to add experimental updates and forks. 
This is a local update, try to push to remote.

Instructions for converting your existing Quartus project someting to place on gitlab:


1. Make a copy of your project, this is your staging folder.
2. Open your <...>.qpf quartus project
3. Go to Project > Generate TCL File for Project, which will generate <...>.tcl file 
	1. You may this tcl file something simple
	2. Look at the generated file and remove anything that does not need to be there.
4. Copy in the get_files.py helper program
5. Close quartus and open up gitbash in the staging folder.  
6. Run python get_files.py -c -s -f <...>.tcl (use the same name as in step 3).
7. Check if there are any warnings or errors and fix if necessary.
8. In your staging folder open the git_repo folder
	1. Make sure that no .jic or large files are present (use find . -type f -name "*.jic")
	2. Add the <...>.tcl file that was used
	3. Rename this git_repo to the folder that you want to show up in gitlab, LLRF3_<system>
9. If you do not have a current working version of the git repository:
	1. Create a new folder called GIT_STAGING
	2. Open gitbash and run: git clone https://github.com/latshaw/EES_REPO_CTRL.git
	3. Copy over the LLRF3_<system>
	4. In git bash run git commit -m '<insert your useful message here'
	5. Then also run git push
	6. If there are no error messages then your repo is now onlin! :)
10. If you are working from a already cloned project
	1. Use git pull to pull in the latest repo from online.
	2. Use 'git status' to display helpful messages
	3. Use git rm <file> or git rm -r <folder>/* to remove content as needed
	4. Use git add <file> to add a file (NEVER do a git add all).
	5. Perform a git commit and then a git push.

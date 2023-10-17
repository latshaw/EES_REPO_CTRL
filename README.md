# EES_REPO_CTRL
Welcome to the JSA Repository Page. This is a public repository page contianing information needed to properly use github repos. We can use this as a playground in which to add experimental updates and forks. 
This is a local update, try to push to remote.

Instructions for converting your existing Quartus project someting to place on gitlab:


1. Make a copy of your project, this is your staging folder
2. Open your PROJECT.qpf quartus project
3. Go to Project > Generate TCL File for Project, which will generate PROJECT.tcl file 
	1. Keep this the same as your PROJECT name
	2. Look at the generated file and remove anything that does not need to be there
4. Copy in the get_files.py helper program
5. Close quartus and open up gitbash in the staging folder
6. Run python get_files.py -c -s -f PROJECT.tcl 
7. Check if there are any warnings or errors and fix if necessary
8. In your staging folder open the git_repo folder
	1. Make sure that no .jic or large files are present (use: find . -type f -name "*.jic")
	2. Add the PROJECT.tcl file that was created
	3. Rename this git_repo to the folder that you want to show up in gitlab, LLRF3_SYTEM/FCC/HPA/RES/INT/ETC
9. If you do not have a current working version of the git repository:
	1. Create a new folder called GIT_STAGING
	2. Open gitbash and run: git clone https://github.com/latshaw/EES_REPO_CTRL.git
	3. Copy over the LLRF3_SYSTEM
	4. In git bash run git commit -m 'insert your useful message here'
	5. Then also run git push
	6. If there are no error messages then your repo is now online! :)
10. If you are working from a already cloned project
	1. To update your local repo with the remote one follow these steps:
		a. git fetch origin
  		b. git reset --hard origin
    	c. git clean -fd
	3. Use 'git status' to display helpful messages
	4. Use git rm <file> or git rm -r FOLDER/* to remove content as needed
	5. Use git add <file> to add a file (NEVER do a git add all)
	6. Perform a git commit and then a git push.


Insturctions to generate FPGA laod files:
It is recommend to use this template to make a script:

```
#!/bin/bash

GIT_ID_FULL=$(git rev-parse HEAD)
GIT_ID=${GIT_ID_FULL:0:8}

TCL=$(ls | grep *.tcl)
PROJECT="${TCL%.*}"

echo 'GENERATING PROJECT '$PROJECT' FROM GIT REPO COMMIT ID '$GIT_ID_FULL'...'


quartus_sh -t $TCL
quartus_sh --flow compile $PROJECT
cd output_files
quartus_cpf -o auto_create_rpd=on -c -d MT25QU01G -s 10CX105Y $PROJECT.sof $PROJECT'_'$GIT_ID.jic

echo 'DONE!'
```

OR if you prefer lots of typing, you can use git bash to run the following manual commands:

1. quartus_sh -t PROJECT.tcl
2. quartus_sh --flow compile PROJECT
3. cd output_files
4. run this in gitbash, git rev-parse HEAD  and keep just the first 8 characters. Call it GIT_ID
4. quartus_cpf -o auto_create_rpd=on -c -d MT25QU01G -s 10CX105Y resonance_control_fpga_rev_pr.sof GIT_ID.jic

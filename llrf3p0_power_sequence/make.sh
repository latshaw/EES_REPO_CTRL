#!/bin/bash
#change for quartus 19.1 LITE for max10
echo "TEMP CHANGE TO PATH FOR QUARTUS 18.1 LITE"
export PATH="/c/intelFPGA_lite\18.1\quartus\bin64\:$PATH" 
GIT_ID_FULL=$(git rev-parse HEAD)
GIT_ID=${GIT_ID_FULL:0:8}

TCL=$(ls | grep *.tcl)
PROJECT="${TCL%.*}"

echo 'GENERATING PROJECT '$PROJECT' FROM GIT REPO COMMIT ID '$GIT_ID_FULL'...'


quartus_sh -t $TCL
quartus_sh --flow compile $PROJECT
cd output_files
#note project auto generates .pof, the below just renames it
cp $PROJECT.pof $PROJECT'_'$GIT_ID.pof
echo 'DONE!'

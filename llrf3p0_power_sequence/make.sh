#!/bin/bash

GIT_ID_FULL=$(git rev-parse HEAD)
GIT_ID=${GIT_ID_FULL:0:8}

TCL=$(ls | grep *.tcl)
PROJECT="${TCL%.*}"

echo 'GENERATING PROJECT '$PROJECT' FROM GIT REPO COMMIT ID '$GIT_ID_FULL'...'


quartus_sh19 -t $TCL
quartus_sh19 --flow compile $PROJECT
cd output_files
quartus_cpf19 -o auto_create_rpd=on -c -d MT25QU01G -s 10CX105Y $PROJECT.sof $PROJECT'_'$GIT_ID.jic

echo 'DONE!'

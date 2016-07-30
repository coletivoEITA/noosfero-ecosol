#!/bin/bash

cd public/designs/themes/cirandas-themes
git checkout master
git pull --rebase

# update theme's submodules
#cd colivre-themes
#git checkout master
#git pull --rebase;
#cd ..
#git commit colivre-themes -m "Update colivre"

cd ../../../..
git commit public/designs/themes -m 'Update themes'

# push all
git push --recurse-submodules=on-demand


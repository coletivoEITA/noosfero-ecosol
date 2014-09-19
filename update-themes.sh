#!/bin/bash

# update colivre themes
cd public/designs/themes/cirandas-themes/colivre-themes
git pull --rebase;

cd ..
git commit colivre-themes -m "Update colivre"
cd ../../../..
git commit public/designs -m 'Update themes'

# push all
git push --recurse-submodules=on-demand


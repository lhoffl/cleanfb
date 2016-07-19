#!/bin/bash

git add .
git commit -m 'i'
git push -u origin master
echo lhoffl
echo ${args[0]}

bundle exec rake release 
echo lhoffl
echo ${args[0]}
echo lhoffl
echo ${args[0]}

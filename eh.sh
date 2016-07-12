#!/bin/bash

git add .
git commit -m 'i'
git push -u origin master

bundle exec rake release 

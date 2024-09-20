#!/bin/bash
#
# Script to download a bunch of stuff from svtplay. Relies heavily on
# svtplay-dl. In this script we use docker to run it, smart ey!
# 
# Author: deegan@monkii.net, https://github.com/deegan
# 

# make sure we have the latest version.
docker pull spaam/svtplay-dl

# Full path to where you want to store are you svtplay goodness.
STORAGE=$(pwd)

# enter the root path.
cd $STORAGE

# handle some input in case we just want to add a single show.
if [ $1 ]; then  
  show=$1
  if [ ! -d $STORAGE/$show ]; then
      mkdir $STORAGE/$show
  fi 
  pwd 
  cd $STORAGE/$show
  docker run -d --rm --name svtplay_$show -u $(id -u):$(id -g) -v "$(pwd):/data" spaam/svtplay-dl -A https://svtplay.se/$show &
else
  # This can be a file either local or remote, you decide. Formating is simple
  # you add one show per line which matches with what svtplay uses. 
  # example: masterflygarna = https://www.svtplay.se/masterflygarna
  showlist=$(curl https://raw.githubusercontent.com/deegan/barntv/master/shows)
  
  # Loop through the list, checking if the show path already exists. If not then
  # create the directory and cd into it. If it does exist then just cd into it
  # and start running the docker image.
  for show in $showlist; do
      if [ ! -d $STORAGE/$show ]; then
          mkdir $STORAGE/$show
      fi 
      pwd 
      cd $STORAGE/$show
      docker run -d --rm --name svtplay_$show -u $(id -u):$(id -g) -v "$(pwd):/data" spaam/svtplay-dl -A https://svtplay.se/$show &
      sleep 1 # this is very silly. But spawning containers too fast may cause them to not come up with a network connection and subsequently dies.
  done
fi

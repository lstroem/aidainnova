#!/bin/bash

##
# Utility script for creating a new document directory from the template
##

show_usage() {
  echo "Usage:"
  echo "    createNewDoc.sh [-h] [-p path] name"
  echo "Options:"
  echo "  -h  --help    Shows this help"
  echo "  -p  --path    Sets the base path for the new directory"
  echo "Creates a new note directory of the given name at the given path (default is ../)."
}

# defaults
noteName=""
basePath=..

# The files in copyList will be copied to the node directory
copyList="build.sh"

# The contents of the following directories will be copied.
# The directories themselves are created in the note directory
copyDirList="bibliography"

# Empty dirs will be created in the note directory for the items in this list
copyEmptyDirList="figures include"

# The files of types listed under linkList will be soflinked, so 
# that there is a unique copy of these contents on the system. Thus any
# updates of these contents need be done only once for all future work.
linkList="*.sty"

# The contents of the following directories will be soflinked 
# for the same reason as above.
# The directories themselves are created in the note directory, so 
# additional content specific to the new note can be added.
linkDirList="logos"

# name of the template file
templateName=AIDAinnova_template.tex

# treat command line options
if [ $# -eq 0 ]; then
  show_usage
  return
fi
while test $# -gt 0; do
  arg=${1//[[:space:]]}
  if [ $arg = "-h" ] || [ $arg = "--help" ]; then
    show_usage
    return
  elif [ $arg = "-p" ] || [ $arg = "--path" ]; then
    shift
    basePath=$1
  else
    noteName=$arg
  fi
  shift
done
if [ -z $noteName ]; then
  show_usage
  return
fi

notePath=${basePath%%/}/$noteName

# check if the target directory already exists
if [ -d $notePath ]; then
  echo "ERROR: $notePath already exists!"
  return
fi

# create the new note directory
mkdir -p $notePath

# check if the target directory has been properly created
if [ ! -d $notePath ]; then
  echo "ERROR: could not create $notePath!"
  return
fi

# Copy all required objects
for object in $copyList; do
  cp -r $object $notePath/
done

# Copy contents of directories
for dir in $copyDirList; do
  mkdir $notePath/$dir
  for object in $(ls $dir)
  do
    cp -r $(pwd)/$dir/$object $notePath/$dir/$object
  done
done

# Copy empty directories
for dir in $copyEmptyDirList; do
  mkdir $notePath/$dir
done

# Link objects for which global updates are desired
for object in $linkList; do
  ln -sf $(pwd)/$object $notePath/$object
done

# Link contents of directories for which global updates are desired
for dir in $linkDirList; do
  mkdir $notePath/$dir
  for object in $(ls $dir)
  do
    ln -sf $(pwd)/$dir/$object $notePath/$dir/$object
  done
done

# copy the actual template, change title and remove example content
sed -e 's#^\\title{.*}#\\title{'$noteName'}#;/\\input{.*tex}/d' $templateName > $notePath/$noteName.tex

echo "Created new directory here: $notePath"

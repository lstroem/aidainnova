#!/bin/bash

##
# Utility script for compiling latex files
# Christian Grefe (christian.grefe@cern.ch)
##

# treat command line options
for arg in $@; do
    if [ $arg = "-h" ] || [ $arg = "--help" ]; then
	echo "Usage:"
	echo "    build.sh [-h] [file1.tex] [file2.tex] [...]"
	echo "Options:"
	echo "  -h  --help    Shows this help"
	echo "If no file name is provided builds all available tex files."
	return
    elif [ -z $arg ]; then
	texFiles="$texFiles $arg"
    fi
done

if [ -z $texFiles ]; then
    texFiles=`ls *.tex`
fi

# set the latex compiler
latexCompiler=pdflatex
bibCompiler=biber
bibFlags=--output-safechars

# check if latex compilers are available
if ! hash $latexCompiler 2>/dev/null; then
    echo "ERROR: can not execute \"$latexCompiler\" check your environment setup!"
    return
fi
if ! hash $bibCompiler 2>/dev/null; then
    echo "ERROR: can not execute \"$bibCompiler\" check your environment setup!"
    return
fi

# compile all tex files
for texFile in $texFiles; do
    if [ -f $texFile ]; then
	$latexCompiler $texFile
	$bibCompiler $bibFlags ${texFile%%.tex}
	$latexCompiler $texFile
    else
	echo "ERROR: \"$texFile\" does not exist!"
    fi
done
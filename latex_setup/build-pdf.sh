#!/bin/bash
# Build PDF from LateX

file="$1"

if [ -e "$file" ]
then
    echo "File Exists"
    echo "Starting Build of $file"
    docker run --rm --name latexbuild -v "$(pwd)/:/docs" -w /docs docker.io/3n3a/latex latexmk -bibtex -pdf -file-line-error -halt-on-error -interaction=nonstopmode -shell-escape -auxdir=/docs/build -outdir=/docs/build "$file"
else
    echo "File $file not found."
    echo "Please specify a file that exists"
    exit 1
fi

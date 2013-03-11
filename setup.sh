#!/bin/bash

for file in \.*; do 
    if [[ ${file} == ".." || ${file} == "." ]]; then
        continue;
    fi
    if [[ -f "${HOME}/${file}" ]]; then
        if [[ `diff -q ${file} ${HOME}/${file}` ]]; then
            echo mv "${file}" "${file}.`date +%Y`"
        fi
    fi
    echo ln -s "${file}" "${HOME}/${file}"
done

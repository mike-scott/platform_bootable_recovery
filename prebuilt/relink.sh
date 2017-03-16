#!/bin/bash

process_file()
{
    dst=$1/sbin/$(basename $2)
    src=$2

    if [[ $src == *".so" ]]; then
       if [[ $src == *"/lib64/"* ]]; then
            dst=$1/lib64/$(basename $2)
       elif [[ $src == *"/lib/"* ]]; then
            dst=$1/lib/$(basename $2)
       fi
    fi

    if [ $dst == $src ]; then
      cp -f -p $src $src.tmp
      src=$2.tmp
    else
      cp -f -p $src $dst
    fi

    mkdir -p $(dirname $dst)
    sed "s|/system/bin/linker64\x0|/sbin/linker64\x0\x0\x0\x0\x0\x0\x0|g" $src | sed "s|/system/bin/linker\x0|/sbin/linker\x0\x0\x0\x0\x0\x0\x0|g" | sed "s|/system/bin/sh\x0|/sbin/sh\x0\x0\x0\x0\x0\x0\x0|g" | sed "s|/system/lib64\x0|/sbin\x0\x0\x0\x0\x0\x0\x0\x0\x0|g" | sed "s|/system/lib\x0|/sbin\x0\x0\x0\x0\x0\x0\x0|g" > $dst

    if [[ $src == *".tmp" ]]; then
      rm -f $src
    fi
}


dest=$1
shift 1
for ARG in $*
do
    process_file $dest $ARG
done

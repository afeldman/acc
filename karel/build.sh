#!/usr/bin/env bash

TARGET=./build

rm -Rf $TARGET
mkdir ${TARGET}
bnfc -m --haskell -o $TARGET karel.cf
cd $TARGET
make 
make clean

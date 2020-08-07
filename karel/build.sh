#!/usr/bin/env bash

TARGET=./build

rm -Rf $TARGET
bnfc -m -l --ghc -o $TARGET karel.cf
cd $TARGET
make 
make clean

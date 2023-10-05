#!/bin/sh

set -xe

CC=g++
CFLAGS="-Wall -Wextra -std=c++11"
LIBS=
SRC=tegazi.cc
BIN=tegazi

$CC $CFLAGS $SRC -o $BIN $LIBS

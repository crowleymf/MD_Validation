#!/bin/sh

NAMD=$HOME/src/NAMD_2.8_Linux-x86_64

$NAMD/charmrun ++local +p1 $NAMD/namd2 md.conf > md.log

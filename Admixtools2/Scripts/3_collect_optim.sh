#!/bin/bash -l

DIR="/cfs/klemming/projects/supr/sllstore2017093/mammoth/marianne/GIT/data_BCM/ADMIXTOOLS/Chukochya"

cd $DIR/graphs

readlink -f *.Rdata > Rdata.txt

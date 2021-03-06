#!/bin/bash

for file in `ls /lustre/cms/store/user/defilip/ZprimeAnalysis/Spring16_ZprimeMuMu_13TeV_merged/*TTT*.root`; do
echo $file
cat checkentries.C | sed "s?filename?${file}?g" > tmp.C
g++ -I $ROOTSYS/include tmp.C `root-config --glibs` `root-config --libs` `root-config --cflags` -o checkentries
./checkentries

done


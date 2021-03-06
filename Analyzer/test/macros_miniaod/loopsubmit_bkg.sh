#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$4" == "" ] || [ "$4" == "" ]; then
    echo "Please provide arguments to the script: site configuration, data type and MC type"
    echo "Usage bash loopsubmit_bkg_<finalstate>.sh <arg1> <arg2> <arg3> <arg4>"
    exit      
fi



echo "$1 configuration";
echo "$2 data"
echo "$3 simulation"
echo "$4 site"

SCERN="CERN";
SFNAL="FNAL";
SDESY="DESY";
SBARI="BARI";

mkdir -p jobs;

###### Background
n=0;
m=0;

echo "Reading bkg_input_$3_AN.txt file"

cp -f bkg_input_$3_AN.txt bkg_input.txt
nlines=`wc -l bkg_input_$3_AN.txt | awk '{print $1}'`;

while [ $n -lt ${nlines} ]; do
  (( n = n + 1 ))
  (( m = ${nlines} - n ))
  echo $n $m
  mkdir -p BkgCards$3
  rm -f BkgCards$3/bkg_input_${n}.txt
  cat bkg_input.txt | head -1 > BkgCards$3/bkg_input_${n}.txt
  samplename=`cat BkgCards$3/bkg_input_${n}.txt | awk '{print $1}'`
  echo $samplename
  cat bkg_input.txt | tail -n $m >  bkg_input_tmp.txt
  mv  bkg_input_tmp.txt bkg_input.txt
  rm -f jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
  rm -f jobs/condor_template.cfg

  if [ $4 = ${SCERN} ]; then
      cat submit_ZprimeMuMuAnalysis_CERN.sh | sed "s?which?bkg?g" | sed "s?site?$4?g" | sed "s?mc?$3?g" |sed "s?year?$2?g" | sed "s?ZprimeMuMuAnalysis?RunZprimeMuMuAnalysis?g" | sed "s?jobdir?jobs/jobsZprimeMuMu?g" | sed "s?histodir?histos/histosZprimeMuMu?g" | sed "s?output?output_${samplename}?g" | sed "s?bkg_input.txt?BkgCards$3/bkg_input_${n}.txt?g" | sed "s?s.log?s_${samplename}.log?g" > jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
  elif  [ $4 = ${SFNAL} ]; then 
      cat submit_ZprimeMuMuAnalysis_FNAL.sh  | sed "s?path?$PATH?g"  | sed "s?lib?$LD_LIBRARY_PATH?g" | sed "s?which?bkg?g" | sed "s?site?$4?g" | sed "s?mc?$3?g" |sed "s?year?$2?g" | sed "s?jobdir?jobs/jobsZprimeMuMu?g" | sed "s?histodir?histos/histosZprimeMuMu?g" | sed "s?output?output_${samplename}?g" | sed "s?bkg_input.txt?bkg_input_${n}.txt?g" | sed "s?s.log?s_${samplename}.log?g" > jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
      cat condor_template.cfg  | sed "s?submit_ZprimeMuMuAnalysis_FNAL?submit_ZprimeMuMuAnalysis_${samplename}?g" | sed "s?sig_input_h150.txt?BkgCards$3/bkg_input_${n}.txt?g" | sed "s?mail?`whoami`?g" > jobs/condor_ZprimeMuMuAnalysis_${samplename}.cfg      
  elif  [ $4 = ${SDESY} ]; then
     cat submit_ZprimeMuMuAnalysis_DESY.sh | sed "s?which?bkg?g" | sed "s?site?$4?g" | sed "s?mc?$3?g" |sed "s?year?$2?g" | sed "s?jobdir?jobs/jobsZprimeMuMu?g" | sed "s?histodir?histos/histosZprimeMuMu?g" | sed "s?output?output_${samplename}?g" | sed "s?bkg_input.txt?BkgCards$3/bkg_input_${n}.txt?g" | sed "s?s.log?s_${samplename}.log?g" > jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
  elif  [ $4 = ${SBARI} ]; then
      cat submit_ZprimeMuMuAnalysis_BARI.sh  | sed "s?path?$PATH?g"  | sed "s?lib?$LD_LIBRARY_PATH?g" | sed "s?which?bkg?g" | sed "s?site?$4?g" | sed "s?mc?$3?g" |sed "s?year?$2?g" | sed "s?jobdir?jobs/jobsZprimeMuMu?g" | sed "s?histodir?histos/histosZprimeMuMu?g" | sed "s?output?output_${samplename}?g" | sed "s?bkg_input.txt?bkg_input_${n}.txt?g" | sed "s?s.log?s_${samplename}.log?g" > jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
      cat condor_template.cfg  | sed "s?submit_ZprimeMuMuAnalysis_BARI?submit_ZprimeMuMuAnalysis_${samplename}?g" | sed "s?sig_input_h150.txt?BkgCards$3/bkg_input_${n}.txt?g" | sed "s?mail?`whoami`?g" > jobs/condor_ZprimeMuMuAnalysis_${samplename}.cfg
  else
      cat submit_ZprimeMuMuAnalysis.sh | sed "s?which?bkg?g" | sed "s?mc?$3?g" |sed "s?year?$2?g" | sed "s?jobdir?jobs/jobsZprimeMuMu?g" | sed "s?histodir?histos/histosZprimeMuMu?g" | sed "s?output?output_${samplename}?g" | sed "s?bkg_input.txt?BkgCards$3/bkg_input_${n}.txt?g" | sed "s?s.log?s_${samplename}.log?g" > jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh
  fi

  chmod u+xr jobs/submit_ZprimeMuMuAnalysis_${samplename}.sh

  cd jobs

  if [ $4 = ${SCERN} ]; then
      echo "Submitting jobs via LSF at CERN"
      bsub -q 8nh  submit_ZprimeMuMuAnalysis_${samplename}.sh
  elif  [ $4 = ${SFNAL} ]; then
      echo "Submitting jobs via CONDOR at FNAL"
      condor_submit  condor_ZprimeMuMuAnalysis_${samplename}.cfg
  elif  [ $4 = ${SDESY} ]; then
      echo "Submitting jobs via SGE"
      qsub  -l h_rt="10:00:00" submit_ZprimeMuMuAnalysis_${samplename}.sh   
   elif  [ $4 = ${SBARI} ]; then
      echo "Submitting jobs via CONDOR at BARI"
      condor_submit  -name ettore condor_ZprimeMuMuAnalysis_${samplename}.cfg
  else
      echo "Submitting jobs via PBS"    
      qsub -q local submit_ZprimeMuMuAnalysis_${samplename}.sh
  fi
  cd ..
done 


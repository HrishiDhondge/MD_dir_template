#!/bin/sh
# example use (for assembly/crystals)--> bash download_pdb.sh 2rs2 true
# example use (for NMR/normal pdb file) --> bash download_pdb.sh 2rs2 false

url="wget https://files.rcsb.org/download/"
id="${1}.pdb"
assembly="${id}1.gz"

if [ "$2" == true ]
then
    eval "${url}${assembly}"
    eval "gunzip ${assembly}"
else
    eval "${url}${id}"
fi

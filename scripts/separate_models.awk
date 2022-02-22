#! /bin/awk -f
# usage: awk -f separate_models.awk < pdb_file.pdb
# usage: awk -v model="17" -f ../scripts/separate_models.awk < 2RS2.pdb
# usage: ../scripts/separate_models.awk -v model=17 < 2RS2.pdb
# All models will be written in current directory
 BEGIN {file = 1; filename = "model_"  file ".pdb"}
 /ENDMDL/ {getline; file ++; filename = "model_" file ".pdb"}
 {if (file == model) print $0 > filename}
 #{ print $0 > filename}


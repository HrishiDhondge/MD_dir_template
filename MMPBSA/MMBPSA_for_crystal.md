# Compute free energy for Protein-RNA complex (after docking) 
From docking (or any complex), we have a structure (.pdb) containing receptor (Protein) and ligand (RNA) in bound state. Separate the receptor and ligand in different files.  

To run MMPBSA we need following files:
1. Topology of receptor (Protein)
2. Topology of ligand (RNA)
3. Topology of bound complex (Protein-RNA)
4. Topology of solvated complex 
5. The trajectory file

For cluster -->  

```
module load singularity
singularity run --nv --bind /data1/hdhondge/MMPBSA_crystal:/MMPBSA/  /softs/singimg/amber16_cuda
```
where `/data1/hdhondge/MMPBSA_crystal/` is the directory with `Protein-aa.pdb` and `RNA-aa.pdb`.  
Change the directory in Singularity 
```
cd /MMPBSA/
```

We will create all the topology files using `tleap` program from AMBER.

Start tleap
```
tleap
```

Load all the force fileds
```
source leaprc.protein.ff14SB 
source leaprc.RNA.OL3
source leaprc.DNA.OL15
source leaprc.gaff2
```

Load tip3p for waterbox
```
source leaprc.water.tip3p
```

Load molecules
```
prot = loadpdb Prot-aa.pdb
rna = loadpdb RNA-aa.pdb
```

Save topology of receptor and ligand separately.
```
saveamberparm prot protein.parm7 protein.rst7
saveamberparm rna rna.parm7 rna.rst7
```

Create the complex and save topology.
```
complex = combine {prot, rna}
saveamberparm complex complex.parm7 complex.rst7
```

Add waterbox & note down the volume.
```
solvateOct complex TIP3PBOX 5.0
```

Ionize the system - [Follow this tutorial to compute Molarity](http://ambermd.org/tutorials/basic/tutorial8/index.php)
```
addIonsRand complex Na+ 21 Cl- 21
```
Save the topology for solvated (+ ionized) complex
```
saveamberparm complex complex_solv.parm7 complex_solv.rst7
```
Quit tleap
```
quit
```

Create the input file for MMPBSA [ref](https://ambermd.org/tutorials/advanced/tutorial3/py_script/section6.htm)
`mmpbsa_per_res.in`
```
Per-residue GB and PB decomposition
&general
   endframe=1, verbose=1,
/
&gb
  igb=5, saltcon=0.150,
/
&pb
  istrng=150,
/
&decomp
  idecomp=1, print_res="290-295"
  dec_verbose=1,
/
```
Note: `# istrng Ionic strength in Molarity. It is converted to mM for PBSA and kept as M for APBS, Delphi.`

Run `MMPBSA.py` from AMBER using following command - 
```
$AMBERHOME/bin/MMPBSA.py -O -i mmpbsa_per_res.in -sp complex_solv.parm7 -cp complex.parm7 -rp protein.parm7 -lp rna.parm7 -y complex_solv.rst7
```

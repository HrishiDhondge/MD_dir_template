# MD_dir_template
Templates for amber force field in NAMD

## Preparing the system
1. Get PDB file
- From RCSB PDB 
	- Biological assembly is same as of first model.*
	- `wget https://files.rcsb.org/download/2RS2.pdb`
- Lookout for any non-standard residues used (like MSE)

2. Pre-processing of PDB file
- Find the most average NMR structure 
	(https://swift.cmbi.umcn.nl/servers/html/bestml.html)

- Separate the most average model (Use ./scripts/separate_models.awk )
- Check the sequence from structure with actual protein sequence
	- Download fasta sequence for the PDB file `wget https://www.rcsb.org/fasta/entry/2RS2/download -O 2RS2.fasta`
	- Split the downloaded PDB sequence into different chains `grep -A1 "Chain A" 2RS2.fasta > 2RS2_chain_A.fasta`

- PDBFixer to add any missing atoms 
	`pdbfixer MODEL.pdb --output=PDB_PROCESSED.pdb --add-residues --add-atoms=heavy --verbose`
- Modeller (only if required)

3. Separate chains (if any)
```
vmd -dispdev text PDB_PROCESSED.pdb
set sel1 [atomselect top "chain A and protein"]
set sel2 [atomselect top "chain B and nucleic"]
$sel1 writepdb protA.pdb
$sel2 writepdb rnaB.pdb
exit
```
- NOTE: If you are using PDBFixer after separating chains, be aware of [this issue](https://github.com/openmm/openmm/issues/3446). 
- In this case, you can simply delete the first line of PDB file for separated chains using `sed -i '1d' prot_A.pdb`.

4. Prepare topology and coordinate files
- Run pdb4amber for each separated chains.
`pdb4amber -i PDB_PROCESSED.pdb -o PDB_AMBER.pdb -y -d -l pdb4amber.log --leap-template`

- Start tleap to prepare topology, coordinates
	Source/load all force fields
	- `source leaprc.protein.ff14SB`  #ff19SB
	- `source leaprc.RNA.OL3`
	- `source leaprc.DNA.OL15`
	- `source leaprc.gaff2`

5. Solvation and ionization 
- Load tip3p for waterbox
	- `source leaprc.water.tip3p`  #opc

- Load molecule and check charge of molecule
	- `prot = loadpdb prot_A.pdb`
	- `rna = loadpdb rna_B.pdb`

- Combine all loaded molecules together
	- `complex = combine {prot, rna}`

- Check charge of molecule and neutralize if needed
	- `charge complex`
	- (`addIons MOLECULE Na+ NUMBER`)

- Add waterbox 
	- `solvateOct complex TIP3PBOX 15.0`
	- Note down the volume 

- Save files for solvated system 
	- `saveamberparm complex PDB_solv.prmtop PDB_solv.inpcrd`

- Ionize the system (http://ambermd.org/tutorials/basic/tutorial8/index.php)
	- addIonsRand complex Na+ 27 Cl- 27

- Write topology and coordinate files 
	- `saveamberparm complex PDB_ion.prmtop PDB_ion.inpcrd`
	- `saveamberparm complex PDB_ion.parm7 PDB_ion.rst7`

- Quit tleap
	- `quit`


## Minimization
1. Set cellBasisVector 1, 2 and 3 based on the water box (https://ambermd.org/namd/namd_amber.html)
2. Set cellOrigin 
	- Open parm7 and rst7 files in VMD 
	- `set all [atomselect top all]`
	- `measure center $all`
	- Other way is difference between minmax of the system 
		- `measure minmax $all`
	- If you would like to move system to center origin 
		- `$all moveby [vecinvert [measure center $all]]`


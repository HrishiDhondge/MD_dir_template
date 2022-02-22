#!/bin/bash
#
#SBATCH --job-name="MD_001_RRM2_5X3Z"
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=6
#SBATCH --mail-user=<usermail>@gmail.com
#SBATCH --mail-type=BEGIN,END
#SBATCH --mem=10G
#SBATCH --nodelist=sb-node1


# Alternative for GPUs: --gres=gpu:1 or 2 (unspecified gpu)
#                       --gres=gpu:k40m:1 or 2 (gpus of sb-nodeX)
#                       --gres=gpu:p100:1
# p100 est faster than k40m, i guess 4x time

set -ue

module purge
module load namd3-cuda

echo $USER
# write in the scracth dir (means local, fastest than NFS /dataX) if you generate big files quickly (at lot I/O) 
#mkdir -p /scratch/$USER

# Minimization
namd3  +idlepoll +p 1 +setcpuaffinity +devices 0 01_Minimization.namd  > 01_Minimization.out

#Heating
cd ../02_heat/
namd3  +idlepoll +p 1 +setcpuaffinity +devices 0 02_Heating.namd > 02_Heating.out

# Equilibration NVT
cd ../03_equil_NVT/
namd3  +idlepoll +p 1 +setcpuaffinity +devices 0  03_Equilibration_NVT.namd > 03_Equilibration_NVT.out

# Equilibration NPT
cd ../03_equil_NPT/
namd3  +idlepoll +p 1 +setcpuaffinity +devices 0 03_Equilibration_NPT.namd  > 03_Equilibration_NPT.out

# Production run
cd ../04_prod/
namd3  +idlepoll +p 1 +setcpuaffinity +devices 0 04_Production.namd  > 04_Production.out

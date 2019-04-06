module load gromacs-plumed-adjmat/default


gmx_mpi grompp -f NVT.mdp -c <conf>.gro -p topol.top -pp processed.top

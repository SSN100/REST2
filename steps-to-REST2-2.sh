# Number of replicas
nrep=15

# effective temperature range
tmin=300
tmax=525

location=/sudarshan

# Building Geometric Progression
list=$(
awk -v n=$nrep \
    -v tmin=$tmin \
    -v tmax=$tmax \
  'BEGIN{for(i=0;i<n;i++){
    t=tmin*exp(i*log(tmax/tmin)/(n-1));
    printf(t); if(i<n-1)printf(",");
  }
}'
)
echo $list
rm -rf \#*

for((i=0;i<nrep;i++))
do
echo -e "Enterd in to the directory $i \n"
rm -rf replica.$i
mkdir replica.$i
cd replica.$i

# choose lambda as T[0]/T[i]
# remember that high temperature is equivalent to low lambda
  lambda=$(echo $list | awk 'BEGIN{FS=",";}{print $1/$'$((i+1))';}')
# process topology
# (if you are curious, try "diff topol0.top topol1.top" to see the changes)
  plumed partial_tempering $lambda < ${location}/processed.top > topol.top
# prepare tpr file
# -maxwarn is often needed because box could be charged
gmx_mpi grompp -o topol.tpr -f ${location}/NPT.mdp -p ./topol.top -c ${location}/NPT_out.part0002.gro

cd ../
done

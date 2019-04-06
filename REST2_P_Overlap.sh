#!/bin/bash

# no of replicas
nrep=15
# "effective" temperature range
tmin=300
tmax=525

# build geometric progression
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

for((i=0;i<nrep;i++))
do
lambda=$(echo $list | awk 'BEGIN{FS=",";}{print $1/$'$((i+1))';}') # Calculation of lambda
cd replica.${i}
    

#getting Epp and Epw from gromacs
/home/sudarshan/softwares/gromacs-5.1_s/bin/gmx_mpi energy -f NPT_out_REST2_WTMetD.edr -sum -o pp.xvg << EOF
44 45 46 47 0
EOF

/home/sudarshan/softwares/gromacs-5.1_s/bin/gmx_mpi energy -f NPT_out_REST2_WTMetD.edr -sum -o pw.xvg << EOF
48 49 50 51 0
EOF

#getting Epp+0.5*(1/lambda)**0.5*Epw
sed '1, 28d' pw.xvg | awk -v l=$lambda '{print 0.5*(1/l)**0.5*$2}' > pw-0.5.txt
sed '1, 28d' pp.xvg | awk '{print $2}' > pp.txt
ppl=$(cat pp.txt | wc -l)
head -n$ppl pw-0.5.txt > pw-0.5_2.txt
paste pp.txt pw-0.5_2.txt | awk '{print $1+$2}' > pp+0.5pw.txt


#Getting Histogram for all replicas
../histogram.x $ppl

cd ../

done
################# Yehhhh..It worked fine#############

#xmgrace replica.*/histogram.dat -free &

mkdir histogram
for((i=0;i<nrep;i++))
do cp replica.${i}/histogram.dat histogram/histogram_${i}.dat; done

#gnuplot script to plot in a file plot.gnp
cat >>plot.gnp<<EOF
reset
#set term png
#set output "All_histogram.png"
set border lw 2
set ylabel "Probability Distribution"
set xlabel "Potential Energy"
#set xrange [-6500:-3000]
set title "PE Overlap REST2" font' ,15'
plot "histogram_0.dat" u 1:2 w l lw 2 title'replica-0', "histogram_1.dat" u 1:2 w l lw 2 title'replica-1', "histogram_2.dat" u 1:2 w l lw 2 title'replica-2', "histogram_3.dat" u 1:2 w l lw 2 title'replica-3', "histogram_4.dat" u 1:2 w l lw 2 title'replica-4', "histogram_5.dat" u 1:2 w l lw 2 title'replica-5', "histogram_6.dat" u 1:2 w l lw 2 title'replica-6', "histogram_7.dat" u 1:2 w l lw 2 title'replica-7', "histogram_8.dat" u 1:2 w l lw 2 title'replica-8', "histogram_9.dat" u 1:2 w l lw 2 title'replica-9', "histogram_10.dat" u 1:2 w l lw 2 title'replica-10', "histogram_11.dat" u 1:2 w l lw 2 title'replica-11', "histogram_12.dat" u 1:2 w l lw 2 title'replica-12', "histogram_13.dat" u 1:2 w l lw 2 title'replica-13', "histogram_14.dat" u 1:2 w l lw 2 title'replica-14'
EOF

mv plot.gnp histogram/

#go to histogram directory
#then gnuplot & load "plot.gnp"

#instance: 0, 1, 2 (bc, nc, wc)
#temperature: 0, 1, 2 (bc, nc, wc)
#dc: val
nargs=$#
if [ $nargs -lt 4 ]
then
	echo "usage : $0 iindex tindex dcindex app" 
	exit
fi

wpath='../weather-multiple/data/'
tfile[0]='HI_Mauna_Loa_5_NN-2011'
tfile[1]='SD_Sioux_Falls_14_NN-2011'
tfile[2]='CA_Stovepipe_Wells_1_S-2011'

ipath='../varemu/power_model_data/45nm_'
ifile[0]='bc.txt'
ifile[1]='nc.txt'
ifile[2]='wc.txt'

wf="$wpath${tfile[$2]}"
if="$ipath${ifile[$1]}"

lstate="${ifile[$1]}"
linst="${tfile[$2]}"

lfile="${lstate:0:2}_${linst:0:2}_$3"

let "extra_param=(((($1<<16))|(($2<<8))|(($3))))"

#echo "-vextra $extra_param"

../varemu/qemu-linaro/arm-softmmu/qemu-system-arm -M lm3s6965evb -kernel $4 -singlestep -variability $if --serial stdio -temperature $wf -vlog ../results/kalman_baseline_vemu/$lfile -vextra $extra_param > ../results/kalman_baseline_app/$lfile

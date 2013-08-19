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
ifile[0]='rand_01.txt'
ifile[1]='rand_02.txt'
ifile[2]='rand_03.txt'
ifile[3]='rand_04.txt'
ifile[4]='rand_05.txt'
ifile[5]='rand_06.txt'
ifile[6]='rand_07.txt'
ifile[7]='rand_08.txt'
ifile[8]='rand_09.txt'
ifile[9]='rand_10.txt'

wf="$wpath${tfile[$2]}"
if="$ipath${ifile[$1]}"

lstate="${ifile[$1]}"
linst="${tfile[$2]}"

lfile="i${lstate:5:2}_${linst:0:2}"

let "extra_param=(((($1<<16))|(($2<<8))|(($3))))"

#echo "-vextra $extra_param"

../varemu/qemu-linaro/arm-softmmu/qemu-system-arm -M lm3s6965evb -kernel $6 -singlestep -variability $if --serial stdio -temperature $wf -vlog ../results/localization_novar_vemu/$lfile -vid $4 -vspeed $5 -vextra $extra_param > ../results/localization_novar_app/$lfile

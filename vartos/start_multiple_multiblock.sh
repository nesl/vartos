for iindex in `seq 0 2`
  do
  for tindex in `seq 0 2`
  do
  echo $iindex $tindex $dcindex
  sh start_single_multiblock.sh $iindex $tindex 0 freertos/apps/app3_dsp_multiblock/RTOSDemo.axf &
  done
done

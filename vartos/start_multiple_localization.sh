for iindex in `seq 0 7`
  do
  for tindex in `seq 0 2`
  do
  echo $iindex $tindex 
  sh start_single_localization.sh $iindex $tindex 0 $iindex 200 freertos/apps/app2_localization/RTOSDemo.axf &
  done
done

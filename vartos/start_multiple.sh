for iindex in `seq 0 2`
  do
  for tindex in `seq 0 2`
  do
    for dcindex in `seq 0 0`
    do 
      echo $iindex $tindex $dcindex
      sh start_single.sh $iindex $tindex $dcindex freertos/apps/app2_localization/RTOSDemo.axf &
    done
  done
done

../varemu/qemu-linaro/arm-softmmu/qemu-system-arm -M lm3s6965evb -kernel $1 -singlestep -variability ../varemu/power_model_data/$2 --serial stdio -temperature ../weather-multiple/data/$3 -vlog $4

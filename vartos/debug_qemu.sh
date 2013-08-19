../varemu/qemu-linaro/arm-softmmu/qemu-system-arm -M lm3s6965evb -kernel $1 -singlestep -variability ../varemu/power_model_data/instance_01.txt --serial stdio -S -s

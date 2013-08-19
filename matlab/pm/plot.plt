set datafile separator ","

wc='wc'
bc='bc'
nc='nc'

set key top left
set xlabel "Temperature (\312 C)"
set ylabel "Power (uW)"
set xrange [0:60]
plot wc u 1:($2*1000000) w l lw 4 t "Worst-Case", nc u 1:($2*1000000) w l lw 4 t "Nominal",  bc u 1:($2*1000000) w l lw 4 t "Best-Case"

set terminal postscript size 6,4 color
set output "sleep_power.eps"
replot
set terminal x11

set key top left
set xlabel "Temperature (\312 C)"
set ylabel "Power (mW)"
set xrange [0:60]
plot wc u 1:($3*1000) w l lw 4 t "Worst-Case", nc u 1:($3*1000) w l lw 4 t "Nominal",  bc u 1:($3*1000) w l lw 4 t "Best-Case"

set terminal postscript size 6,4 color
set output "active_power.eps"
replot
set terminal x11

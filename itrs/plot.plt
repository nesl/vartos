plot 'itrs.dat' u 1:2 smooth csplines lw 4 t 'Total Power', 'itrs.dat' u 1:3 smooth csplines lw 4 t 'Static Power'
set xrange [2009:2022]
set yrange [0:600]
set key left top
set xlabel 'Year'
set ylabel '% Variability'
set terminal postscript enhanced color "Helvetica" 16 size 9,5.5
set output 'itrs.eps'
replot
set terminal wxt
replot

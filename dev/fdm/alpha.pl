
set datafile separator ","
set title  "Alpha"
set ylabel "Alpha (deg)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:42 title "Alpha"


set datafile separator ","
set title  "Beta"
set ylabel "Beta (deg)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:43 title "Beta"

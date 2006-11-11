
set datafile separator ","
set title  "Altitude"
set ylabel "Altitude (ft)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:38 title "Altitude"

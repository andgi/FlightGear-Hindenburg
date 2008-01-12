
set datafile separator ","
set title  "Position"
set ylabel "(deg)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:44 title "Latitude",\
     "LZ-129_datalog.csv" using 1:45 title "Longitude"

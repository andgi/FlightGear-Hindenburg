
set datafile separator ","
set title  "Velocities"
set ylabel "(ft/sec)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:19 title "UBody (forward)",\
     "LZ-129_datalog.csv" using 1:20 title "VBody (side)",\
     "LZ-129_datalog.csv" using 1:21 title "WBody (down)",\
     "LZ-129_datalog.csv" using 1:18 title "Vtotal"

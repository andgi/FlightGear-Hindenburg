
set datafile separator ","
set title  "Orientation"
set ylabel "(deg)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:39 title "Phi (roll)",\
     "LZ-129_datalog.csv" using 1:40 title "Theta (pitch)",\
     "LZ-129_datalog.csv" using 1:41 title "Psi (heading)"

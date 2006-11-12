
set datafile separator ","
set title  "Throttles"
set ylabel "(norm.)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:118 title "Engine 1 (BL)",\
     "LZ-129_datalog.csv" using 1:119 title "Engine 2 (BR)",\
     "LZ-129_datalog.csv" using 1:120 title "Engine 3 (FL)",\
     "LZ-129_datalog.csv" using 1:121 title "Engine 4 (FR)"


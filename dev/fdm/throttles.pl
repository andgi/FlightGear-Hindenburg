
set datafile separator ","
set title  "Throttles"
set ylabel "(norm.)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:126 title "Engine 1 (BL)",\
     "LZ-129_datalog.csv" using 1:127 title "Engine 2 (BR)",\
     "LZ-129_datalog.csv" using 1:128 title "Engine 3 (FL)",\
     "LZ-129_datalog.csv" using 1:129 title "Engine 4 (FR)"


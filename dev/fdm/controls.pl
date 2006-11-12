
set datafile separator ","
set title  "Throttles"
set ylabel "(norm.)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:118 title "Throttle engine 1 (BL)",\
     "LZ-129_datalog.csv" using 1:119 title "Throttle engine 2 (BR)",\
     "LZ-129_datalog.csv" using 1:120 title "Throttle engine 3 (FL)",\
     "LZ-129_datalog.csv" using 1:121 title "Throttle engine 4 (FR)",\
     "LZ-129_datalog.csv" using 1:50 title "Elevator position",\
     "LZ-129_datalog.csv" using 1:53 title "Rudder position"



set datafile separator ","
set title  "Throttles"
set ylabel "(norm.)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:126 title "Throttle engine 1 (BL)",\
     "LZ-129_datalog.csv" using 1:127 title "Throttle engine 2 (BR)",\
     "LZ-129_datalog.csv" using 1:128 title "Throttle engine 3 (FL)",\
     "LZ-129_datalog.csv" using 1:129 title "Throttle engine 4 (FR)",\
     "LZ-129_datalog.csv" using 1:50 title "Elevator position",\
     "LZ-129_datalog.csv" using 1:53 title "Rudder position"


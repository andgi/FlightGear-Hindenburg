
set datafile separator ","
set title  "Pitch AP"
set ylabel "(various)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:40 title "Theta (pitch)",\
     "LZ-129_datalog.csv" using 1:50 title "Elevator position",\
     "LZ-129_datalog.csv" using 1:66 title "Pitch AP Linear",\
     "LZ-129_datalog.csv" using 1:67 title "Pitch AP Integrator",\
     "LZ-129_datalog.csv" using 1:68 title "Pitch AP Derivator"


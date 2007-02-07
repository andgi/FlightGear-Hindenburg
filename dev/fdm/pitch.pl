
set datafile separator ","
set title  "Pitch AP"
set ylabel "(various)"
set xlabel "Time (sec)"
plot \
     "LZ-129_datalog.csv" using 1:40 title "Theta (pitch deg)"\
    ,"LZ-129_datalog.csv" using 1:42 title "Alpha (deg)"\
    ,"LZ-129_datalog.csv" using 1:50 title "Elevator position"\
    ,"LZ-129_datalog.csv" using 1:63 title "Pitch setpoint (rad)"\
    ,"LZ-129_datalog.csv" using 1:64 title "Pitch error (rad)"\
#    ,"LZ-129_datalog.csv" using 1:63 title "Pitch AP Linear"\
#    ,"LZ-129_datalog.csv" using 1:64 title "Pitch AP Integrator"\
#    ,"LZ-129_datalog.csv" using 1:64 title "Pitch AP Derivator"\


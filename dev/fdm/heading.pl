
set datafile separator ","
set title  "Heading AP"
set ylabel "(various)"
set xlabel "Time (sec)"
plot \
     "LZ-129_datalog.csv" using 1:54 title "Heading (degrees)"\
    ,"LZ-129_datalog.csv" using 1:53 title "Rudder position (norm.)"\
    ,"LZ-129_datalog.csv" using 1:107 title "Heading Setpoint (degrees)"\
    ,"LZ-129_datalog.csv" using 1:57 title "Heading Error (degrees)"\
    ,"LZ-129_datalog.csv" using 1:43 title "Beta (degrees)"\
#    ,"LZ-129_datalog.csv" using 1:58 title "Heading AP PID"\
#    ,"LZ-129_datalog.csv" using 1:58 title "Heading AP Linear"\
#    ,"LZ-129_datalog.csv" using 1:59 title "Heading AP Integrator"\
#    ,"LZ-129_datalog.csv" using 1:60 title "Heading AP Derivator"



set datafile separator ","
set title  "Heading AP"
set ylabel "(various)"
set xlabel "Time (sec)"
plot "LZ-129_datalog.csv" using 1:41 title "Psi (heading)",\
     "LZ-129_datalog.csv" using 1:53 title "Rudder position",\
     "LZ-129_datalog.csv" using 1:57 title "Heading Error",\
     "LZ-129_datalog.csv" using 1:58 title "Heading AP Linear",\
     "LZ-129_datalog.csv" using 1:59 title "Heading AP Integrator",\
     "LZ-129_datalog.csv" using 1:60 title "Heading AP Derivator"


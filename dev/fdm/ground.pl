
set datafile separator ","
set title  "Gear loads"
set ylabel "Vertical load (lbs)"
set xlabel "Time (sec)"
plot \
     "LZ-129_datalog.csv" using 1:69 title "Control car wheel"\
    ,"LZ-129_datalog.csv" using 1:80 title "Lower fin wheel"\

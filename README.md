# Multiplot

Tools like Ganglia are very important in system administratrion because it allows us to see trends in resource utilization, but sometimes, can be useful have the freedom to manipulate the graphs, like ploting more than one graph together. 

## Usage

The script plot up to 6 _rrd_ files in a single graph. It accepts the width and height of the graph as parameter.

For example generating a graph 600 x 200 pixels with `user` and `system` CPU utilization

```
mgarcia@mordor:~/Documents/Work/multiplot$ ./rrd_multiplot.sh \               
> -w 600 \
> -g 200 \
> data/teta1/cpu_user.rrd \
> data/teta1/cpu_system.rrd
mg: size: 600 x 200
681x255
Have a nice day.
mgarcia@mordor:~/Documents/Work/multiplot$ 
```

At the moment, the graph is put in `graph` directory with the name `multiplot.png`. The legends for the graph is the name of the data source. 

## TODO

Next steps:

1. Legend for the graphs.

1. Path and name for the output graph.
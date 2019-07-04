#!/usr/bin/env bash
# Graph 'rrd' files from Ganglia.
# Using this site as example:
# rrdtool.vandenbogaerdt.nl/tutorial/graph.php
# Marcelo Garcia.

readonly PROGRAM=${0##*/}
readonly RRDTOOL=/usr/bin/rrdtool

# Color picker
# https://htmlcolorcodes.com/color-names/
readonly MY_COLORS=(\#FF0000 \#0000FF \#008000 \#C71585 \#9370DB \#A52A2A \#708090)

function print_array {
    MY_ARRAY=("$@")
    len=${#MY_ARRAY[@]}
    for (( ii=0; ii<len; ii++ )); do
        echo "${MY_ARRAY[$ii]}"
    done
}

##
## Main 
## 

# Provide the command line options in a array.
readonly CMD_OPTS=( "$@" )

help_note_text="Syntax: $PROGRAM [-h|--help] or [-w|--width] [-g|--height] rrd1, rrd2,...,rrd6"

if ! OPTS="$( getopt -n $PROGRAM -o "hw:g:" -l "help,width,height:" -- "$@" )"; then
    echo "$help_note_text"
    exit 1
fi
readonly OPTS
eval set -- "$OPTS"
while true; do
    case "$1" in 
        (-h|--help)
            echo "$help_note_text"
            exit 1 
            ;;
        (-w|--width)
            if [[ "$2" == -* ]]; then
                # When the item that follows '-w' starts with a '-'
                # it is considered to be the next option and not an...
                # argument for '-c':
                echo "-w requires an argument."
                echo "$help_note_text"
                exit 1
            fi
            GRAPH_WIDTH=$(echo "$2" | bc)
            shift
            ;;
        (-g|--height)
            if [[ "$2" == -* ]]; then
                # When the item that follows '-g' starts with a '-'
                # it is considered to be the next option and not an...
                # argument for '-g':
                echo "-g requires an argument."
                echo "$help_note_text"
                exit 1
            fi
            GRAPH_HEIGHT=$(echo "$2" | bc)
            shift
            ;;
        (--)
            shift
            break
            ;;
        (-*)
            echo "$PROGNAME: unrecognized option '$option'"
            echo "$help_note_text"
            exit 1
        (*)
            break
            ;;
    esac
    shift
done

readonly RRD_FILES=( "$@" )

# Plot the graph.
ii=1
cc=0
PLOT_NAME=./graphs/multiplot.png
RRD_FIRST=`rrdtool first ${RRD_FILES[0]}`
RRD_LAST=`rrdtool last ${RRD_FILES[0]}`
RRD_PLOT_CMD="${RRDTOOL} graph ${PLOT_NAME} "
RRD_PLOT_CMD="${RRD_PLOT_CMD} --start $RRD_FIRST --end $RRD_LAST "
# Check if "width" wasn't define, use default value.
if [ -z ${GRAPH_WIDTH} ]; then
    GRAPH_WIDTH=640
fi
RRD_PLOT_CMD="${RRD_PLOT_CMD} --width $GRAPH_WIDTH "
# Check if "height" is defined or not.
if [ -z ${GRAPH_HEIGHT} ]; then
    GRAPH_HEIGHT=480
fi
RRD_PLOT_CMD="${RRD_PLOT_CMD} --height $GRAPH_HEIGHT "
echo "mg: size: $GRAPH_WIDTH x $GRAPH_HEIGHT"
for ff in ${RRD_FILES[@]}; do
    RRD_PROPERTY=`basename $ff .rrd`
    RRD_PLOT_CMD="${RRD_PLOT_CMD} DEF:ds${ii}=${ff}:sum:AVERAGE "
    RRD_PLOT_CMD="${RRD_PLOT_CMD} LINE${ii}:ds${ii}${MY_COLORS[cc]}:${RRD_PROPERTY}"
    ((ii++))
    ((cc++))
done

eval $RRD_PLOT_CMD

# The End.
echo "Have a nice day."
exit 0

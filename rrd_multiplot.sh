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

help_note_text="Use '$PROGRAM --help' for more information."
if ! OPTS="$( getopt -n $PROGRAM -o "hs:" -l "help,size:" -- "$@" )"; then
    echo "$help_note_text"
    exit 1
fi
readonly OPTS
eval set -- "$OPTS"
while true; do
    case "$1" in 
        (-h|--help)
            echo "$help_note_text"
            ;;
        (-s|--size)
            if [[ "$2" == -* ]]; then
                # When the item that follows '-c' starts with a '-'
                # it is considered to be the next option and not an...
                # argument for '-c':
                echo "-c requires an argument."
                echo "$help_note_text"
                exit 1
            fi
            GRAPH_SIZE="$2"
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

if [ "$#" -eq 0 ]; then 
    echo "No parameters"
    exit 1
else
    echo "Parameters left: $#"
fi

readonly RRD_FILES=( "$@" )
echo "mg. RRD_FILES: ${RRD_FILES[@]}"

# Print array.
print_array "${RRD_FILES[@]}"

# Plot the graph.
ii=1
cc=0
PLOT_NAME=./graphs/multiplot.png
RRD_FIRST=`rrdtool first ${RRD_FILES[0]}`
RRD_LAST=`rrdtool last ${RRD_FILES[0]}`
RRD_PLOT_CMD="${RRDTOOL} graph ${PLOT_NAME} "
RRD_PLOT_CMD="${RRD_PLOT_CMD} --start $RRD_FIRST --end $RRD_LAST "
RRD_PLOT_CMD="${RRD_PLOT_CMD} --width 640 --height 480 "
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

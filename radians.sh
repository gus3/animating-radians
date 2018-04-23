#!/bin/bash

function draw_frame() {
	ITER=$1 ; ANNOT=${2:-""}
	# first, constants: one radian X and Y
	XRAD=.54030230586813971740
	YRAD=.84147098480789650665
	# conversions
	RADDEG=57.2957795
	DEGRAD=.017453292
	# and of course
	PI=3.14159265358979

	# here's the heavy lifting
	echo "set term png size 640,640
	set output
	set xrange [-1:2*$PI*$YRAD]
	set yrange [-1:2*$PI*$YRAD]
	set object 1 circle at 0,0 size 1 arc [0:$ITER*$RADDEG]
	set object 2 circle at 0,0 size 0.95 fs solid 1.0 fc bgnd
	set object 3 polygon from 0,0 to $XRAD*$ITER,$YRAD*$ITER to 0,0
	set label \"$ITER\" at 1,1
	set label \"$ANNOT\" at 2,0
	plot -2" | gnuplot > frames/frame-$ITER.png
	
	# if annotated, pause for 2 seconds
	if [ ! -z "$ANNOT" ] ; then
		for i in `seq -f "%02.0f" 2 50` ; do
			ln frames/frame-$ITER.png{,-$i}
		done
	fi
}

# initializer: make or clean frames/ directory
if [ -d frames ] ; then
	rm -rf frames
fi
mkdir frames

for RAD in `seq 0 5` ; do
	( for CRAD in `seq -f "%02.0f" 0 98` ; do
		draw_frame $RAD.$CRAD
	done ) &
done
( for CRAD in `seq -f "%02.0f" 0 29` ; do
	draw_frame 6.$CRAD
done ) &
wait

# re-render a few frames, pausing for annotations
draw_frame 1.00 "chord length = radius, 1 radian"
draw_frame 3.14 "pi radians, 180 degrees"
draw_frame 6.28 "circumference = 2 * pi * radius"

# then pause it for 2 seconds

# now, animate them. fps is arbitrary but shouldn't be > 30
mencoder "mf://frames/*.png*" -mf fps=25 -o output.mp4 -of lavf -ovc lavc -lavcopts vcodec=mpeg4


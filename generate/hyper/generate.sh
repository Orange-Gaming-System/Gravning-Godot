#!/bin/bash -xe

declare -a strs=(H Y P E R)

boundsize=1024
animsize=16
animcount=16
centertest=false

outfile="$(echo "${strs[*]}" | tr -cd '[-a-zA-Z0-9_]')".png
rm -f "$outfile"

declare -a imgs

for str in "${strs[@]}"; do
    rm -f "$str".*.{pov,png}

    cat > "$str".bound.pov <<EOF
#version 3.7;
#declare Text = "$str";
#declare Degrees = 0.0;
#declare X = clock;
#declare Y = clock;
#declare Scale = 1.0;
#include "text.inc"
EOF
    povray -D +I"$str".bound.pov +w$boundsize +h$boundsize bound.ini

    # width height leftpos downpos
    declare -a b0=($(magick "$str".bound0.png -format '%@' info: | tr '+x' '  '))
    declare -a b1=($(magick "$str".bound1.png -format '%@' info: | tr '+x' '  '))

    cat > "$str".anim.pov <<EOF
#version 3.7;
#declare Text = "$str";
#declare Degrees = clock*360.0;
#declare X = ($boundsize-${b0[0]}-2*${b0[2]})/(2*(${b1[2]}-${b0[2]}));
#declare Y = ($boundsize-${b0[1]}-2*${b0[3]})/(2*(${b1[3]}-${b0[3]}));
#declare Scale = $boundsize*7/8/((${b0[1]}+${b1[1]})/2);
#include "text.inc"
EOF

    if $centertest; then
	povray +I"$str".test.pov +w$boundsize +h$boundsize +K0.0 bound.ini
    fi

    povray -D +I"$str".anim.pov +w$animsize +h$animsize +KFI0 +KFF$animcount \
	   +SF0 +EF$((animcount-1)) anim.ini

    imgs+=("$str".anim*.png)
done

montage "${imgs[@]}" -alpha set -background none -geometry +0+0 \
	-tile ${animcount}x${#strs[@]} "$outfile"

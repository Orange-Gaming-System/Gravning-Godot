#!/bin/bash

declare -a static=(ghost-stopped-trans.png ghost-right-trans.png
                   ghost-left-trans.png ghost-down-trans.png
                   ghost-up-trans.png ghost-frozen-trans.png)
declare -a thaw

rm -rf tmp
mkdir -p tmp

count=15

./gradients.pl $count

for ((i = 1; i <= $count ; i++)); do
    n=$(printf 'tmp/grad%02d' $i)
    magick ghost-thawing-frozen-gradient-noalpha.png \
	   "$n.pgm" -compose copy-alpha \
	   -composite "$n.g.png"
    magick ghost-thawing-ghostcolor.png "$n.g.png" \
	   ghost-thawing-eyes.png -flatten "$n.f.png"
    magick "$n.f.png" ghost-thawing-bodymask-greyscale.png \
	   -compose copy-alpha -composite "$n.t.png"
    thaw+=("$n.t.png")
done
montage "${thaw[@]}" -alpha set -background none -geometry +0+0 \
	    -tile ${count}x1 tmp/thaw.png
montage "${static[@]}" -alpha set -background none -geometry +0+0 \
        -tile "${#static[@]}"x1 tmp/static.png
montage tmp/static.png tmp/thaw.png -alpha set -background none \
	-geometry +0+0 -tile 1x2 ghosts.png

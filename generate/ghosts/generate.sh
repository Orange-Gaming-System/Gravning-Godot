#!/bin/bash

declare -a directions=(stopped right left down up)

rm -rf tmp
mkdir -p tmp

ghostcolor='#02008f'
frozecolor='#7f9bff'
thawcount=16

magick -size 16x16 "xc:$ghostcolor" tmp/live.png
magick -size 16x16 "xc:$frozecolor" tmp/froz.png

declare -a static
for d in "${directions[@]}"; do
    df="tmp/$d"
    magick tmp/live.png eyes-"$d".png -flatten "$df.s.png"
    magick "$df.s.png" bodymask.png -compose copy-alpha -composite "$df.png"
    static+=("$df.png")
done

magick tmp/froz.png eyes-stopped.png -flatten "tmp/frozen.s.png"
magick "tmp/frozen.s.png" bodymask.png -compose copy-alpha -composite \
       "tmp/frozen.png"
static+=("tmp/frozen.png")

./gradients.pl $thawcount

declare -a thaw
for ((i = 1; i <= $thawcount ; i++)); do
    n=$(printf 'tmp/grad%02d' $i)
    magick tmp/froz.png "$n.pgm" -compose copy-alpha -composite "$n.g.png"
    magick tmp/live.png "$n.g.png" eyes-stopped.png -flatten "$n.f.png"
    magick "$n.f.png" bodymask.png -compose copy-alpha -composite "$n.t.png"
    thaw+=("$n.t.png")
done
montage "${thaw[@]}" -alpha set -background none -geometry +0+0 \
	    -tile ${thawcount}x1 tmp/thaw.png
montage "${static[@]}" -alpha set -background none -geometry +0+0 \
        -tile "${#static[@]}"x1 tmp/static.png
montage tmp/static.png tmp/thaw.png -alpha set -background none \
	-geometry +0+0 -tile 1x2 ghosts.png

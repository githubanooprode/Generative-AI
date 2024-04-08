#!/bin/bash

OLDDIR=$(pwd)
RESDIR=~/Desktop/Inpainting2017
CRIMDIR=~/Desktop/InpaintingArchive/FinalResults_May_31_2017/AllImages
mkdir -p /tmp/tmpImage


cp -f $RESDIR\/results_2017_June_12/$1* /tmp/tmpImage/
cp -f $RESDIR\/results_2017_June_15/$1* /tmp/tmpImage/
cp -f $RESDIR\/results_2017_June_16/$1* /tmp/tmpImage/
cp -f $RESDIR\/results_2017_June_19/$1* /tmp/tmpImage/
cp -f $RESDIR\/results_2017_June_22/$1* /tmp/tmpImage/
cp $CRIMDIR/$1_Amoeba0* /tmp/tmpImage

echo $1

cd /tmp/tmpImage
halfwidth=$(convert  $1_Amoeba0_StandardBox_PatchRadiusRange1-1_*.png -format "%[fx:floor(w/2)]" info:)
halfheight=$(convert $1_Amoeba0_StandardBox_PatchRadiusRange1-1_*.png -format "%[fx:floor(h/2)+10]" info:)
halfheight2=$(($halfheight * 3 + 40))
halfheight3=$(($halfheight * 5 + 40))
halfheight4=$(($halfheight * 7 + 40))
halfheight5=$(($halfheight * 9 + 40))
halfheight6=$(($halfheight * 11 + 40))


images="1 2 3 4 5 6 "


#Criminisi
for lookAtMe in $images; do
    patternMe="$1_Amoeba0_StandardBox_PatchRadiusRange$lookAtMe-$lookAtMe\_*.png"
    files=( $patternMe)
    test -f ${files[0]}  && myImage[$lookAtMe]=${files[0]}  || myImage[$lookAtMe]="null:" 
    echo $lookAtMe ${myImage[lookAtMe]}
done
		

convert  ${myImage[1]}  ${myImage[2]}  ${myImage[3]}  ${myImage[4]}  ${myImage[5]}  ${myImage[6]} \
 -set page '+0+%[fx:t*u.h+20*(t+1)]'   \
 -background white -layers merge  +repage  \
 -splice 0x40 -font Arial -pointsize 36 -annotate +180+30 'Criminisi' \
 -splice 100x0 -annotate +50+${halfheight} 'R1' \
 -annotate +50+${halfheight2} 'R2' \
 -annotate +50+${halfheight3} 'R3' \
 -annotate +50+${halfheight4} 'R4' \
 -annotate +50+${halfheight5} 'R5' \
 -annotate +50+${halfheight6} 'R6' \
  Crim.png

echo



#Amoeba Threshold 5, physical distance 0.5
for lookAtMe in $images; do
    patternMe="$1_Amoeba1_SeparateSearchBox_PatchRadiusRange$lookAtMe-$lookAtMe\_AmoebaThreshold5_physicalDistance0.50_*.png"
    files=( $patternMe)
    test -f ${files[0]}  && myImage[$lookAtMe]=${files[0]}  || myImage[$lookAtMe]="null:" 
    echo $lookAtMe ${myImage[lookAtMe]}
done

if  [ ${myImage[6]} == "null:" ] ; then
    myImage[6]="null: null:"
fi

convert  ${myImage[1]}  ${myImage[2]}  ${myImage[3]}  ${myImage[4]}  ${myImage[5]}  ${myImage[6]}  \
	 -set page '+0+%[fx:t*u.h+20*(t+1)]' -background white -layers merge +repage -splice 0x40 -font Arial -pointsize 36 \
	 -annotate +80+30 'Amoeba T5, P 0.5' A05PD05.png




echo 
#Amoeba Threshold 10, physical distance 1.0
for lookAtMe in $images; do
    patternMe="$1_Amoeba1_SeparateSearchBox_PatchRadiusRange$lookAtMe-$lookAtMe\_AmoebaThreshold10_physicalDistance1.00_*.png"
    files=( $patternMe)
    test -f ${files[0]}  && myImage[$lookAtMe]=${files[0]}  || myImage[$lookAtMe]="null:" 
    echo $lookAtMe ${myImage[lookAtMe]}
done

if  [ ${myImage[6]} == "null:" ] ; then
    myImage[6]="null: null:"
fi

convert  ${myImage[1]}  ${myImage[2]}  ${myImage[3]}  ${myImage[4]}  ${myImage[5]}  ${myImage[6]}  \
	 -set page '+0+%[fx:t*u.h+20*(t+1)]' -background white -layers merge +repage -splice 0x40 -font Arial -pointsize 36 \
	 -annotate +80+30 'Amoeba T10, P 1.0'  A10PD10.png





echo 
#Amoeba Threshold 20, physical distance 1.0
for lookAtMe in $images; do
    patternMe="$1_Amoeba1_SeparateSearchBox_PatchRadiusRange$lookAtMe-$lookAtMe\_AmoebaThreshold20_physicalDistance1.00_*.png"
    files=( $patternMe)
    test -f ${files[0]}  && myImage[$lookAtMe]=${files[0]}  || myImage[$lookAtMe]="null:" 
    echo $lookAtMe ${myImage[lookAtMe]}
done

if  [ ${myImage[6]} == "null:" ] ; then
    myImage[6]="null: null:"
fi

convert  ${myImage[1]}  ${myImage[2]}  ${myImage[3]}  ${myImage[4]}  ${myImage[5]}  ${myImage[6]}  \
	 -set page '+0+%[fx:t*u.h+20*(t+1)]' -background white -layers merge +repage -splice 0x40 -font Arial -pointsize 36 \
	 -annotate +80+30 'Amoeba T20, P 1.0'  A20PD10.png





#total image
montage Crim.png  A05PD05.png A10PD10.png A20PD10.png -tile x1 -geometry +10+10 ~/Desktop/$1_Compare.png

cp ~/Desktop/$1_Compare.png $OLDDIR/

#!/bin/bash

#USAGE:sh ./start_dwc.sh [ IMAGE_FILE | "ALL"] [ SETTINGS_FILE | "ALL"]

#sh start_dwc.sh eagle settings_1to50_mag1_match1_weigth5_noMex.setting
#sh start_dwc.sh eagle ./settings/settings_1to50_mag1_match1_weigth5_blend0_noMex.setting

patchFixed="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
patchMin="1"
patchMax="20"
amoebaMax="10 20 40"
physicalDistance=".1 1 2"

numColorGradientFails=0;
numColorGradientFails_source=0;

doColorSeparate=1;
useNewColorPriority=1;
chooseStrongestPriortiyGradient=0;
magnitudeWeight=2;
testOnlyNewPixels="0"
FillIn1="FillIn_CreateAndUseDynamicSourcePatch";
FillIn2="FillIn_UseTargetPatch";

numBins="6 30"
images="eagle bicycle1 bungee1 butterfly butterfly2 car2 cat colosseum glasses mochizuki mountains3 penguins pigeons soccer tiger twobirds"
macFile=MachineSettings11.txt

#CRIM (fixed Target and Source)
#for myImage in $images; do
#    for pixMe in $patchFixed; do
#	for histSize in $numBins; do
#	    echo \'useAmoeba\',0 '\n'\
#		 \'numColorGradientFails\',$numColorGradientFails '\n'\
#		 \'numColorGradientFails_source\',$numColorGradientFails_source '\n'\
#		 \'doColorSeparate\',$doColorSeparate '\n'\
#		 \'useNewColorPriority\',$useNewColorPriority '\n'\
#		 \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
#		 \'magnitudeWeight\',$magnitudeWeight '\n'\
#		 \'testOnlyNewPixels\', $testOnlyNewPixels'\n'\
#		 \'numBins\', $histSize '\n'\
#		 \'patch_radius_min\',$pixMe '\n'\
#		 \'patch_radius_max\', $pixMe > dctemp_boboCrim.setting
#	    ./start_dwc_6b.sh $myImage dctemp_boboCrim.setting $macFile
#	done
#   done
#done


#Dyn target Patch, fixed source
for myImage in $images; do
    for histSize in $numBins; do
	echo \'useAmoeba\',0 '\n'\
	     \'numColorGradientFails\',$numColorGradientFails '\n'\
	     \'numColorGradientFails_source\',$numColorGradientFails_source '\n'\
	     \'doColorSeparate\',$doColorSeparate '\n'\
	     \'useNewColorPriority\',$useNewColorPriority '\n'\
	     \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
	     \'magnitudeWeight\',$magnitudeWeight '\n'\
	     \'testOnlyNewPixels\', $testOnlyNewPixels'\n'\
	     \'numBins\', $histSize '\n'\
	     \'FillIn\',  \'$FillIn2 \'  '\n'\
	     \'patch_radius_min\',$patchMin '\n'\
	     \'patch_radius_max\',$patchMax > dctemp_DTP.setting
	./start_dwc_6b.sh $myImage dctemp_DTP.setting $macFile
    done
done

#fixed target plus dynamic source patch
for myImage in $images; do
    for pixMe in $patchFixed; do
	for histSize in $numBins; do
	    echo \'useAmoeba\',0 '\n'\
		 \'numColorGradientFails\',$numColorGradientFails '\n'\
		 \'numColorGradientFails_source\',$numColorGradientFails_source '\n'\
		 \'doColorSeparate\',$doColorSeparate '\n'\
		 \'useNewColorPriority\',$useNewColorPriority '\n'\
		 \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
		 \'magnitudeWeight\',$magnitudeWeight '\n'\
		 \'testOnlyNewPixels\', $testOnlyNewPixels'\n'\
		 \'numBins\', $histSize '\n'\
		 \'FillIn\',  \'$FillIn1\'  '\n'\
		 \'patch_radius_min_source\',$patchMin '\n'\
		 \'patch_radius_min_source\',$patchMax '\n'\
		 \'patch_radius_min\',$pixMe '\n'\
		 \'patch_radius_max\', $pixMe > dctemp_DSP.setting
	    ./start_dwc_6b.sh $myImage dctemp_DSP.setting $macFile
	done
    done
done


#Dyn target Patch + dynamic source patch
for myImage in $images; do
    for histSize in $numBins; do
	echo \'useAmoeba\',0 '\n'\
	     \'numColorGradientFails\',$numColorGradientFails '\n'\
	     \'numColorGradientFails_source\',$numColorGradientFails_source '\n'\
	     \'doColorSeparate\',$doColorSeparate '\n'\
	     \'useNewColorPriority\',$useNewColorPriority '\n'\
	     \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
	     \'magnitudeWeight\',$magnitudeWeight '\n'\
	     \'testOnlyNewPixels\', $testOnlyNewPixels'\n'\
	     \'numBins\', $histSize '\n'\
	     \'FillIn\',  \'$FillIn1 \'  '\n'\
	     \'patch_radius_min_source\',$patchMin '\n'\
	     \'patch_radius_min_source\',$patchMax '\n'\
	     \'patch_radius_min\',$patchMin '\n'\
	     \'patch_radius_max\',$patchMax > dctemp_DTPDSP.setting
	./start_dwc_6b.sh $myImage dctemp_DTPDSP.setting $macFile
    done
done



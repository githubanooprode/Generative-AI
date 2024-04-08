#!/bin/bash

#USAGE:sh ./start_dwc.sh [ IMAGE_FILE | "ALL"] [ SETTINGS_FILE | "ALL"]

#sh start_dwc.sh eagle settings_1to50_mag1_match1_weigth5_noMex.setting
#sh start_dwc.sh eagle ./settings/settings_1to50_mag1_match1_weigth5_blend0_noMex.setting

patchMin="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"
amoebaMax="20 40"
physicalDistance="0.5 1 2"
numColorGradientFails=2;
doColorSeparate=1;
useNewColorPriority=1;
chooseStrongestPriortiyGradient=0;
magnitudeWeight=2;

images="car2 twobirds"


#CRIM
#for pixMe in $patchMin; do
#    echo \'useAmoeba\',0 '\n'\
#	 \'patch_radius_min\',$pixMe '\n'\
#	 \'numColorGradientFails\',$numColorGradientFails '\n'\
#	 \'doColorSeparate\',$doColorSeparate '\n'\
#	 \'useNewColorPriority\',$useNewColorPriority '\n'\
#	 \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
#	 \'magnitudeWeight\',$magnitudeWeight '\n'\
#	 \'patch_radius_max\', $pixMe > dctemp_bobo206.setting
#    ./start_dwc_6b.sh $images dctemp_bobo206.setting MachineSettings9.txt
#done

#Static Patch Amoeba
#for phyDist in $physicalDistance; do
#    for amThres in $amoebaMax; do
#for pixMe in $patchMin; do
#	    echo \'useAmoeba\',1 '\n'\
#		 \'numColorGradientFails\',$numColorGradientFails '\n'\
#		 \'doColorSeparate\',$doColorSeparate '\n'\
#		 \'useNewColorPriority\',$useNewColorPriority '\n'\
#		 \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
#		 \'magnitudeWeight\',$magnitudeWeight '\n'\
#		 \'amoeba_max_distance\',$amThres '\n'\
#		 \'physicalDistance\',$phyDist '\n'\
#		 \'patch_radius_min\',$pixMe '\n'\
#		 \'patch_radius_max\', $pixMe > dctemp_bobo206.setting
#	    ./start_dwc_6b.sh $images dctemp_bobo206.setting MachineSettings9.txt
#	done
#  done
#done

patchMin="1 3"
patchMax="10 20 40"
#Dyn Patch Amoeba
for phyDist in $physicalDistance; do
    for pMin in $patchMin; do
	for pMax in $patchMax; do
	    for amThres in $amoebaMax; do
		echo    \'useAmoeba\',1 '\n'\
		     \'numColorGradientFails\',$numColorGradientFails '\n'\
		     \'doColorSeparate\',$doColorSeparate '\n'\
		     \'useNewColorPriority\',$useNewColorPriority '\n'\
		     \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
		     \'magnitudeWeight\',$magnitudeWeight '\n'\
		     \'amoeba_max_distance\',$amThres '\n'\
		     \'physicalDistance\',$phyDist '\n'\
		     \'patch_radius_min\',$pMin '\n'\
		     \'patch_radius_max\',$pMax > dctemp_bobo206.setting
		./start_dwc_6b.sh $images dctemp_bobo206.setting MachineSettings9.txt
	    done
	done
    done
done


#Dyn Patch standard
for phyDist in $physicalDistance; do
    for pMin in $patchMin; do
	for pMax in $patchMax; do
	    for amThres in $amoebaMax; do
		echo \'useAmoeba\',0 '\n'\
		     \'numColorGradientFails\',$numColorGradientFails '\n'\
		     \'doColorSeparate\',$doColorSeparate '\n'\
		     \'useNewColorPriority\',$useNewColorPriority '\n'\
		     \'chooseStrongestPriortiyGradient\',$chooseStrongestPriortiyGradient '\n'\
		     \'magnitudeWeight\',$magnitudeWeight '\n'\
		     \'amoeba_max_distance\',$amThres '\n'\
		     \'physicalDistance\',$phyDist '\n'\
		     \'patch_radius_min\',$pMin '\n'\
		     \'patch_radius_max\',$pMax > dctemp_bobo206.setting
		./start_dwc_6b.sh $images dctemp_bobo206.setting MachineSettings9.txt
	    done
	done
    done
done

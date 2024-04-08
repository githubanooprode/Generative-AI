function [settings]=testSettings(min_patch,max_patch)

%these change and are the core parameters
%amoeba
    
settings.useAmoeba=0; %1 or 0, yes or no
settings.useMultiAmoeba=0; %1 or 0, yes or no
if settings.useMultiAmoeba==1
    settings.useAmoeba=1;
    settings.FillIn= 'FillIn_ShiftWholeImage_multiAmoeba';
end

settings.amoeba_max_distance=15; %amoeba threshold.
settings.physicalDistance=.05;

%dynamic target patch (THE VOID)
settings.patch_radius_min=min_patch;
settings.patch_radius_max=max_patch;

%dynamic source patch (THE REST of the image)
settings.source_patch_radius_min=20;
settings.source_patch_radius_max=20 ;
%settings.FillIn= 'FillIn_CreateAndUseDynamicSourcePatch';
settings.FillIn= 'FillIn_ShiftWholeImage';

%dealing with three color channels
%how many color channels can have a change of angle before we stop growing.
%values are 0, 1, or other
settings.numColorGradientFails=1; 
settings.numColorGradientFails_source=1;
settings.doColorSeparate=1;
settings.useNewColorPriority=1;

%dealing with gradients
settings.chooseStrongestPriortiyGradient=0; %get the highest importance term.
settings.numBins=30; %histogram bins. All angles are between 0 and 180.
%for growth of dynamic box, should we see if the dominant gradient changed in the whole patch of just in the new pixels.
settings.testOnlyNewPixels=0; 
settings.magnitudeWeight=2; 


%_______________
%The variables below here rarely change. There are just listed here for
%documentation.

%these are all set to a default in the program, but I list them here as a
%sort of overview.

%These are not used any more
settings.badMatchThreshold=999; %if the search match is sooo bad, do not use it. 
settings.dir_distance_weight=0.0; %no idea.


%these rarely change
settings.machine='NoMachine';
settings.imagePath='target';
settings.inpainting_INFO='ImageInpainting_July2017';
settings.percent_search_box=false; %set max patch and amoeba distance at 2% of image size.
settings.voidBitThreshold=0.5; %no more than 50% of pixels in target patch can be in the void.
settings.IgnoreMagnitude=0; %when calculating the priority
settings.useGradientMagAverage=0; %what does this do again?
settings.matchMeanVsSum=1; %speed boost, uses the sum of the magnitudes, not the mean.
settings.localUpdate=1; %speed boost, only calc. new priority on the new portion of the contour

%double check this
settings.confidenceWeight= 0.9; %if the amoeba cannot get a pixel to fit in the void, drop the importance of the confidence term 

%I think this is no longer necessary, as we use just three pixels, but
%would need to rewirite the code to eliminate it.
settings.radiusForTangent=2; %minimum size of patch for calculating the tangent at the contour.


%these sometimes change, but usually only for debugging.
settings.display_progress=true; %show figures at each iteration
settings.saveStepImages=true; %save ieach iteration to files.
settings.saveStepImages_interval = 1;    %how often to save
formatOut = 'YYyy-mmmm-dd-HH_MM';
currentTime=datestr(now,formatOut);
settings.resultsDir=sprintf('~/Desktop/InPaintingResults/testResults_%s',currentTime);
%settings.resultsDir= '~/Desktop/tempResults/';
%settings.theImage='car2';
settings.theImage='top-min-28';
settings.blend=0; %percent of new to mix into old. 
%settings.blendDistanceFunction='getBlendPriorityDistanceFromContour_amoeba';
end


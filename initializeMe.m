function [settings,currentStep]=initializeMe(settings)

addpath(genpath('.'))
currentStep= [];

%Set default values
[settings]=setDefaultValues(settings);
[settings]=setDefaultFunctions(settings);

%convert to functions
currentStep.getBestMatch  = str2func(settings.getBestMatch);
currentStep.createAdaptivePatch = str2func(settings.createAdaptivePatch);
currentStep.localCalculatePriority = str2func(settings.calculatePriority);
currentStep.matchDistanceFunction = str2func(settings.matchDistanceFunction);
currentStep.blendDistanceFunction = str2func(settings.blendDistanceFunction);
currentStep.patchSizes=zeros(settings.patch_radius_max*settings.patch_radius_max*10,1);
currentStep.FillInFunction= str2func(settings.FillIn);

currentStep.newContour=0;
currentStep.lastPixel = [-1 -1];

if settings.localUpdate
    currentStep.BadPixelBank=zeros(2000,2);
    currentStep.numBad=0;    
else
    currentStep.BadPixelBank=[];
end

%if settings.source_patch_radius_min ~= settings.source_patch_radius_max
%  settings.FillIn ='FillIn_CreateAndUseDynamicSourcePatch';
%end

if settings.useAmoeba==1 
    currentStep.FillInFunction=str2func('FillIn_ShiftWholeImage');        
end


if settings.useMultiAmoeba==1
    settings.useAmoeba=1;
    currentStep.FillInFunction=str2func('FillIn_ShiftWholeImage_multiAmoeba');        
end


if strcmp(settings.FillIn,'FillIn_UseTargetPatch') || strcmp(settings.FillIn,'FillIn_CreateAndUseDynamicSourcePatch')
    settings.useAmoeba=0;
else if settings.useAmoeba==0 && ~strcmp(settings.FillIn,'FillIn_CreateAndUseDynamicSourcePatch')
        currentStep.FillInFunction=str2func('FillIn_UseTargetPatch');        
    end
end
end


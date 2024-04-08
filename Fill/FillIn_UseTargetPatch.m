function [settings,currentStep] = FillIn_UseTargetPatch(settings,currentStep)
if strcmp(settings.blendDistanceFunction, 'getBlendPriorityOnlyOutsideTarget')
    blendPriority = currentStep.blendDistanceFunction(currentStep.targetArea3Color, currentStep.confidence3Color,currentStep);
else
    blendPriority=0;
end

targetPatchLab = settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX, :);
sourcePatchLab = settings.initialLabImage(currentStep.sourcePatchY,currentStep. sourcePatchX, :);
unknown_area = currentStep.targetArea3Color(currentStep.targetPatchY, currentStep.targetPatchX,:);
known_area = ~unknown_area;

alphaMeAchoo=1-settings.blend;
settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX,:) = ...
    (targetPatchLab .* known_area).*(alphaMeAchoo) + ...
    ( sourcePatchLab .* known_area).*settings.blend + ...
    sourcePatchLab .* unknown_area;

%figure(2);
%ArmyAnt2=lab2rgb(initialLabImage(targetPatchY, targetPatchX,:));
%imshow(ArmyAnt2);

currentStep.targetArea3Color(currentStep.targetPatchY, currentStep.targetPatchX,:) = 0;
patchConfidence = currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX,1);
newConfidence = sum(patchConfidence(:)) / currentStep.targetPatchSize;
% lower boundry = 1/200 (should never be 0)
if newConfidence < 1/200
    newConfidence = 1/200;
end
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 1) = known_area(:,:,1) .* patchConfidence + unknown_area(:,:,1) .* newConfidence;
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 2) = known_area(:,:,2) .* patchConfidence + unknown_area(:,:,2) .* newConfidence;
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 3) = known_area(:,:,3) .* patchConfidence + unknown_area(:,:,3) .* newConfidence;



lab_progress=settings.initialLabImage;
lab_progress(currentStep.sourcePatchY,currentStep.sourcePatchX,1) = (lab_progress(currentStep.sourcePatchY,currentStep.sourcePatchX,1)).*100 ;
lab_progress(currentStep.targetPatchY,currentStep.targetPatchX,:) = lab_progress(currentStep.targetPatchY,currentStep.targetPatchX,:) .* known_area*2  + unknown_area *80;
saveMeImage = lab2rgb(lab_progress);
fName=sprintf('%s/%s_step%.5d.png',settings.resultsDir,settings.output_image,currentStep.step_number);

if settings.display_progress
    if(any(findall(0,'Type','Figure')==3))
        set(0,'CurrentFigure',3);
    else
        myFig=figure(3);
        %set(myFig, 'Position' , [1   settings.screenSize(4)/2  settings.screenSize(3)/2 settings.screenSize(4)/2]);
    end
    ArmyAnt2=lab2rgb(lab_progress);
    imshow(ArmyAnt2);
end

if settings.saveStepImages && ~mod(currentStep.step_number, settings.saveStepImages_interval)
    imwrite(saveMeImage,fName,'png','Author','Cunningham and gang','Comment','This image has been altered by inpainting');
end
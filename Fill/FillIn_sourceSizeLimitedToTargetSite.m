function [settings,currentStep] = FillIn_sourceSizeLimitedToTargetSite(settings,currentStep)
%%*****OLD VERSION: Just copy a target sized patch            
%Amoeba is maximally the size of the search(target) patch, and
%starts somewhere in the hole

if strcmp(settings.blendDistanceFunction, 'getBlendPriorityOnlyOutsideTarget')
    blendPriority = currentStep.blendDistanceFunction(currentStep.targetArea3Color, currentStep.confidence3Color,currentStep);
else
    blendPriority=0;
end

dont_blend=1-settings.blend;
targetPatchLab = settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX, :);
unknown_area = currentStep.targetArea3Color(currentStep.targetPatchY,currentStep.targetPatchX,:);
known_area = ~unknown_area;


sourcePatchLab = settings.initialLabImage(currentStep.sourcePatchY, currentStep.sourcePatchX, :);
centerY = currentStep.currentYPos-currentStep.targetPatchY(1)+1;
centerX = currentStep.currentXPos-currentStep.targetPatchX(1)+1;
% Center(s) of the amoeba: closest pixel to the center thatconfidence3Color \'s inside the target area
centers = placeCenterInsideTarget(centerY,centerX,currentStep.targetArea3Color(currentStep.targetPatchY,currentStep.targetPatchX,1));
[currentStep.amoeba_map,currentStep.amoeba_size] = CreateAmoeba(centers,sourcePatchLab(:,:,1),settings.amoeba_max_distance,settings);
currentStep.amoeba_map = repmat(currentStep.amoeba_map,1,1,3);
settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX,:) = ...
    (targetPatchLab .* known_area .* ~currentStep.amoeba_map) + ...
    (targetPatchLab .* known_area .* currentStep.amoeba_map)*(dont_blend) + ...
    (sourcePatchLab .* known_area .* currentStep.amoeba_map)*settings.blend.*blendPriority + ...
    sourcePatchLab .* unknown_area .* currentStep.amoeba_map;
patchConfidence = currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX,1);
%techically, this should be the sum of the patch confidences in
%the amoeba area BEFORE it is copies over...
newConfidence = sum(sum(patchConfidence.*currentStep.amoeba_map(:,:,1))) / currentStep.amoeba_size;

% lower boundry = 1/200 (should never be 0)
if newConfidence < 1/200
    newConfidence = 1/200;
end

%know stays as is. New amoeba in unknown gets new confidence.
%old unknown stays at 0
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 1) = known_area(:,:,1) .* patchConfidence + unknown_area(:,:,1) .* currentStep.amoeba_map(:,:,1).*newConfidence;
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 2) = known_area(:,:,2) .* patchConfidence + unknown_area(:,:,2) .* currentStep.amoeba_map(:,:,2).*newConfidence;
currentStep.confidence3Color(currentStep.targetPatchY, currentStep.targetPatchX, 3) = known_area(:,:,3) .* patchConfidence + unknown_area(:,:,3) .* currentStep.amoeba_map(:,:,3).*newConfidence;



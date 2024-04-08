function [currentStep] = doTargetPatch(settings,currentStep)

if settings.patch_radius_min == settings.patch_radius_max
    [currentStep.targetPatchY, currentStep.targetPatchX, currentStep.targetPatchSize] = createPatch(currentStep.currentYPos,...
        currentStep.currentXPos,  settings.patch_radius_min, size(settings.initialLabImage(:,:,1)));
    currentStep.targetPatchRadii=[settings.patch_radius_min, settings.patch_radius_min, settings.patch_radius_min, settings.patch_radius_min];
else
    [currentStep.targetPatchY, currentStep.targetPatchX, currentStep.targetPatchSize,  currentStep.targetPatchRadii] = currentStep.createAdaptivePatch(currentStep,settings);
end

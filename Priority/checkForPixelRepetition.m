function   [currentStep]= checkForPixelRepetition(settings, currentStep)

%if this is the second time in a row trying this pixel, then its best
%match does not fill in all the hole pixels nearby. So place it in the
%Bad Pixel Bank. Try anyway, but then skip it in the future.
if currentStep.currentYPos==currentStep.lastPixel(1) && currentStep.currentXPos==currentStep.lastPixel(2)
    if settings.localUpdate
        currentStep.numBad=currentStep.numBad+1;
        currentStep.BadPixelBank(currentStep.numBad,:)=[currentStep.currentYPos currentStep.currentXPos];
    else
        currentStep.BadPixelBank=[currentStep.BadPixelBank; currentStep.currentYPos currentStep.currentXPos];
    end
end
currentStep.lastPixel=[currentStep.currentYPos currentStep.currentXPos];


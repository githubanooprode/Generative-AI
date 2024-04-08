function  [max_priority,settings,currentStep,priority]= getMaxPriority(settings,currentStep,priority)

max_priority= max(priority(:));
if (max_priority > 0)
    [currentStep.currentYPos, currentStep.currentXPos] = find(priority == max_priority);
    %if more than one pixel has the same priority, use the first one
    currentStep.currentYPos = currentStep.currentYPos(1);
    currentStep.currentXPos = currentStep.currentXPos(1);
else
    fprintf('Zero Priority\n')
    currentStep.currentYPos = contour_Y(loopMe1);
    currentStep.currentXPos = contour_X(loopMe1);
    currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos)=currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos)+1;
    currentStep.mult=1 -.1*forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos);
    fprintf('\nforbidden: %d, multiplier set to %f\n', forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos),currentStep.mult);
    if currentStep.mult<0
        disp('ERROR: mutliplier for color term is negative...setting to zero');
        currentStep.mult=0;
    end
end
%if this is the second time in a row trying this pixel, then its best
%match does not fill in all the hole pixels nearby. So place it in the
%Bad Pixel Bank. Try anyway, but then skip it in the future.
if currentStep.currentYPos==lastPixel(1) && currentStep.currentXPos==lastPixel(2)
    if settings.localUpdate
        currentStep.numBad=currentStep.numBad+1;
        currentStep.BadPixelBank(numBad,:)=[currentStep.currentYPos currentStep.currentXPos];
    else
        currentStep.BadPixelBank=[currentStep.BadPixelBank; currentStep.currentYPos currentStep.currentXPos];
    end
end

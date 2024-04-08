function  [currentStep]= getNextPixel(currentStep,priority)

max_priority= max(priority(:));
if (max_priority > 0)
    [currentStep.currentYPos, currentStep.currentXPos] = find(priority == max_priority);
    %if more than one pixel has the same priority, use the first one
    currentStep.currentYPos = currentStep.currentYPos(1);
    currentStep.currentXPos = currentStep.currentXPos(1);
else
    fprintf('Zero Priority\n')
    currentStep.currentYPos = currentStep.contour_Y(1);
    currentStep.currentXPos = currentStep.contour_X(1);
    currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos)=currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos)+1;
    currentStep.mult=1 -.1*currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos);
    fprintf('\nforbidden: %d, multiplier set to %f\n', currentStep.forbiddenPatches(currentStep.currentYPos, currentStep.currentXPos),currentStep.mult);
    if currentStep.mult<0
        disp('ERROR: mutliplier for color term is negative...setting to zero');
        currentStep.mult=0;
    end
end

function [settings,currentStep,priority] = updateVariables(settings,currentStep,priority)

if settings.useAmoeba 
        oldContourInAmoeba=currentStep.targetContour3Color.* currentStep.shiftedAmoebaMap;
end

oldInside=sum(sum(currentStep.targetArea3Color(:,:,1)));

[currentStep.targetArea3Color,currentStep.targetContour3Color,targetContour2] = calculateContour(currentStep.confidence3Color);
[currentStep.myInitialGradientM,currentStep.myInitialGradientDir] = calculateGradient(settings.initialLabImage,targetContour2);
currentStep.contour_size=sum(sum(currentStep.targetContour3Color(:,:,1)));
newInside= sum(sum(currentStep.targetArea3Color(:,:,1)));
if settings.localUpdate && settings.useAmoeba
    %removeMe=~oldContourInAmoeba;
    %oldContourInAmoeba=currentStep.targetContour3Color.* currentStep.shiftedAmoebaMap;
    if oldInside==newInside
        %fprintf('ARGH, no pixels copied into the void. Bad Pixel.  %d vs %d\n',oldInside,newInside);
        currentStep.numBad=currentStep.numBad+1;
        currentStep.BadPixelBank(currentStep.numBad,:)=[currentStep.currentYPos currentStep.currentXPos];
    end
    jojo=imgradient(double(currentStep.shiftedAmoebaMap(:,:,1)),'CentralDifference');
    jojo(jojo>0)=1.0;
    currentStep.newContour=jojo.*currentStep.targetArea3Color(:,:,1);
    priority(oldContourInAmoeba(:,:,1)==1)=0;
    %priority(currentStep.currentYPos ,currentStep.currentXPos,:)=0;
end
currentStep.step_number = currentStep.step_number + 1;

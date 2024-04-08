function [currentStep,priority] = decideOnPriority(settings,currentStep,priority)

%get pixels that are on the contour, find total number of them
[contour_Y,contour_X] = find(currentStep.targetContour3Color(:,:,1) == 1);
newContourPixelSum=sum(currentStep.newContour(:));
[aa,bb,~]=size(currentStep.targetContour3Color);

%either do all priority or just  the new contour pixels
if settings.localUpdate==0
    priority = zeros(aa,bb);
else
    if  newContourPixelSum==0
        upToHere=currentStep.contour_size;
        priority = zeros(aa,bb);
    else
        upToHere=newContourPixelSum;
    end
end

%calculate the priority for each pixel in out todo list
for loopMe1 = 1:upToHere
    currentStep.contour_Y= contour_Y(loopMe1);
    currentStep.contour_X = contour_X(loopMe1);
    priority(currentStep.contour_Y, currentStep.contour_X)= currentStep.localCalculatePriority(currentStep,settings);
end

function [currentStep] = getBestMatchSSD_3color_dwc(settings,currentStep)
% Difference is sum of squares of differences for L,a,b for each pixel, each weighted by a priority factor.
% In its simplest form, this priority is 0 for pixels in the target area and otherwise 1
% It can however be used to give higher priority to pixel closer to the
% contour.
%hu!
%disp(size(target_patch_lab))

target_patch_lab= settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX, :);

match_priority = currentStep.matchDistanceFunction(currentStep);

best_match = [1,1,inf];
patch_height = size(settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX, :),1);
patch_width = size(settings.initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX, :),2);
patch_size = patch_height *patch_width;

Yprime=1 : patch_height ;
Xprime=1:patch_width;
for y = 1:(size(settings.initialLabImage,1) - patch_height +1)
    Y = y : (y + patch_height - 1);
    for x = 1:(size(settings.initialLabImage,2) - patch_width + 1)
        X = x : (x + patch_width - 1);
        if sum(sum(currentStep.confidence3Color(Y,X,1))) < patch_size % any confidence value in area < 1
            continue
        end
        %weighted_color_distance =sqrt( sum(sum(sum( (settings.initialLabImage(Y, X, :) - target_patch_lab ).^2  .* match_priority))));
        jojo=(settings.initialLabImage(Y, X, :) - target_patch_lab).^2  .* match_priority;
        
        %jojo=(settings.initialLabImage(Y, X, :) - target_patch_lab (Yprime,Xprime,:)).^2  .* match_priority;
        jojo2=sum(jojo,3);
        jojo3=sqrt(jojo2);
        if settings.matchMeanVsSum
            weighted_color_distance=sum(jojo3(:));
        else
            weighted_color_distance=mean(jojo3(:));
        end
        if weighted_color_distance < best_match(3)
            best_match = [y,x,weighted_color_distance];
            %msg=sprintf('Best mean distance so far= %f', weighted_color_distance);
            %disp(msg);
        end
        
    end
end

centrateMe_Y= currentStep.currentYPos - currentStep.targetPatchY(1) ;
centrateMe_X=currentStep.currentXPos - currentStep.targetPatchX(1) ;
currentStep.sourcePatchCenterY=best_match(1) + centrateMe_Y;
currentStep.sourcePatchCenterX=best_match(2) + centrateMe_X;

currentStep.sourcePatchY= (best_match(1): (best_match(1)+size(target_patch_lab,1)-1))';
currentStep.sourcePatchX= (best_match(2): (best_match(2)+size(target_patch_lab,2)-1))';

currentStep.sourcePatchY_orig= (best_match(1): (best_match(1)+size(target_patch_lab,1)-1))';
currentStep.sourcePatchX_orig= (best_match(2): (best_match(2)+size(target_patch_lab,2)-1))';
%msg=sprintf('Best mean distance overall= %f', best_match(3));
%disp(msg);
currentStep.matchDistance = best_match(3);
end
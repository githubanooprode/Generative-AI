function priority = calculatePriority_weighted_FullAmoeba(currentStep,settings)
%% find the normal to the curve (using the tangent and a 3x3 patch). 
%then make real patch (as long as it is not tooo small).
%use the patch to calculate the confidence
%since this is the same for all three color channels and is a percent,
%we can do it for one. 

if settings.patch_radius_min<settings.radiusForTangent
    useThisRadius=settings.radiusForTangent;
else
    useThisRadius=settings.patch_radius_min;
end
if(settings.useAmoeba)
    useThisRadius=settings.radiusForTangent;
end

[contour_normal_slope]=findNormal(currentStep.contour_Y,currentStep.contour_X,size(currentStep.confidence3Color(:,:,1)),currentStep.targetContour3Color(:,:,1));
[patch_Y, patch_X, patch_size, ~,~] = createPatch(currentStep.contour_Y,currentStep.contour_X, useThisRadius,size(currentStep.confidence3Color(:,:,1)));
confidence_term = sum(sum(currentStep.confidence3Color(patch_Y, patch_X,1))) / patch_size;
 
%% get the local gradient field. Ignore the bits in the target area
% this needs to be done for all three channels

if(settings.useNewColorPriority)
    %do data term calculation separately for each color channel
    [gradient_angle,gradient_magnitude3,~,~,~] = calculateDominantPatchAngle_separateColor(patch_Y, patch_X,currentStep,settings) ;
    gradSlope=zeros(2,3);
    gradient_angle2=gradient_angle*pi/180;
    if settings.IgnoreMagnitude
        gradSlope(:,1)=[sin(gradient_angle2(1)+pi/2), cos(gradient_angle2(1)+pi/2)]';
        gradSlope(:,2)=[sin(gradient_angle2(2)+pi/2), cos(gradient_angle2(2)+pi/2)]';
        gradSlope(:,3)=[sin(gradient_angle2(3)+pi/2), cos(gradient_angle2(3)+pi/2)]';
        %gradSlopeN=gradSlope./norm(gradSlope);
    else
        gradSlope(:,1)=[sin(gradient_angle2(1)+pi/2), cos(gradient_angle2(1)+pi/2)]'*gradient_magnitude3(1);
        gradSlope(:,2)=[sin(gradient_angle2(2)+pi/2), cos(gradient_angle2(2)+pi/2)]'*gradient_magnitude3(2);
        gradSlope(:,3)=[sin(gradient_angle2(3)+pi/2), cos(gradient_angle2(3)+pi/2)]'*gradient_magnitude3(3);
        %gradSlope=[sin(gradient_angle2+pi/2), cos(gradient_angle2+pi/2)]'*gradient_magnitude3;
    end
    normalSlopeN=contour_normal_slope./norm(contour_normal_slope);
    importance3(1)=abs(dot(gradSlope(:,1),normalSlopeN));
    importance3(2)=abs(dot(gradSlope(:,2),normalSlopeN));
    importance3(3)=abs(dot(gradSlope(:,3),normalSlopeN));
    
    %two options: pick the angle that is closest to 90 going straight into the
    %void or choose the angle that has the highest magnitude
    if settings.chooseStrongestPriortiyGradient
        myColorIndex= find(gradient_magnitude3 == max(gradient_magnitude3));
        importance=importance3(myColorIndex(1));
    else
        importance=max(importance3);
    end
else %do it do all channels AT THE SAME TIME (so, pretend it is one big channel)
    [gradient_angle,gradient_magnitude3,~]= calculateDominantPatchAngle(patch_Y, patch_X,currentStep,settings);
    gradient_angle2=gradient_angle*pi/180;
    if settings.IgnoreMagnitude
        gradSlope=[sin(gradient_angle2+pi/2), cos(gradient_angle2+pi/2)]';
    else
        gradSlope=[sin(gradient_angle2+pi/2), cos(gradient_angle2+pi/2)]'*gradient_magnitude3;
    end
    normalSlopeN=contour_normal_slope./norm(contour_normal_slope);
    importance=abs(dot(gradSlope,normalSlopeN));
    
end

%NOTE: Change so that at least one channel must have an edge going into the
%void.
if importance <1e-4
    importance =0.0001;
end

%fprintf('Current Gradient Mag %f, current importance %f \n',gradient_magnitude3,importance)

%%
%do not need to scale te data term as the gradient_magnitude is alread between 0 and 1.
data_term = importance;

if isnan(data_term)
    fprintf('DT Not a number! data= %f, importance=%f, tangN(%f,%f), tang(%f,%f)\n',data_term, importance,...
        normalSlopeN(1),normalSlopeN(2),contour_normal_slope(1),contour_normal_slope(2));
end

% if data_term >1
%     msg=sprintf('data term is greater than 1. Importance = %f, gradMagNorm= %f, data term=%f.)',...
%         importance,gradient_magnitude3/255,data_term);
%     disp(msg)
%     msg=sprintf('.... Tang(%f,%f), Isop(%f,%f)',...
%         normalSlopeN(1),normalSlopeN(2),gradSlope(1),gradSlope(2));
%     disp(msg)
% end

%priority = settings.dataWeight*data_term  + confidence_term;
%priority = data_term * confidence_term;
%priority = data_term^(settings.confidenceWeight) * confidence_term^(settings.confidenceWeight);
priority = data_term * confidence_term^(settings.confidenceWeight);
%priority = data_term * confidence_term;
%fprintf('data_term %f, Confidence, %f, priority, %f\n',data_term, confidence_term, priority)

end

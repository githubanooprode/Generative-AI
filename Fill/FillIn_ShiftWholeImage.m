function [settings,currentStep] = FillIn_ShiftWholeImage(settings,currentStep)
%%****First try at new version, copy whole image...after
%%shifting the Amoeba_Map and the source patch
%Amoeba is as large as it can be, and starts on the source pixel
%that most closely matches the target pixel

%centerY = currentStep.currentYPos;
%centerX = currentStep.currentXPos;
%centers = placeCenterInsideTarget(centerY,centerX,currentStep.targetArea3Color(:,:,1));
%centerY = (centers{1}(1)-currentStep.targetPatchY(1)) + currentStep.sourcePatchY(1);
%centerX = (centers{1}(2)-currentStep.targetPatchX(1)) + currentStep.sourcePatchX(1);

if strcmp(settings.blendDistanceFunction, 'getBlendPriorityOnlyOutsideTarget')
    blendPriority = currentStep.blendDistanceFunction(currentStep.targetArea3Color, currentStep.confidence3Color,currentStep);
else
    blendPriority=0;
end


centerY = (currentStep.currentYPos-currentStep.targetPatchY(1)) + currentStep.sourcePatchY(1);
centerX = (currentStep.currentXPos-currentStep.targetPatchX(1)) + currentStep.sourcePatchX(1);
centers = {[centerY centerX]};


%centers = {[currentStep.sourcePatchY(2), currentStep.sourcePatchX(2)]};
[currentStep.amoeba_map,currentStep.amoeba_size] = CreateAmoeba_color(centers,settings.initialLabImage,settings.amoeba_max_distance,currentStep,settings);
currentStep.amoeba_map = repmat(currentStep.amoeba_map,1,1,3);

unknown_area = currentStep.targetArea3Color;
known_area = ~unknown_area;
dont_blend=1-settings.blend;


%find the distance between the top left corner of the target and source patches:
%currentYPos and currentXPos is the target pixel
%offsetY=-currentStep.sourcePatchY(1) + currentStep.targetPatchY(1)+1;
%offsetX=-currentStep.sourcePatchX(1) + currentStep.targetPatchX(1)+1;

offsetY=currentStep.currentYPos - currentStep.sourcePatchCenterY;
offsetX=currentStep.currentXPos - currentStep.sourcePatchCenterX;


%now shift the amoeba map to be centered on the target pixel
%also need to shift POSTITION of the the source pixels...somehow...
%do not just add the offset, that changes the value, not the
%indexes...


%fix this so that we do not wrap shift...

%shifted_amoeba_map =zeros(size(amoeba_map));
%shifted_source_patch =zeros(size(initialLabImage));

%non-circular shift
[sY,sX]=size(settings.initialLabImage(:,:,1));
if offsetY >0
    newYIndices2a = 1:sY-offsetY;
    newYIndices2b = offsetY+1:sY;
else
    if offsetY <0
        newYIndices2a =abs(offsetY)+1:sY;
        newYIndices2b = 1:sY-abs(offsetY);
    else
        newYIndices2a = 1:sY;
        newYIndices2b = 1:sY;
    end
end

if offsetX >0
    newXIndices2a = 1:sX-offsetX;
    newXIndices2b = offsetX+1:sX;
else
    if offsetX <0
        newXIndices2a =abs(offsetX)+1:sX;  %abs(offsetX)+1:sX;
        newXIndices2b = 1:sX-abs(offsetX);
    else
        newXIndices2a = 1:sX;
        newXIndices2b = 1:sX;
    end
end
shifted_amoeba_map=zeros(size(currentStep.amoeba_map));
shifted_source_patch=zeros(size(settings.initialLabImage));
shifted_amoeba_map(newYIndices2b,newXIndices2b,:) = currentStep.amoeba_map(newYIndices2a,newXIndices2a,:);
shifted_source_patch(newYIndices2b,newXIndices2b,:) = settings.initialLabImage(newYIndices2a,newXIndices2a,:);
currentStep.shiftedAmoebaMap=shifted_amoeba_map;

%figure(10);imshow(currentStep.amoeba_map);
%figure(11);imshow(shifted_amoeba_map);
%ArmyAnt2=lab2rgb(initialLabImage);figure(12);imshow(ArmyAnt2);
%ArmyAnt2=lab2rgb(shifted_source_patch);figure(13);imshow(ArmyAnt2);

settings.initialLabImage = ...
    (settings.initialLabImage.* known_area .* ~shifted_amoeba_map) + ...
    (settings.initialLabImage.* known_area .* shifted_amoeba_map)*(dont_blend) + ...
    (settings.initialLabImage.* unknown_area .* shifted_amoeba_map)*(dont_blend) + ...
    (shifted_source_patch.* known_area .* shifted_amoeba_map)*settings.blend + ...
    shifted_source_patch.* unknown_area .* shifted_amoeba_map;

%New amoeba in unknown gets new confidence. Rest stay as is,
%and the new confidece is: summ confidence of known pixles in the 
%amoeba. Divide by total nuber of amoeba pixels. 
patchConfidence = currentStep.confidence3Color(:, :,:);

%new idea: find all the pxiels in the amoea that have a non-zero
%confidence. Of those, find the minimum. The new confidence is
%that values tie some weight (say, 0.9 to make it 90%). In the first
%iteration this this will be 1 for the min of the non-zeros, so the 
%new confidence is  0.9. In the next iteration, it will of 0.9 times 0.9,
%or 0.81

%[~,~,previousNonZero]= (find((patchConfidence.*shifted_amoeba_map(:,:,1))~=0));
%bobo=patchConfidence.*shifted_amoeba_map(:,:,1);
%previousMin=min(previousNonZero(:));
%newConfidence= previousMin*settings.confidenceWeight;
newConfidence = sum(sum(patchConfidence.*shifted_amoeba_map(:,:,1))) / currentStep.amoeba_size;


if newConfidence < 1/200 % lower boundry = 1/200 (should never be 0)
    newConfidence = 1/200;
end

%fprintf('new confidence %f',newConfidence);

%size(currentStep.confidence3Color)
%size(known_area)
%size(patchConfidence)
%size(unknown_area)
%size(currentStep.amoeba_map)
%size(newConfidence)

currentStep.confidence3Color = known_area.* patchConfidence + unknown_area.* shifted_amoeba_map.*newConfidence;

unknown_area = currentStep.targetArea3Color;
known_area = ~unknown_area;
lab_progress=settings.initialLabImage;
unknown_area2 = currentStep.targetArea3Color(currentStep.targetPatchY,currentStep.targetPatchX,:);
known_area2 = ~unknown_area;

lab_progress(currentStep.amoeba_map(:,:,1)==1)=100;
lab_progress(shifted_amoeba_map(:,:,1)==1)=100;

%lab_progress(:,:,1)= lab_progress(:,:,1) + lab_progress(:,:,1).*currentStep.amoeba_map(:,:,1).*10 ;
lab_progress(:,:,3)= lab_progress(:,:,3) + known_area(:,:,3).*shifted_amoeba_map(:,:,3)*200;
lab_progress(:,:,2)= lab_progress(:,:,2) + unknown_area(:,:,2).*shifted_amoeba_map(:,:,2)*200;
%lab_progress(:,:,3)= known_area(:,:,3).*shifted_amoeba_map(:,:,3)*100 + lab_progress(:,:,3).* unknown_area(:,:,3).*shifted_amoeba_map(:,:,3)*200;
%lab_progress(:,:,1)= lab_progress(:,:,1) +lab_progress(:,:,1).* known_area(:,:,1).*shifted_amoeba_map(:,:,1)/10  + lab_progress(:,:,1).* unknown_area(:,:,1).*shifted_amoeba_map(:,:,1)*10;
saveMeImage = lab2rgb(lab_progress);
fName=sprintf('%s/%s_step%.5d.png',settings.resultsDir,settings.output_image,currentStep.step_number);
%figure(25);imshow(currentStep.confidence3Color(:,:,1));
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




function [settings,currentStep] = FillIn_CreateAndUseDynamicSourcePatch(settings,currentStep)

if strcmp(settings.blendDistanceFunction, 'getBlendPriorityOnlyOutsideTarget')
    blendPriority = currentStep.blendDistanceFunction(currentStep.targetArea3Color, currentStep.confidence3Color,currentStep);
else
    blendPriority=0;
end
[currentStep.sourcePatchY, currentStep.sourcePatchX, currentStep.sourcePatchSize,  currentStep.sourcePatchRadii] = createAdaptivePatch_source(currentStep,settings);

%fprintf('size of dynamic source is %d (%d,%d,%d,%d)\n',currentStep.sourcePatchSize, currentStep.sourcePatchRadii)

unknown_area = currentStep.targetArea3Color;
known_area = ~unknown_area;
dont_blend=1-settings.blend;


%offsetY=-currentStep.sourcePatchY(1) + currentStep.targetPatchY(1)+1;
%offsetX=-currentStep.sourcePatchX(1) + currentStep.targetPatchX(1)+1;

offsetY=currentStep.currentYPos - currentStep.sourcePatchCenterY;
offsetX=currentStep.currentXPos - currentStep.sourcePatchCenterX;

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

source_map=zeros(size(settings.initialLabImage));
shifted_source_map=zeros(size(settings.initialLabImage));
shifted_source_patch=zeros(size(settings.initialLabImage));

source_map(currentStep.sourcePatchY, currentStep.sourcePatchX, :)=1;
shifted_source_map(newYIndices2b,newXIndices2b,:) = source_map(newYIndices2a,newXIndices2a,:);
shifted_source_patch(newYIndices2b,newXIndices2b,:) = settings.initialLabImage(newYIndices2a,newXIndices2a,:);

%figure(10);imshow(source_map);
%figure(11);imshow(shifted_source_map);
%ArmyAnt2=lab2rgb(settings.initialLabImage);figure(12);imshow(ArmyAnt2);
%ArmyAnt2=lab2rgb(shifted_source_patch);figure(13);imshow(ArmyAnt2);

settings.initialLabImage = ...
    (settings.initialLabImage.* known_area .* ~shifted_source_map) + ...
    (settings.initialLabImage.* known_area .* shifted_source_map)*(dont_blend) + ...
    (settings.initialLabImage.* unknown_area .* shifted_source_map)*(dont_blend) + ...
    (shifted_source_patch.* known_area .* shifted_source_map)*settings.blend + ...
    shifted_source_patch.* unknown_area .* shifted_source_map;

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
newConfidence = sum(sum(patchConfidence.*shifted_source_map(:,:,1))) /  currentStep.sourcePatchSize;


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

currentStep.confidence3Color = known_area.* patchConfidence + unknown_area.* shifted_source_map.*newConfidence;

unknown_area = currentStep.targetArea3Color;
known_area = ~unknown_area;
lab_progress=settings.initialLabImage;
lab_progress2=settings.initialLabImage;
lab_progress3=settings.initialLabImage;
lab_progress4=settings.initialLabImage;
lab_progress5=settings.initialLabImage;
unknown_area2 = currentStep.targetArea3Color(currentStep.targetPatchY,currentStep.targetPatchX,:);
known_area2 = ~unknown_area;


lab_progress(currentStep.targetPatchY,currentStep.targetPatchX,1)=100;
lab_progress(currentStep.targetPatchY,currentStep.targetPatchX,2)=-200;

lab_progress4(currentStep.sourcePatchY_orig,currentStep.sourcePatchX_orig,1)=100;
lab_progress4(currentStep.sourcePatchY_orig,currentStep.sourcePatchX_orig,2)=-200;

%lab_progress2(source_map(:,:,1)==1)=100;
%imshow(source_map)
lab_progress2(:,:,1)=lab_progress2(:,:,1) +lab_progress2(:,:,1).*source_map(:,:,1)*100;
lab_progress2(:,:,3)= lab_progress2(:,:,3) + lab_progress2(:,:,3).*source_map(:,:,3)*200;

lab_progress3(shifted_source_map(:,:,1)==1)=100;

%lab_progress(:,:,1)= lab_progress(:,:,1) + lab_progress(:,:,1).*currentStep.amoeba_map(:,:,1).*10 ;
lab_progress3(:,:,3)= lab_progress3(:,:,3) + known_area(:,:,3).*shifted_source_map(:,:,3)*200;
lab_progress3(:,:,2)= lab_progress3(:,:,2) + unknown_area(:,:,2).*shifted_source_map(:,:,2)*200;
%lab_progress(:,:,3)= known_area(:,:,3).*shifted_amoeba_map(:,:,3)*100 + lab_progress(:,:,3).* unknown_area(:,:,3).*shifted_amoeba_map(:,:,3)*200;
%lab_progress(:,:,1)= lab_progress(:,:,1) +lab_progress(:,:,1).* known_area(:,:,1).*shifted_amoeba_map(:,:,1)/10  + lab_progress(:,:,1).* unknown_area(:,:,1).*shifted_amoeba_map(:,:,1)*10;

lab_progress5(:,:,1)=lab_progress5(:,:,1) +lab_progress5(:,:,1).*source_map(:,:,1)*100;
lab_progress5(shifted_source_map(:,:,1)==1)=100;
lab_progress5(:,:,3)= lab_progress5(:,:,3) + known_area(:,:,3).*shifted_source_map(:,:,3)*200;
lab_progress5(:,:,2)= lab_progress5(:,:,2) + unknown_area(:,:,2).*shifted_source_map(:,:,2)*200;



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

        if(any(findall(0,'Type','Figure')==33))
        set(0,'CurrentFigure',33);
    else
        myFig=figure(33);
        %set(myFig, 'Position' , [1   settings.screenSize(4)/2  settings.screenSize(3)/2 settings.screenSize(4)/2]);
    end
    ArmyAnt2=lab2rgb(lab_progress4);
    imshow(ArmyAnt2);

    if(any(findall(0,'Type','Figure')==13))
        set(0,'CurrentFigure',13);
    else
        myFig=figure(13);
        %set(myFig, 'Position' , [1   settings.screenSize(4)/2  settings.screenSize(3)/2 settings.screenSize(4)/2]);
    end
    ArmyAnt2=lab2rgb(lab_progress2);
    imshow(ArmyAnt2);

    if(any(findall(0,'Type','Figure')==23))
        set(0,'CurrentFigure',23);
    else
        myFig=figure(23);
        %set(myFig, 'Position' , [1   settings.screenSize(4)/2  settings.screenSize(3)/2 settings.screenSize(4)/2]);
    end
    ArmyAnt2=lab2rgb(lab_progress3);
    imshow(ArmyAnt2);

    if(any(findall(0,'Type','Figure')==53))
        set(0,'CurrentFigure',53);
    else
        myFig=figure(53);
        %set(myFig, 'Position' , [1   settings.screenSize(4)/2  settings.screenSize(3)/2 settings.screenSize(4)/2]);
    end
    ArmyAnt2=lab2rgb(lab_progress5);
    imshow(ArmyAnt2);
    %pause()
end
if settings.saveStepImages && ~mod(currentStep.step_number, settings.saveStepImages_interval)
    imwrite(saveMeImage,fName,'png','Author','Cunningham and gang','Comment','This image has been altered by inpainting');
end

function [gradient_angle,gradient_magnitude,voidBit]= calculateDominantPatchAngle(targetPatchesY,targetPatchesX,currentStep,settings)
%Calculate the weighted histogram of orientation,skipping the target area 
%and neighboring contour...also calculate peakArea/TotalArea
%add new control. If a significant portion of the pixels along a give
%edge are in the void, then do not grow in that direction, but set the
%void bit. If all 4 edges are either false or voidbit, then stop
%growing alltogether.
voidPercent=0;

%Find the missing pixels in the patch. Target area and target contour
%this is the void as well as the contour of known pixles at the 
%boundary of the void
patchTA3=currentStep.targetArea3Color(targetPatchesY,targetPatchesX,:);
patchTC3=currentStep.targetContour3Color(targetPatchesY,targetPatchesX,:);
patchVoid=patchTA3+patchTC3;

%set the voidBit!
if numel(patchVoid(:,:,1))~=0
    voidPercent=sum(sum(patchVoid(:,:,1)))/numel(patchVoid(:,:,1));
end

%fprintf('voidPercent = %.2f \n',voidPercent)
%if the percentage of void pixels in the patch is above a threshold,stop
if voidPercent>settings.voidBitThreshold
    voidBit=1;
    %fprintf('voidBid = %d...drop it.\n',voidBit)
else
    voidBit=0; %vp is greater than threshold
    %fprintf('voidBid = %d...KEEP ME!\n',voidBit)
end

%find the gradients in the patch, make sure all are between 0 and 180. 
patch_gradientM_init=currentStep.myInitialGradientM(targetPatchesY,targetPatchesX,:);
patch_gradientDir_init=currentStep.myInitialGradientDir(targetPatchesY,targetPatchesX,:);
patch_gradientDir_init(patch_gradientDir_init<0)=patch_gradientDir_init(patch_gradientDir_init<0)+180;


%reshape to a column vector, DO NOT use the ones in the void!
patch_gradientM3=zeros(numel(find(patchVoid(:,:,1)==0)),3);
patch_gradientDir3=zeros(numel(find(patchVoid(:,:,1)==0)),3);

%In LAB space, the range for L is [0,100] and for A and B it is [-100,100]
%so we need to scale for the maximum gradient. 
for loopAhead=1:3
    if(loopAhead==1)
        offset=100;
    else
        offset=200;
    end
    %offset=1;
    tmp1=patch_gradientM_init(:,:,loopAhead)/offset;
    patch_gradientM3(:,loopAhead)=tmp1(find(patchVoid(:,:,loopAhead)==0));
    tmp2=patch_gradientDir_init(:,:,loopAhead);
    patch_gradientDir3(:,loopAhead)=tmp2(find(patchVoid(:,:,1)==0));
end

%
%get the histograms
%clear nn1 nn2 nn3 hh jj kk temp2 temp2a temp_magnitude
[nn1,hh]=hist(patch_gradientDir3(:,1),settings.histogramCenters);
[nn2,~]=hist(patch_gradientDir3(:,2),settings.histogramCenters);
[nn3,~]=hist(patch_gradientDir3(:,3),settings.histogramCenters);

%get the summed magnitudes per bin:
summedM1=zeros(numel(hh),3);
for alof=1:numel(hh)
    for myColor=1:3
        if alof==1
            [inBin1]=find(patch_gradientDir3(:,myColor)>=hh(alof)-settings.binSeparation/2);
        else
            [inBin1]=find(patch_gradientDir3(:,myColor)>hh(alof)-settings.binSeparation/2);
        end
        tempSum1=patch_gradientDir3(inBin1,myColor);
        tempSumM1=patch_gradientM3(inBin1,myColor);
        
        [inBin1A]=find(tempSum1(:)<=hh(alof)+settings.binSeparation/2);
        
        if isempty(inBin1A)
            summedM1(alof,myColor)=0;
        else
            summedM1(alof,myColor)=sum(tempSumM1(inBin1A));
        end
    end
end

%as an option, multiply the summed magnitude by the number of pixels with
%that gradient. This differentiates between a few large -magnitude
%gradients and a lot of small-magnitude gradients...and does so in favor
%of a lot of small gradients. settings.magnitudeWeight


%Basically: Use either the summed magnitude or the summed multiplied by 
%the frequency. One could also use the average...bit we do not at this
%point.
%Criminisi used either the average or the summed (I think), but it
%is not clear.

newNN=zeros(numel(hh),3);
switch settings.magnitudeWeight
    case 0
        newNN(:,1)=summedM1(:,1);
        newNN(:,2)=summedM1(:,2);
        newNN(:,3)=summedM1(:,3);
    case 1
        newNN(:,1)=nn1'.*summedM1(:,1);
        newNN(:,2)=nn2'.*summedM1(:,2);
        newNN(:,3)=nn3'.*summedM1(:,3);
    case 2
        newNN(:,1)=nn1';
        newNN(:,2)=nn2';
        newNN(:,3)=nn3';
end

%get the average gradient magnitudes:
averagedM1=zeros(numel(hh),3);
averagedM1(:,1)=summedM1(:,1)'./nn1;
averagedM1(:,2)=summedM1(:,2)'./nn2;
averagedM1(:,3)=summedM1(:,3)'./nn3;
averagedM1(isnan(averagedM1))=0;

%then combine to a single histogram. Can be weighted or not. Currently
%I choose to treat all three color channels equal. We might weight L
%higher, though.
if settings.useGradientMagAverage
    finalNN=mean(averagedM1,2);
else
    finalNN=sum(newNN,2); %use the (case 2: unweighted, case 1: weighted) mode 
    finalSUM=sum(summedM1,2);
end

%find the maximum for this patch

[jj]=find(finalNN==max(finalNN));
if isempty(patch_gradientDir3)
    gradient_angle=0;
    gradient_magnitude=0;
else %if there is a tie, take the first one.
    gradient_angle=hh(jj(1));
    if settings.useGradientMagAverage
        gradient_magnitude=max(averagedM1(jj(1),:));
        %gradient_magnitude3=mean(averagedM1(jj(1),:));
    else
        gradient_magnitude=max(finalSUM(jj(1),:));
        %gradient_magnitude3=mean(finalNN(jj(1),:));
    end
end
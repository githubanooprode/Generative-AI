function [targetPatchY, targetPatchX, targetPatchSize, radius] = createAdaptivePatchB_weighted_3color_FullAmoeba(currentStep,settings)

    % ADAPTIVE PATCH B -- Grow in each direction alternatingly until value < (1-stop_growing_threshold) * initial value
     % start with minimal size
    radius = repmat(settings.patch_radius_min, 4,1);

    % create initial patch and get starting values for dominant gradient angle
    [targetPatchY,targetPatchX] = createPatch(currentStep.currentYPos, currentStep.currentXPos, radius, size(currentStep.confidence3Color(:,:,1)));
    if(settings.doColorSeparate)
        [initialAdaptivePatchAngle, ~,gradient_angle_all,~,~] = calculateDominantPatchAngle_separateColor(targetPatchY,targetPatchX,currentStep,settings);
        myColorInitialAdaptivePatchAngle=initialAdaptivePatchAngle;
        initialAdaptivePatchAngle=gradient_angle_all;
        %fprintf('\t\tadaptive patch angle %f, and by color %f,%f,%f \n',initialAdaptivePatchAngle,myColorInitialAdaptivePatchAngle);
    else
        [initialAdaptivePatchAngle, ~,~] = calculateDominantPatchAngle(targetPatchY,targetPatchX,currentStep,settings);
        %fprintf('\t\tadaptive patch angle %f\n',initialAdaptivePatchAngle);
    end
    targetPatchSize = numel(targetPatchY)*numel(targetPatchX);

    %initial value for growth controllers
    keepGrowing = [true, true, true, true]; % east, south, west, north
    voidBit=[0,0,0,0];
    failBit=[0,0,0,0];

    %tempGradBins=floor(currentStep.myInitialGradientDir(:,:,:)/settings.binSeparation)+1;
    
    while any(keepGrowing)
        for direction = find(keepGrowing==true)
            radius(direction) = radius(direction) + 1;
            
            %get current size, to see if the grows in the next step
            startTargetPatchY=targetPatchY;
            startTargetPatchX=targetPatchX;            

             %create the new patch. If it passes the edge of the image it
             %will not grow.
            [newTargetPatchY,newTargetPatchX,~,~,~,failMe] = createPatch(currentStep.currentYPos, currentStep.currentXPos, radius, size(currentStep.confidence3Color(:,:,1)));
            newTargetPatchSize = numel(newTargetPatchY)*numel(newTargetPatchX);
 
            %either test only the new pixels, or use all the pixels in
            %the patch
            if settings.testOnlyNewPixels %GET the new pixels
                if abs(min(newTargetPatchY)-min(startTargetPatchY))
                    testPY=min(newTargetPatchY);
                    testPX=newTargetPatchX;
                end
                if abs(max(newTargetPatchY)-max(startTargetPatchY))
                    testPY=max(newTargetPatchY);
                    testPX=newTargetPatchX;
                end
                if abs(min(newTargetPatchX)-min(startTargetPatchX))
                    testPY=newTargetPatchY;
                    testPX=min(newTargetPatchX);
                end
                if abs(max(newTargetPatchX)-max(startTargetPatchX))
                    testPY=newTargetPatchY;
                    testPX=max(newTargetPatchX);
                end
            else
                    testPY=newTargetPatchY;
                    testPX=newTargetPatchX;
            end                
            
            %see if the percentage of pixels in the void is too high:
            patchVoid=currentStep.targetArea3Color(testPY,testPX,:)+currentStep.targetContour3Color(testPY,testPX,:);
            if numel(patchVoid(:,:,1))~=0
                voidPercent=sum(sum(patchVoid(:,:,1)))/numel(patchVoid(:,:,1));
                %fprintf('void %f compared to threshold %f is %d\n', voidPercent,settings.voidBitThreshold,voidPercent>settings.voidBitThreshold);
                if voidPercent>settings.voidBitThreshold
                    vbTemp=1;
                    %fprintf('\tset void bit\n');
                else
                    vbTemp=0; %vp is greater than threshold
                end
            end
            
            if(settings.doColorSeparate)
                if failMe
                    %fprintf('fail due to lack of size change\n');
                    testAngleChange1=1;
                    testAngleChange2=1;
                    testAngleChange3=1;
                else
                    [adaptivePatchAngle,~,~,~,~] = calculateDominantPatchAngle_separateColor(testPY,testPX,currentStep,settings) ;
                    myColorAdaptivePatchAngle=adaptivePatchAngle;
                    testAngleChange1=myColorAdaptivePatchAngle(1)~= myColorInitialAdaptivePatchAngle(1);
                    testAngleChange2=myColorAdaptivePatchAngle(2)~= myColorInitialAdaptivePatchAngle(2);
                    testAngleChange3=myColorAdaptivePatchAngle(3)~= myColorInitialAdaptivePatchAngle(3);
                end
                maxChange=settings.numColorGradientFails;
                if (testAngleChange1 + testAngleChange2 + testAngleChange3)>maxChange
                    testAngleChange=1;
                else
                    testAngleChange=0;
                end
                if sum(currentStep.myInitialGradientM(testPY,testPX,1))==0
                    testAngleChange=0;
                end
            else
                [adaptivePatchAngle,~,~] = calculateDominantPatchAngle(testPY,testPX,currentStep,settings) ;
                testAngleChange= adaptivePatchAngle~= initialAdaptivePatchAngle;
            end
            voidBit(direction)=vbTemp;
            if (newTargetPatchSize == targetPatchSize ||  radius(direction) > settings.patch_radius_max)
                keepGrowing(direction)=false;
                %fprintf('direction %d) Failed because either did not grow %d, or is too big %d, or both.\n',direction,newTargetPatchSize == targetPatchSize,radius(direction) > settings.patch_radius_max);                
            end
            
            if  (keepGrowing(direction)==false||voidBit(direction) ||testAngleChange)
                failBit(direction)=1;
                radius(direction) = radius(direction) - 1;
                %fprintf('direction %d) Failed becase in the void %d or angle change %d (%d, %d, %d  vs %d, %d, %d) \n', direction,voidBit(direction) ,testAngleChange,myColorInitialAdaptivePatchAngle, myColorAdaptivePatchAngle);
                coco=0;
                for lolo=1:4
                    if failBit(lolo)
                        coco=coco+1;
                    end
                end
                if coco==4
                    keepGrowing(:)=false;
                    break;
                end
            else
                failBit(direction)=0;      
                targetPatchSize = newTargetPatchSize;
                targetPatchY=newTargetPatchY;
                targetPatchX=newTargetPatchX;
            end
        end
    end
end

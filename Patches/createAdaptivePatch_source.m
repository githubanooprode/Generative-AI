function [sourcePatchY, sourcePatchX, sourcePatchSize, radius] = createAdaptivePatch_source(currentStep,settings)

    % ADAPTIVE PATCH B -- Grow in each direction alternatingly until value < (1-stop_growing_threshold) * initial value
     % start with minimal size
    radius = repmat(settings.source_patch_radius_min, 4,1);

    % create initial patch and get starting values for dominant gradient angle
    [sourcePatchY,sourcePatchX] = createPatch(currentStep.sourcePatchCenterY,currentStep.sourcePatchCenterX, radius, size(currentStep.confidence3Color(:,:,1)));
    if(settings.doColorSeparate)
        [initialAdaptivePatchAngle, ~,gradient_angle_all,~,~] = calculateDominantPatchAngle_separateColor(sourcePatchY,sourcePatchX,currentStep,settings);
        myColorInitialAdaptivePatchAngle=initialAdaptivePatchAngle;
        initialAdaptivePatchAngle=gradient_angle_all;
        %fprintf('\t\tadaptive patch angle %f, and by color %f,%f,%f \n',initialAdaptivePatchAngle,myColorInitialAdaptivePatchAngle);
    else
        [initialAdaptivePatchAngle, ~,~] = calculateDominantPatchAngle(sourcePatchY,sourcePatchX,currentStep,settings);
        %fprintf('\t\tadaptive patch angle %f\n',initialAdaptivePatchAngle);
    end
    sourcePatchSize = numel(sourcePatchY)*numel(sourcePatchX);
    
    %initial value for growth controllers
    keepGrowing = [true, true, true, true]; % east, south, west, north
    voidBit=[0,0,0,0];
    failBit=[0,0,0,0];
    
    
    
    while any(keepGrowing)
        for direction = find(keepGrowing==true)
            radius(direction) = radius(direction) + 1;
            
            %get current size, to see if the grows in the next step
            startSourcePatchY=sourcePatchY;
            startSourcePatchX=sourcePatchX;            

            %create the new patch. If it passes the edge of the image it
             %will not grow.
            [newSourcePatchY,newSourcePatchX,~,~,~,failMe] = createPatch( currentStep.sourcePatchCenterY,currentStep.sourcePatchCenterX,radius, size(currentStep.confidence3Color(:,:,1)));
            newSourcePatchSize = numel(newSourcePatchY)*numel(newSourcePatchX);

            %either test only the new pixels, or use all the pixels in
            %the patch
            if settings.testOnlyNewPixels %GET the new pixels
                if abs(min(newSourcePatchY)-min(startSourcePatchY))
                    testPY=min(newSourcePatchY);
                    testPX=newSourcePatchX;
                end
                if abs(max(newSourcePatchY)-max(startSourcePatchY))
                    testPY=max(newSourcePatchY);
                    testPX=newSourcePatchX;
                end
                if abs(min(newSourcePatchX)-min(startSourcePatchX))
                    testPY=newSourcePatchY;
                    testPX=min(newSourcePatchX);
                end
                if abs(max(newSourcePatchX)-max(startSourcePatchX))
                    testPY=newSourcePatchY;
                    testPX=max(newSourcePatchX);
                end
            else
                testPY=newSourcePatchY;
                testPX=newSourcePatchX;
            end
            
            %Fail if ANY pixels are in the void
            patchVoid=currentStep.targetArea3Color(testPY,testPX,:)+currentStep.targetContour3Color(testPY,testPX,:);            
            if numel(patchVoid(:,:,1))~=0
                vbTemp=sum(sum(patchVoid(:,:,1)))/numel(patchVoid(:,:,1));
                if vbTemp<1.0
                    vbTemp=0;
                end                
            end

            if(settings.doColorSeparate)
                %orig_voidBitThreshold=settings.voidBitThreshold; 
                %settings.voidBitThreshold=0;
                %[~,~,~,~,vbTemp] = calculateDominantPatchAngle_separateColor(newSourcePatchY,newSourcePatchX,currentStep,settings) ;
                %settings.voidBitThreshold=orig_voidBitThreshold;
                %fprintf('vbtemp %d\t',vbTemp);
                
                if failMe
                    fprintf('fail due to lack of size change\n');
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
                if failMe
                    testAngleChange= 1;
                else
                    [adaptivePatchAngle,~,~] = calculateDominantPatchAngle(testPY,testPX,currentStep,settings) ;
                    testAngleChange= adaptivePatchAngle~= initialAdaptivePatchAngle;
                end
            end

            voidBit(direction)=vbTemp;
            if (newSourcePatchSize == sourcePatchSize ||  radius(direction) > settings.source_patch_radius_max)
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
                sourcePatchSize = newSourcePatchSize;
                sourcePatchY=newSourcePatchY;
                sourcePatchX=newSourcePatchX;
            end
        end
    end
end

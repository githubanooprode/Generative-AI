function saveMeImage = ImageInpainting_Main_Simplified_2017(settings)

tic();
disp('Initializing');
[settings,currentStep]=initializeMe(settings);
[settings,currentStep]=prepareImage(settings,currentStep);
disp(settings.output_image)


%% Step 3: Main loop!
priority=0;
while currentStep.contour_size > 0    
    
    %CALCULATE PRIORITY
    [currentStep,priority]= decideOnPriority(settings,currentStep,priority);
    [currentStep,priority] = resetPriorityForBadPixels(settings,currentStep,priority);
    
    %GET NEXT TARGET PIXEL
    currentStep= getNextPixel(currentStep,priority);
    currentStep= checkForPixelRepetition(settings, currentStep);
    
    % CREATE TARGET PATCH
    currentStep = doTargetPatch(settings,currentStep);
    
    %GET BEST MATCH
    [currentStep] =currentStep.getBestMatch(settings,currentStep);
    
    %COPY SOURCE PATCH TO TARGET AREA
    [settings,currentStep] = currentStep.FillInFunction(settings,currentStep);
    [settings,currentStep,priority] = updateVariables(settings,currentStep,priority);
    
    %SAVE PROGRESS
%     currentStep=saveProgress(settings,currentStep);
end
saveMeImage = lab2rgb(settings.initialLabImage);
imwrite(saveMeImage,settings.fullpath_output_image,'png','Author','Cunningham and gang','Comment','This image has been altered by inpainting');
end

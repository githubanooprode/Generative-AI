function [currentStep]=saveProgress(settings,currentStep)


%PROGRESS
% if settings.display_progress
%     figure(2);
%     ArmyAnt2=lab2rgb(initialLabImage(currentStep.targetPatchY, currentStep.targetPatchX,:));
%     imshow(ArmyAnt2);
%
%if(any(findall(0,'Type','Figure')==4))
%    set(0,'CurrentFigure',4); 
%else
%    figure(4);
%end
%bar(1:410,currentStep.patchSizes(1:410));
%xticks([0:10:410]);drawnow;

% end

target_area_size = sum(sum(currentStep.targetArea3Color(:,:,1)));
currentStep.progress = (1-target_area_size/settings.initial_target_area_size);
FID=fopen(settings.fullpath_logfile,'at');
currentStep.patchSizes(currentStep.targetPatchSize)=currentStep.patchSizes(currentStep.targetPatchSize)+1;


if settings.useAmoeba
    fprintf(FID,'\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))));
    fprintf(FID,'Step %5d - Progress: %5.1f%% (amoeba size: (%d))\n', currentStep.step_number,currentStep.progress*100,currentStep.amoeba_size);
    fprintf('\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole, TARGET PIXEL: (%d,%d)  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))), currentStep.currentYPos,currentStep.currentXPos);
    fprintf('Step %5d - Progress: %5.1f%% (amoeba size: (%d), patch size (%d: %d,%d,%d,%d))\n', currentStep.step_number,currentStep.progress*100,currentStep.amoeba_size,currentStep.targetPatchSize,currentStep.targetPatchRadii);
else
    if  strcmp(settings.FillIn,'FillIn_CreateAndUseDynamicSourcePatch')
        fprintf('\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole, TARGET PIXEL: (%d,%d)  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))), currentStep.currentYPos,currentStep.currentXPos);
        fprintf('Step %5d - Progress: %5.1f%% (window size: (%d,%d,%d,%d)),size of dynamic source is %d (%d,%d,%d,%d)\n', currentStep.step_number, currentStep.progress*100, currentStep.targetPatchRadii,currentStep.sourcePatchSize, currentStep.sourcePatchRadii)
        fprintf(FID,'\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole, TARGET PIXEL: (%d,%d)  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))), currentStep.currentYPos,currentStep.currentXPos);
        fprintf(FID,'Step %5d - Progress: %5.1f%% (window size: (%d,%d,%d,%d)), ,size of dynamic source is %d (%d,%d,%d,%d)\n', currentStep.step_number, currentStep.progress*100, currentStep.targetPatchRadii,currentStep.sourcePatchSize, currentStep.sourcePatchRadii);
    else
        fprintf('\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole, TARGET PIXEL: (%d,%d)  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))), currentStep.currentYPos,currentStep.currentXPos);
        fprintf('Step %5d - Progress: %5.1f%% (window size: (%d,%d,%d,%d))\n', currentStep.step_number, currentStep.progress*100, currentStep.targetPatchRadii);
        fprintf(FID,'\t %d  Bad Pixels, %d Contour Pixels, %d pixels in hole, TARGET PIXEL: (%d,%d)  ',currentStep.numBad,currentStep.contour_size, sum(sum(currentStep.targetArea3Color(:,:,1))), currentStep.currentYPos,currentStep.currentXPos);
        fprintf(FID,'Step %5d - Progress: %5.1f%% (window size: (%d,%d,%d,%d))\n', currentStep.step_number, currentStep.progress*100, currentStep.targetPatchRadii);
    end
end
fclose(FID);
if settings.logfile
    %save current image (to later make a movie?)
    %disp('is a logfile')
    %fprintf('step %d, interval %d, mod %d', currentStep.step_number, settings.saveStepImages_interval, mod(currentStep.step_number, settings.saveStepImages_interval))
     
    result_info.processing_time = toc();
    result_info.finish_time = datestr(now(), 'yyyy-mm-dd HH:MM:SS.FFF');
    result_info.steps = numel(currentStep.step_number);
    result_info.mean_match_distance = mean(currentStep.matchDistance);
    result_info.patch_radius = sqrt(currentStep.targetPatchSize) / 2 - 1;
    [result_info.patch_radius_hist, result_info.patch_radius_hist_bins] = hist(round(result_info.patch_radius), 10);
    
    save(strcat(settings.fullpath_logfile, '.mat'), 'currentStep','settings','result_info');
end


function [settings]=moreInit(settings)

if settings.percent_search_box == true
    myBoxString='PercentageSearchBox';
    bobo=floor(max(settings.image_height,settings.image_width)*.02);
    settings.amoeba_max_distance=bobo;
    settings.patch_radius_min=settings.amoeba_max_distance;
    settings.patch_radius_max=settings.amoeba_max_distance;
else
    myBoxString='StandardSearchBox';
end

formatOut = 'YYyy-mmmm-dd-HH_MM';
currentTime=datestr(now,formatOut);

if strcmp(settings.FillIn,'FillIn_CreateAndUseDynamicSourcePatch')
    settings.output_image=sprintf('%s_Amoeba%d_%s_TRad%d-%d_SRad%d-%d_AThresh%d_phyDist%.2f_testOnlyNew%d_numBins%d_voidThresh%.2f_blend%.2f_numGradFails%d_numGradFailsS%d_newColorPriority%d__strongest%d_%s_%s',settings.theImage, settings.useAmoeba,myBoxString,settings.patch_radius_min,settings.patch_radius_max,settings.source_patch_radius_min,settings.source_patch_radius_max,settings.amoeba_max_distance,settings.physicalDistance,settings.testOnlyNewPixels,settings.numBins,settings.voidBitThreshold,settings.blend,settings.numColorGradientFails,settings.numColorGradientFails_source,settings.useNewColorPriority,settings.chooseStrongestPriortiyGradient,settings.machine,currentTime);
else
    settings.output_image=sprintf('%s_Amoeba%d_%s_TRad%d-%d_SRad_SAME_AThresh%d_phyDist%.2f_testOnlyNew%d_numBins%d_voidThresh%.2f_blend%.2f_numGradFails%d_numGradFailsS%d_newColorPriority%d__strongest%d_%s_%s',settings.theImage, settings.useAmoeba,myBoxString,settings.patch_radius_min,settings.patch_radius_max,settings.amoeba_max_distance,settings.physicalDistance,settings.testOnlyNewPixels,settings.numBins,settings.voidBitThreshold,settings.blend,settings.numColorGradientFails,settings.numColorGradientFails_source,settings.useNewColorPriority,settings.chooseStrongestPriortiyGradient,settings.machine,currentTime);

end
settings.fullpath_output_image=sprintf('%s/%s.png',settings.resultsDir,settings.output_image);
settings.logfile=settings.output_image;
settings.fullpath_logfile=sprintf('%s/%s.txt',settings.resultsDir,settings.output_image);
d = fileparts(settings.fullpath_logfile);
if ~strcmp(d,'') && ~exist(d, 'dir')
    mkdir(d);
end



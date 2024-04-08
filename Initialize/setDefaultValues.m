function [settings]=setDefaultValues(settings)

%The other settings are optional, so make some default variable settings
setting_alternative = [ ...
    struct( 'name', 'percent_search_box', 'default', false), ...
    struct( 'name', 'display_progress', 'default', false), ...
    struct( 'name', 'saveStepImages', 'default', false), ...
    struct( 'name', 'saveStepImages_interval', 'default', 1), ...
    struct( 'name', 'patch_radius_min', 'default', 1), ...
    struct( 'name', 'patch_radius_max', 'default', 20), ...
    struct( 'name', 'source_patch_radius_min', 'default', 1), ...
    struct( 'name', 'source_patch_radius_max', 'default', 20), ...
    struct( 'name', 'badMatchThreshold', 'default', 999) ...
    struct( 'name', 'voidBitThreshold', 'default', 0.5), ...
    struct( 'name', 'blend', 'default', 0 ), ...
    struct( 'name', 'numColorGradientFails', 'default', 0), ...
    struct( 'name', 'numColorGradientFails_source', 'default', 0), ...
    struct( 'name', 'doColorSeparate', 'default', 1), ...
    struct( 'name', 'chooseStrongestPriortiyGradient', 'default', 0), ...
    struct( 'name', 'useNewColorPriority','default', 1), ...
    struct( 'name', 'resultsDir','default', 'tempResults' ), ...
    struct( 'name', 'theImage','default', 'eagle'), ...
    struct( 'name', 'machine', 'default', 'NoMachine'), ...
    struct( 'name', 'imagePath', 'default', 'target'), ...
    struct( 'name', 'inpainting_INFO', 'default', 'ImageInpainting_July2017'), ...
    struct( 'name', 'magnitudeWeight','default', 0 ), ...
    struct( 'name', 'IgnoreMagnitude', 'default', 0), ...
    struct( 'name', 'confidenceWeight', 'default', 0.9), ...
    struct( 'name', 'useGradientMagAverage', 'default', 0), ...
    struct( 'name', 'useAmoeba', 'default', 0), ...
    struct( 'name', 'amoeba_max_distance','default', 20), ...
    struct( 'name', 'dir_distance_weight','default', 0.0), ...
    struct( 'name', 'physicalDistance','default', 1.0), ...
    struct( 'name', 'matchMeanVsSum','default', 1), ...
    struct( 'name', 'localUpdate', 'default', 1),...
    struct( 'name', 'radiusForTangent','default', 2), ...
    ];

%if the variable is not set, use the alternative
for s = 1:numel(setting_alternative)
    if ~isfield(settings, setting_alternative(s).name)
        settings.(setting_alternative(s).name) = setting_alternative(s).default;
    end
end
if ~isfield(settings, 'numBins')
    settings.numBins=6;
end

%a few values derived from the above
settings.binSeparation=(180-0) /settings.numBins;
settings.histogramCenters=settings.binSeparation/2:settings.binSeparation:180;
settings.input_image=sprintf('%s/%s.png',settings.imagePath,settings.theImage);


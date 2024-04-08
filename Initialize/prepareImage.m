function [settings,currentStep] = prepareImage(settings,currentStep)
% Fixing the deleted areas from the images in TARGET:
% If pixel is not not 100% opaque, it will now be 100% tranparent,
% i.e. marked as "removed". also, the color of the pixel will
% be set to black. Typically, in our images, the target (or deleted) areas are fully
%transparent (have an alpha value of 0). Fully opaque areas are 255.

%get Image
[inputImage,inputMap,inputAlpha]=imread(settings.input_image);
if numel(inputMap) > 0
    sprintf('load_image: INDEXED COLORS not implemented yet.')
    quit;
end

%get size as well as color depth, see if latter is okay.
[settings.image_height,settings.image_width,channels] = size(inputImage);
if channels == 4
    channels = 3;
    inputAlpha= inputImage(:,:,4);
elseif channels == 2
    channels = 1;
    inputAlpha= inputImage(:,:,2);
elseif numel(inputAlpha) == 0
    inputAlpha= zeros(settings.image_height, settings.image_width);
end
if channels ~= 3 || ~isinteger(inputImage) || ~isinteger(inputAlpha)
    sprintf('load_image: RGB input must have 3 uint8 layer (Grayscale, B/W, other bitdepth...  not implemented yet).')
    quit;
end
settings.image_size = settings.image_height*settings.image_width;


%create initial void or deletion mask (or target). as well as the (initial)
%contour at the edge of the void. pixels in the target area (void) will have 
%a value of 1, pixels in the source area will have a value of 0.
opaque_val = 255;
deleted = inputAlpha < opaque_val;
preparedAlpha = uint8(opaque_val * ~deleted);
preparedAlpha= single(preparedAlpha) ./ 255.0; 
currentStep.confidence3Color = repmat(double(preparedAlpha),[1,1,3]);
[currentStep.targetArea3Color,currentStep.targetContour3Color,targetContour2] = calculateContour(currentStep.confidence3Color);
settings.initial_target_area_size = sum(sum(currentStep.targetArea3Color(:,:,1)));

%set initial image, blacking out areas in the void
initialLabImage = rgb2lab(inputImage);
settings.initialLabImage= double(initialLabImage); % MEX is better with double.
settings.initialLabImage= settings.initialLabImage.* ~currentStep.targetArea3Color;
currentStep.forbiddenPatches=zeros(size(settings.initialLabImage,1),size(settings.initialLabImage,2));

%set ouput info
settings=moreInit(settings);

%set initial gradient map, initial position ,etc.
[currentStep.myInitialGradientM,currentStep.myInitialGradientDir] = calculateGradient(initialLabImage,targetContour2);
currentStep.contour_size=sum(sum(currentStep.targetContour3Color(:,:,1)));
currentStep.currentYPos=-1;
currentStep.currentXPos=-1;
currentStep.step_number=0;
currentStep.mult=1;

currentStep.contour_size=sum(sum(currentStep.targetContour3Color(:,:,1)));
end



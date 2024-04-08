function [targetArea3Color,targetContour3Color,targetContour2] = calculateContour(confidence3Color)
%get the contour and make that a binary mask, then find edge pixels
%We use just the outermost pixel as the actual contour
%Note: confidence3Color has 0 in deleted region for all three color channels.
%Note: targetArea3Color has a value of 1 in the deleted areas, 0 otherwise.
targetArea3Color = (confidence3Color == 0);
jojo=imgradient(double(targetArea3Color(:,:,1)),'CentralDifference');
targetContour3Color=repmat(jojo,[1,1,3]);
targetContour3Color(targetContour3Color>0)=1.0;
targetContour2=targetContour3Color;
targetContour3Color=targetContour3Color.*~targetArea3Color; 
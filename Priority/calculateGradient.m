function [myInitialGradientM,myInitialGradientDir] = calculateGradient(initialLabImage,targetContour2)
[myInitialGradientM(:,:,1),myInitialGradientDir(:,:,1)] = imgradient(initialLabImage(:,:,1),'CentralDifference');
[myInitialGradientM(:,:,2),myInitialGradientDir(:,:,2)] = imgradient(initialLabImage(:,:,2),'CentralDifference');
[myInitialGradientM(:,:,3),myInitialGradientDir(:,:,3)] = imgradient(initialLabImage(:,:,3),'CentralDifference');
myInitialGradientM(targetContour2>0)=0;
myInitialGradientDir(targetContour2>0)=0;
myInitialGradientDir(myInitialGradientDir<0)=180+myInitialGradientDir(myInitialGradientDir<0);





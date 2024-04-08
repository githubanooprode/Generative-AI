function [resultAngle]=findNormal(contour_Y1,contour_X1,mySize,targetContour)
%make a small patch around the point of interest
%then calculate the curve there using a least squares approximation
%to a unit circle. The calculate the tangent.

sX=3;
sY=3;
minPatchX=contour_X1-(sX-1)/2;
maxPatchX=contour_X1+(sX-1)/2;
minPatchY=contour_Y1-(sY-1)/2;
maxPatchY=contour_Y1+(sY-1)/2;

if minPatchX<1
    minPatchX=1;
    sX=sX-1;
end
if minPatchY<1 
    minPatchY=1;
    sY=sY-1;
end

if maxPatchX>mySize(2)    
    maxPatchX=mySize(2);
    sX=sX-1;
end
if maxPatchY>mySize(1)    
    maxPatchY=mySize(1);
    sY=sY-1;
end

%%
myCenter2=[floor(sX/2)+1 floor(sY/2)+1];
myCompare1=targetContour(minPatchY:maxPatchY,minPatchX:maxPatchX);
myCompare1(myCenter2(2),myCenter2(1))=0;
myNeighbors=find(myCompare1==1);


%%

resultAngle=[0,1]';
if numel(myNeighbors)>=2
    [YY,XX]=ind2sub([sY sX],myNeighbors);
    dx=abs(XX(1)-XX(2));
    dy=abs(YY(1)-YY(2));
    resultAngle=[dy,dx]';
end

resultAngle=resultAngle./norm(resultAngle);
if isnan(resultAngle(1))
    msg=sprintf('tangent problem. resultAngle=%f,%f, dx=%d, dy=%f', resultAngle(1),resultAngle(2),dx,dy);
    disp(msg);
end


%NOTE: we want the normal to the curve here, so, rotate by 90 degrees...
%resultAngle=resultAngle
theta=90;
rotateMe=[cosd(theta) -sind(theta); sind(theta) cosd(theta)];
resultAngle= rotateMe*resultAngle;


end

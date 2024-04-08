function [amoeba_map,amoeba_size] = CreateAmoeba(centers,image_gray,max_dist)
%createAmoeba(): function to create a Amoeba around a given center
%   input: coordinates of center, Lab-Image
%   output: map which discribes the amoeba (1->part of the amoeba, 0->not)
%   calculation of the amoeba based on the differences in graylevels

%height=max_dist*2+1;
%width=max_dist*2+1;
[height,width,~] = size(image_gray);
amoeba_map = zeros(height,width);
distance_values = zeros(height,width);
mult = 1.0; %value multipl. with graydiff of pixels (by now  just a random number)
candidates = centers; % list of candidates
[~,length] = size(candidates);
for i = 1:length
    center = candidates{i};
    amoeba_map(center(1),center(2)) = 1;
end
% calculating the amoeba with BFS
while length > 0
    current = candidates{1};
    candidates = candidates(2:length);
    [~,length] = size(candidates);
    % calculating candidates out of the neighborhood of the current pixel
    for i = 1:4 %1:4 for adjacent pixels 1:8 for all surrounding pixels
        switch i
            case 1 % upper pixel
                next = [current(1)-1,current(2)];
                if next(1) <= 0
                    continue
                end
            case 2 % left pixel
                next = [current(1),current(2)-1];
                if next(2) <= 0
                    continue
                end
            case 3 % lower pixel
                next = [current(1)+1,current(2)];
                if next(1) > height
                    continue
                end
            case 4 % right pixel
                next = [current(1),current(2)+1];
                if next(2) > width
                    continue
                end
            case 5 % upper left pixel
                next = [current(1)-1,current(2)-1];
                if next(1) <= 0 || next(2) <= 0
                    continue
                end
            case 6 % lower left pixel
                next = [current(1)+1,current(2)-1];
                if next(1) > height || next(2) <= 0
                    continue
                end
            case 7 % lower right pixel
                next = [current(1)+1,current(2)+1];
                if next(1) > height || next(2) > width
                    continue
                end
            case 8 % upper right pixel
                next = [current(1)-1,current(2)+1];
                if next(1) <= 0 || next(2) > width
                    continue
                end
        end
        % calculating distances between current pixel and his neighbor
        % dist = (difference of gray levels between the current and the next
        %         pixel) * mulitplier
        %         + distance to the current pixel
        %         + 1 because it's a pixel on the next level of BFS-tree
        
        image_distance = abs(image_gray(current(1),current(2))...
                              - image_gray(next(1),next(2)));
                          
        %fprintf('%d) image_distance=%f\n', i, image_distance )
        % amoeba-distance:
        dist = mult*image_distance + distance_values(current(1),current(2)) + 1;
        
        if dist <= max_dist
            if amoeba_map(next(1),next(2)) == 0
                % if next pixel not already part of amoeba, add it
                %candidates = [candidates next];
                length = length+1;
                candidates{length} = next;
                amoeba_map(next(1),next(2)) = 1;
                distance_values(next(1),next(2)) = dist;
%              else
%                  % just update the distance
%                 distance_values(next(1),next(2)) = min(distance_values(next(1),next(2)),image_distance);
            end
        end
    end
end
amoeba_size = sum(amoeba_map(:));
end
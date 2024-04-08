function [Y,X, size, center_y, center_x,failMe] = createPatch(y,x, radius, clip_dimensions)
    % Create a patch bla bla
    %
    % [Y,X, size, center_y, center_x] = create_patch(y,x, radius, clip_dimensions)
    %
    %    
    %
    failMe=0;
    if numel(radius) == 1
       radius = repmat(radius, 4,1);
    end

    right  = x + radius(1); % EAST
    bottom = y + radius(2); % SOUTH
    left   = x - radius(3); % WEST
    top    = y - radius(4); % NORTH

    Y = max(top,1)  : min(bottom, clip_dimensions(1));
    X = max(left,1) : min(right,  clip_dimensions(2));

    if  min(bottom, clip_dimensions(1)) ~=bottom
        fprintf('tried to pass lower bounds of image\n');
        failMe=1;
    end
    if   min(right,  clip_dimensions(2)) ~=right
        fprintf('tried to pass right edge of image\n');
        failMe=1;
    end
    
    if  max(top,1) ~=top
        fprintf('tried to pass upper bounds of image\n');
        failMe=1;
    end
    if  max(left, 1) ~=left
        fprintf('tried to pass left edge of image\n');
        failMe=1;
    end
    
    size = numel(X)*numel(Y);
    center_y = find(Y==y);
    center_x = find(X==x);
end

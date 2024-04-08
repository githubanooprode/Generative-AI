function blendPriority = getBlendPriorityOnlyOutsideTarget(known_area, confidence,currentStep)
    % Matching will only take place outside target area, i.e. match_priority != target_area
    blendPriority = double(known_area);
end
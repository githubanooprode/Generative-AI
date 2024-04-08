function match_priority = getMatchPriorityOnlyOutsideTarget(currentStep)
    % Matching will only take place outside target area, i.e. match_priority != target_area
    match_priority = ~currentStep.targetArea3Color(currentStep.targetPatchY,currentStep.targetPatchX,:);
end
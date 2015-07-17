function costMat = makecostmatrix(CurrObjStats, NextObjStats)
n = numel(CurrObjStats);
m = numel(NextObjStats);
% Top left quadrant.
topLeftMat = pdist2(vertcat(CurrObjStats(:).Centroid), ...
    vertcat(NextObjStats(:).Centroid));
% Determine distance thresholds.
majorAxisLengthCol = 1.5 * [CurrObjStats(:).MajorAxisLength]';
isTooFarMat = bsxfun(@ge, topLeftMat, majorAxisLengthCol);
topLeftMat(isTooFarMat) = inf;
% Compute penalties.
eccPenaltyMat = computepenalty([CurrObjStats(:).Eccentricity], ...
    [NextObjStats(:).Eccentricity]);
areaPenaltyMat = computepenalty([CurrObjStats(:).Area], ...
    [NextObjStats(:).Area]);
sumPenaltyMat = 1 + 0.5 * eccPenaltyMat + 0.5 * areaPenaltyMat;
topLeftMat = (topLeftMat .* sumPenaltyMat).^2;
% Top right quadrant.
alternativeCost = 1.05 * max(topLeftMat(~isinf(topLeftMat)));
topRightMat = alternativeCost * eye(n);
topRightMat(topRightMat == 0) = inf;
% Bottom left quadrant.
bottomLeftMat = alternativeCost * eye(m);
bottomLeftMat(bottomLeftMat == 0) = inf;
% Bottom right quadrant.
bottomRightMat = topLeftMat';
minimalCost = min(topLeftMat(~isinf(topLeftMat)));
bottomRightMat(~isinf(bottomRightMat)) = minimalCost;
% Make cost matrix.
costMat = vertcat([topLeftMat, topRightMat], ...
    [bottomLeftMat, bottomRightMat]);
end

function penaltyMat = computepenalty(currentFeatureRow, nextFeatureRow)
featureDiffMat = abs(pdist2(currentFeatureRow', nextFeatureRow', @minus));
featureSumMat = pdist2(currentFeatureRow', nextFeatureRow', @plus);
penaltyMat = 3 * featureDiffMat ./ featureSumMat;
end
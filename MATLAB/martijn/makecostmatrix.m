function costMat = makecostmatrix(CurrObjStats, NextObjStats)
n = numel(CurrObjStats);
m = numel(NextObjStats);
% Top left quadrant.
topLeftMat = pdist2(vertcat(CurrObjStats(:).Centroid), ...
    vertcat(NextObjStats(:).Centroid));

% Compute nearest-neighbor distance distribution.
distMat = pdist2(vertcat(CurrObjStats(:).Centroid), ...
    vertcat(CurrObjStats(:).Centroid));
distMat(logical(eye(n))) = inf;
minDistCol = min(distMat, [], 1);
% disp(mean(minDistCol));
% disp(std(minDistCol));
distThreshold = mean(minDistCol) + 3 * std(minDistCol);

% Determine distance thresholds.
% majorAxisLengthCol = 1.5 * [CurrObjStats(:).MajorAxisLength]';
% isTooFarMat = bsxfun(@ge, topLeftMat, majorAxisLengthCol);
isTooFarMat = topLeftMat >= distThreshold;
topLeftMat(isTooFarMat) = inf;
% Compute penalties.
eccPenaltyMat = computepenalty([CurrObjStats(:).Eccentricity], ...
    [NextObjStats(:).Eccentricity]);
areaPenaltyMat = computepenalty([CurrObjStats(:).Area], ...
    [NextObjStats(:).Area]);
intensityPenaltyMat = computepenalty([CurrObjStats(:).MeanIntensity], ...
    [NextObjStats(:).MeanIntensity]);
orientationPenaltyMat = computepenalty([CurrObjStats(:).Orientation] + 90, ...
    [NextObjStats(:).Orientation] + 90);
sumPenaltyMat = 1 + 1/4 * eccPenaltyMat + 1/4 * areaPenaltyMat + ...
    1/4 * intensityPenaltyMat + 1/4 * orientationPenaltyMat;
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
function trackIdxCell = linknuclei2(Nucleus)

% Extract region properties of detected nuclei.
StatsCell = arrayfun(@(x) ...
    regionprops(x.bwIm, x.rawIm, ...
    'Centroid', 'Area', 'Eccentricity', ...
    'MajorAxisLength', 'MeanIntensity', 'Orientation'), Nucleus, ...
    'UniformOutput', false);

% Compute linking indices.
noFrames = numel(StatsCell);
Link(noFrames - 1).idxRow = [];
Link(noFrames - 1).notIdxRow = [];
for i = 1 : (noFrames - 1)
    tmpCostMat = makecostmatrix(StatsCell{i}, StatsCell{i + 1});
    tmpSolRow = lapjv(tmpCostMat);
    % Assign nan to track endpoints.
    n = numel(StatsCell{i});
    m = numel(StatsCell{i + 1});
    tmpLinkPartIdxRow = tmpSolRow(1 : n);
    tmpLinkPartIdxRow(tmpLinkPartIdxRow > m) = nan;
    Link(i).idxRow = tmpLinkPartIdxRow;
    Link(i).notIdxRow = tmpSolRow(n + 1 : end) == 1 : m;
end

trackIdxCell = arrayfun(@(x) [x, Link(1).idxRow(x)], ...
    1 : numel(Link(1).idxRow), 'UniformOutput', false);

for i = 2 : noFrames
    
end

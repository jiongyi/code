function Tracks = linknuclei(nucleusStack, objWidth)
nFrames = size(nucleusStack, 3);
idxLinkCell = cell(1, nFrames - 1);
isNucleusCell = arrayfun(@(x) masknuclei(nucleusStack(:, :, x), objWidth), ...
    1 : nFrames, 'UniformOutput', false);
ObjPropsCell = arrayfun(@(x) ...
    regionprops(isNucleusCell{x}, nucleusStack(:, :, x), ...
    'Centroid', 'Area', 'Eccentricity', ...
    'MajorAxisLength', 'MeanIntensity', 'Orientation'), 1 : nFrames, ...
    'UniformOutput', false);
for iFrame = 1 : (nFrames - 1)
    % Compute cost matrix.
    costMat = makecostmatrix(ObjPropsCell{iFrame}, ...
        ObjPropsCell{iFrame + 1});
    % Solve cost matrix.
    idxLinkCell{iFrame} = lapjv(costMat);
    m = numel(ObjPropsCell{iFrame + 1});
    idxLinkCell{iFrame}(idxLinkCell{iFrame} >= m) = nan;
    disp(['Finished linking frame ', num2str(iFrame)]);
end

nTracks = numel(ObjPropsCell{1});
Tracks(nTracks).idxRow = [];
Tracks(nTracks).centroidCol = [];
for iTrack = 1 : nTracks
    iFrame = 1;
    idxRow = iTrack;
    centroidCol = [];
    while ~isnan(idxRow(end)) && iFrame < (nFrames)
        centroidCol = vertcat(centroidCol, ...
            ObjPropsCell{iFrame}(idxRow(end)).Centroid);
        idxRow = [idxRow, idxLinkCell{iFrame}(idxRow(end))];
        iFrame = iFrame + 1;
    end
    if ~isnan(idxRow(end))
        centroidCol = vertcat(centroidCol, ...
            ObjPropsCell{iFrame}(idxRow(end)).Centroid);
    end
    idxRow(isnan(idxRow)) = [];
    Tracks(iTrack).idxRow = idxRow;
    Tracks(iTrack).centroidCol = centroidCol;
end
end
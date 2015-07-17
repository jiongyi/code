function Tracks = linknuclei(nucleusStack)
nFrames = size(nucleusStack, 3);
idxLinkCell = cell(1, nFrames - 1);
isNucleusCell = arrayfun(@(x) masknuclei(nucleusStack(:, :, x), 5), ...
    1 : nFrames, 'UniformOutput', false);
ObjPropsCell = cellfun(@(x) ...
    regionprops(x, ...
    'Centroid', 'Area', 'Eccentricity', 'MajorAxisLength'), ...
    isNucleusCell, 'UniformOutput', false);
for iFrame = 1 : (nFrames - 1)
    % Compute cost matrix.
    costMat = makecostmatrix(ObjPropsCell{iFrame}, ...
        ObjPropsCell{iFrame + 1});
    % Solve cost matrix.
    idxLinkCell{iFrame} = lapjv(costMat);
    m = numel(ObjPropsCell{iFrame + 1});
    idxLinkCell{iFrame}(idxLinkCell{iFrame} > m) = nan;
    disp(['Finished linking frame ', num2str(iFrame)]);
end

nTracks = numel(ObjPropsCell{1});
Tracks(nTracks).idxRow = [];
Tracks(nTracks).centroidCol = [];
for iTrack = 1 : nTracks
    idxRow = iTrack;
    centroidCol = [];
    iFrame = 1;
    while ~isnan(idxRow(end)) && iFrame < (nFrames - 1)
        centroidCol = vertcat(centroidCol, ...
            ObjPropsCell{iFrame}(idxRow(end)).Centroid);
    idxRow = [idxRow, idxLinkCell{iFrame}(idxRow(end))];
    iFrame = iFrame + 1;
    end
    Tracks(iTrack).idxRow = idxRow;
    Tracks(iTrack).centroidCol = centroidCol;
end
end
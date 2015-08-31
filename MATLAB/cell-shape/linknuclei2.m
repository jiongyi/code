function [Track, Movie] = linknuclei2(Nucleus)

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

% Figure out number of tracks.
noTracks = max(arrayfun(@(x) numel(x.idxRow) + sum(x.notIdxRow), Link));

% Initialize track matrix.
trackIdxMat = nan(noTracks, noFrames);

% Populate the indices corresponding to the first frame.
noObjs = numel(Link(1).idxRow);
trackIdxMat(1 : noObjs, 1) = 1 : noObjs;
noNewTracks = sum(Link(1).notIdxRow);
trackIdxMat((noObjs + 1) : (noObjs + noNewTracks), 2) = ...
    find(Link(1).notIdxRow);

% Loop over remaining frames.
for i = 2 : noFrames
    for j = 1 : noTracks
        if ~isnan(trackIdxMat(j, i - 1))
            trackIdxMat(j, i) = Link(i - 1).idxRow(trackIdxMat(j, i - 1));
        end
    end
    if i < noFrames
        tmpCurrNoObjs = numel(Link(i).idxRow);
        tmpCurrNoNewTracks = sum(Link(i).notIdxRow);
        trackIdxMat((tmpCurrNoObjs + 1) : ...
            (tmpCurrNoObjs + tmpCurrNoNewTracks), i + 1) = ...
            find(Link(i).notIdxRow);
    end
end

% Plot tracks.
Track(noTracks).idxRow = [];
Track(noTracks).positionMat = [];
Track(noTracks).colorMat = [];
colorMap = jet(noFrames);
for j = 1 : noTracks
    Track(j).idxRow = nan(1, noFrames);
    Track(j).positionMat = nan(noFrames, 2);
    Track(j).colorMat = zeros(noFrames, 3);
    for i = 1 : noFrames
        Track(j).idxRow(i) = trackIdxMat(j, i);
        Track(j).colorMat(i, :) = colorMap(i, :);
        if ~isnan(Track(j).idxRow(i))
            Track(j).positionMat(i, :) = ...
                StatsCell{i}(Track(j).idxRow(i)).Centroid;
        end
    end
end

figure;
% Movie(noFrames) = struct('cdata', [], 'colormap', []);
writerObj = VideoWriter('tracked-nuclei.avi');
writerObj.FrameRate = 7;
open(writerObj);
for i = 1 : noFrames
    imshow(Nucleus(i).ocIm);
    hold on;
    for j = 1 : noTracks
        plot(Track(j).positionMat(1 : i, 1), ...
            Track(j).positionMat(1 : i, 2), 'color', ...
            Track(j).colorMat(i, :));
    end
    hold off;
    writeVideo(writerObj, getframe);
end
close(writerObj);
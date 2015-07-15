function [CellStats, isCellCell, cadherinStack, idxTrackCell] = trackcells(corrThreshold)
% Select files.
[cadherinFileNameStr, folderNameStr] = uigetfile('*.tif', ...
    'Select cadherin TIF');
nucleusFileNameStr = uigetfile('*.tif', ...
    'Select nucleus TIF', folderNameStr);
% Load files.
cadherinStack = imstack([folderNameStr, cadherinFileNameStr]);
nucleusStack = imstack([folderNameStr, nucleusFileNameStr]);
% Generate regional maxima mask based on nuclear stain.
% noFrames = size(cadherinStack, 3);
noFrames = 5;
isCellCell = cell(1, noFrames);
CellStats = cell(1, noFrames);
labeledCell = cell(1, noFrames);
for iFrame = 1 : size(cadherinStack, 3);
    isRegMaxIm = maskregionalmax(nucleusStack(:, :, iFrame), 3);
    isCellCell{iFrame} = markerwatershed(cadherinStack(:, :, iFrame), ...
        2, isRegMaxIm);
    labeledCell{iFrame} = bwlabel(isCellCell{iFrame});
    CellStats{iFrame} = regionprops(isCellCell{iFrame}, ...
        cadherinStack(:, :, iFrame), ...
        'BoundingBox', 'Orientation', 'WeightedCentroid');
end

noCells = numel(CellStats{1});
idxTrackCell = cell(1, noCells);
for iCell = 1 : noCells
    idxTrackCell{iCell} = nan(1, noFrames);
    templateIm = imcrop(cadherinStack(:, :, 1), ...
        CellStats{1}(iCell).BoundingBox);
    idxTrackCell{iCell}(1) = iCell;
    for iFrame = 1 : (noFrames - 1)
        if ~isnan(idxTrackCell{iCell}(iFrame))
            nextFrame = cadherinStack(:, :, iFrame + 1);
            nextLabeledFrame = labeledCell{iFrame + 1};
            [corrScore, boundingBox] = corrMatching(nextFrame, templateIm, 0);
            [maxVal, ~] = max(corrScore(:));
            if maxVal >= corrThreshold
                matchIm = imcrop(nextLabeledFrame, boundingBox);
                idxTrackCell{iCell}(iFrame + 1) = mode(matchIm(:));
                templateIm = imcrop(cadherinStack(:, :, iFrame + 1), ...
                    boundingBox);
            end
        end
        disp(['Frame ', num2str(iFrame), ' done.']);
    end
end

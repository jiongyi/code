function [frapFit, frapGof] = fitfrap(timeInterval)
%% Select and load files.
[preBleachFileName, folderName] = uigetfile('FRAP Pre Series*.tif', ...
    'Select pre-bleach image sequence');
preBleachImCell = imreadtiff([folderName, preBleachFileName]);
postBleachFileName = uigetfile('FRAP Pb1 Series*.tif', ...
    'Select post-bleach image sequence', folderName);
postBleachImCell = imreadtiff([folderName, postBleachFileName]);

%% Average pre- and post-bleach frames.
preBleachMeanIm = mean(cat(3, preBleachImCell{:}), 3);
postBleachMeanIm = mean(cat(3, postBleachImCell{1:3}), 3);

%% Figure out bleached region.
diffIm = preBleachMeanIm - postBleachMeanIm;
diffIm = mat2gray(diffIm);
isBleachedIm = im2bw(diffIm, graythresh(diffIm));
isBleachedIm = imopen(isBleachedIm, strel('square', 3));
isBleachedIm = imclearborder(isBleachedIm);
isBleachedIm = imfill(isBleachedIm, 'holes');
isBleachedIm = bwareaopen(isBleachedIm, 25);
% Check is bleached region mask has only one region.
regPropStruct = regionprops(isBleachedIm, 'Area', 'PixelIdxList');
if numel(regPropStruct) == 0
    error('No bleach point detected. Closing.');
elseif numel(regPropStruct) > 1
    disp('More than one bleach region detected. Picking largest.');
    isBleachedIm = false(size(isBleachedIm));
    isBleachedIm(regPropStruct([regPropStruct(:).Area] == ...
        max([regPropStruct(:).Area])).PixelIdxList) = true;
% else
%     isBleachedIm = regPropStruct(1).ConvexImage;
end
%% Calculate bleaching correction.
postBleachMeanIm = mat2gray(postBleachMeanIm);
isSignalIm = im2bw(postBleachMeanIm, graythresh(postBleachMeanIm));
postBleachMeanSignalRow = cellfun(@(x) mean(x(isSignalIm)), ...
    postBleachImCell);
timeRow = cumsum([0, timeInterval * ones(1, numel(postBleachImCell) - 1)]);
bleachFit = fit(timeRow', postBleachMeanSignalRow', 'poly1');

%% Compute mean post-bleach intensities.
postBleachMeanROIRow = cellfun(@(x) mean(x(isBleachedIm)), ...
    postBleachImCell);
% Normalize by pre-bleach mean intensity.
postBleachMeanROIRow = postBleachMeanROIRow / ...
    mean(preBleachMeanIm(isBleachedIm));
% Correct for photobleaching.
postBleachMeanROIRow = postBleachMeanROIRow - bleachFit.p1 * timeRow;
% Offset by first postbleach measurement.
postBleachMeanROIRow = postBleachMeanROIRow - postBleachMeanROIRow(1);

%% Fit.
[frapFit, frapGof] = fit(timeRow', postBleachMeanROIRow', ...
    'm * (1 - exp(-x / k))', 'Start', [50, 0.5]);
% Check residuals.
residualsRow = frapFit(timeRow)' - postBleachMeanROIRow;
[h, p] = adtest(residualsRow);
hResiAutoCorr = figure('color', 'w');
autocorr(residualsRow);
box off;
set(gca, 'tickdir', 'out');
if h == true
    disp(['The residuals are not distributed normally (', ...
        num2str(p), ')'])
end

%% Display results.
hFRAPFig = figure('color', 'w');
plot(frapFit, timeRow, postBleachMeanROIRow);
ciFRAPRow = predint(frapFit, timeRow);
hold on;
plot(timeRow, ciFRAPRow, 'r--');
hold off;
legend off;
box off;
set(gca, 'tickdir', 'out');
xlabel('Time (s)');
ylabel('Mean normalized intensity');
print(gcf, '-dpdf', [folderName, postBleachFileName(1 : end - 4), ...
    '_recovery_fit']);
% Make marked up movie.
isPerimIm = bwperim(isBleachedIm);
overlaidImCell = cellfun(@(x) imoverlay(x, isPerimIm, [0, 1, 0]), ...
    postBleachImCell, 'UniformOutput', false);
implay(cat(4, overlaidImCell{:}), 4);

%% Save results.
print(hFRAPFig, '-dpdf', [folderName, postBleachFileName(1 : end - 4), ...
    '_frap_curve']);
print(hResiAutoCorr, '-dpdf', [folderName, ...
    postBleachFileName(1 : end - 4), '_resi_autocorr']); 
end

function tiffCell = imreadtiff(tiffFilePath)
infoStruct = imfinfo(tiffFilePath);
noImages = numel(infoStruct);
tiffCell = arrayfun(@(x) im2double(imread(tiffFilePath, x)), 1 : noImages, ...
    'UniformOutput', false);
end
function thetaCell = analyzecellorientation()
% Select files.
[cadherinFileNameStr, folderNameStr] = uigetfile('*.tif', ...
    'Select cadherin TIF');
nucleusFileNameStr = uigetfile('*.tif', ...
    'Select nucleus TIF', folderNameStr);
% Load files.
cadherinStack = imstack([folderNameStr, cadherinFileNameStr]);
nucleusStack = imstack([folderNameStr, nucleusFileNameStr]);
% Generate regional maxima mask based on nuclear stain.
noStack = size(cadherinStack, 3);
thetaCell = cell(1, noStack);
for iStack = 1 : size(cadherinStack, 3);
    isRegMaxIm = maskregionalmax(nucleusStack(:, :, iStack), 3);
    isCellIm = markerwatershed(cadherinStack(:, :, iStack), ...
        2, isRegMaxIm);
    thetaCell{iStack} = calculateorientation(isCellIm);
end

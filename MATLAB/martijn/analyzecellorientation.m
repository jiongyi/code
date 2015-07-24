function [thetaCell, fusedCellStack] = analyzecellorientation(cadWidth, nucWidth)
% Select files.
[cadherinFileNameStr, folderNameStr] = uigetfile('*.tif', ...
    'Select cadherin TIF', '/home/jiongyi/Documents/MATLAB/martijn');
nucleusFileNameStr = uigetfile('*.tif', ...
    'Select nucleus TIF', folderNameStr);
% Load files.
cadherinStack = imstack([folderNameStr, cadherinFileNameStr]);
nucleusStack = imstack([folderNameStr, nucleusFileNameStr]);
% Generate regional maxima mask based on nuclear stain.
noStack = size(cadherinStack, 3);
thetaCell = cell(1, noStack);
isCellStack = false(size(cadherinStack));
fusedCellStack = uint8(zeros([size(cadherinStack(:, :, 1)), ...
    3, size(cadherinStack, 3)]));
for iStack = 1 : size(cadherinStack, 3);
%     isRegMaxIm = maskregionalmax(nucleusStack(:, :, iStack), nucWidth);
%     [isCellStack(:, :, iStack), fusedCellStack(:, :, :, iStack)] = ...
%         markerwatershed(cadherinStack(:, :, iStack), ...
%         cadWidth, isRegMaxIm);
    Cell = maskcells(cadherinStack(:, :, iStack), ...
        nucleusStack(:, :, iStack), cadWidth, nucWidth);
    isCellStack(:, :, iStack) = Cell.bwIm;
    fusedCellStack(:, :, :, iStack) = Cell.fusedIm;
    thetaCell{iStack} = calculateorientation(isCellStack(:, :, iStack));
end
implay(fusedCellStack);
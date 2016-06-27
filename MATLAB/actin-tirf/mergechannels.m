function [actinImStack, abpImStack] = mergechannels()

% Get file names.
[actinFileNameStrCell, folderNameStr] = uigetfile('*_t561_C0.tiff', ...
    'Select actin images', 'MultiSelect', 'on');
abpFileNameStrCell = uigetfile('*_flat.tiff', ...
    'Select flattened abp images', folderNameStr, 'MultiSelect', 'on');
if ~iscell(actinFileNameStrCell)
    actinFileNameStrCell = {actinFileNameStrCell};
end
if ~iscell(abpFileNameStrCell)
    abpFileNameStrCell = {abpFileNameStrCell};
end

% Load images.
noImages = numel(actinFileNameStrCell);
actinImCell = cellfun(@(x) imread([folderNameStr, x]), ...
    actinFileNameStrCell, 'UniformOutput', false);
abpImCell = cellfun(@(x) imread([folderNameStr, x]), ...
    abpFileNameStrCell, 'UniformOutput', false);

% Process images.
actinImStack = adapthisteq(mat2gray(cat(2, actinImCell{:})), ...
    'distribution', 'exponential');
% actinImStack = imadjust(cat(2, actinImCell{:}));
abpImStack = adapthisteq(mat2gray(cat(2, abpImCell{:})), ...
    'distribution', 'exponential');

% Reshape images.
actinImStack = reshape(actinImStack, [512, 512, noImages]).^1;
abpImStack = reshape(abpImStack, [512, 512, noImages]).^0.5;

% Convert to rgb and save.
zeroIm = zeros(512, 512);
for i = 1 : noImages
    tmpRGBIm = cat(3, actinImStack(:, :, i), abpImStack(:, :, i), zeroIm);
    imwrite(tmpRGBIm, ...
        [folderNameStr, ...
        actinFileNameStrCell{i}(1 : end - 13), '_merged.tiff']);
end
end
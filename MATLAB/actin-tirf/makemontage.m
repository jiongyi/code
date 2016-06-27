function makemontage()

% Get file names.
[fileNameStrCell, folderNameStr] = uigetfile('*.tiff', ...
    'Select stacks for montage', 'MultiSelect', 'on');
if ~iscell(fileNameStrCell)
    fileNameStrCell = {fileNameStrCell};
end

% Load images
stacksCell = cellfun(@(x) imstack([folderNameStr, x]), fileNameStrCell, ...
    'UniformOutput', false);
noStacksRow = cellfun(@(x) size(x, 3), stacksCell);
minNoStacks = min(noStacksRow);
stacksCell = cellfun(@(x) x(:, :, 1 : minNoStacks), stacksCell, ...
    'UniformOutput', false);
% Make montage.
montageStack = cat(2, stacksCell{:});
normMontageStack = mat2gray(montageStack);

% Save montage.
saveFileNameStr = input('Save as: ', 's');
noSlices = size(normMontageStack, 3);
for i = 1 : noSlices
    imwrite(uint16(normMontageStack(:, :, i) * (2^16 - 1)), ...
        [folderNameStr, saveFileNameStr], 'writemode', 'append'); 
end

end
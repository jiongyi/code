function makergbstack()

% Get file names.
[redChannelfileNameStrCell, folderNameStr] = uigetfile('*_t561_C0.tiff', ...
    'Select red channel images', 'MultiSelect', 'on');
if ~iscell(redChannelfileNameStrCell)
    redChannelfileNameStrCell = {redChannelfileNameStrCell};
end

greenChannelfileNameStrCell = cellfun(@(x) ...
    [x(1 : end - 13), '_t488_C1.tiff'], redChannelfileNameStrCell, ...
    'UniformOutput', false);

% Load images.
redChannelImgsCell = cellfun(@(x) imread([folderNameStr, x]), ...
    redChannelfileNameStrCell, 'UniformOutput', false);
greenChannelImgsCell = cellfun(@(x) imread([folderNameStr, x]), ...
    greenChannelfileNameStrCell, 'UniformOutput', false);

% Enhance contrast.
redChannelImgsCell = cellfun(@(x) ...
    adapthisteq(x, 'distribution', 'exponential'), redChannelImgsCell, 'UniformOutput', false);
greenChannelImgsCell = cellfun(@(x) ...
    adapthisteq(x, 'distribution', 'exponential'), greenChannelImgsCell, 'UniformOutput', false);

% Subtract background.
structEl = strel('disk', 20);
redChannelImgsCell = cellfun(@(x) imtophat(x, structEl), ...
    redChannelImgsCell, 'UniformOutput', false);
greenChannelImgsCell = cellfun(@(x) imtophat(x, structEl), ...
    greenChannelImgsCell, 'UniformOutput', false);

% Normalize and stack.
redChannelStack = mat2gray(cat(3, redChannelImgsCell{:}));
greenChannelStack = mat2gray(cat(3, greenChannelImgsCell{:}));

% Make rgb stack.
blueChannelIm = zeros(512, 512);
noSlices = numel(redChannelfileNameStrCell);
rgbImgsCell = arrayfun(@(x) cat(3, ...
    redChannelStack(:, :, x), greenChannelStack(:, :, x), blueChannelIm), ...
    1 :  noSlices, 'UniformOutput', false);

% Save rgb stack.
stackFileNameStr = input('Save as: ', 's');
for i = 1 : noSlices
    imwrite(uint8(rgbImgsCell{i} * 255), ...
        [folderNameStr, stackFileNameStr], 'writeMode', 'append');
end
end
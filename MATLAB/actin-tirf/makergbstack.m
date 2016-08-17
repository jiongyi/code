function makergbstack()

% Get file names.
[redChannelfileNameStrCell, folderNameStr] = uigetfile('*_Cy5_C0.tiff', ...
    'Select red channel images', 'MultiSelect', 'on');
if ~iscell(redChannelfileNameStrCell)
    redChannelfileNameStrCell = {redChannelfileNameStrCell};
end

greenChannelfileNameStrCell = cellfun(@(x) ...
    [x(1 : end - 12), '_t488_C1.tiff'], redChannelfileNameStrCell, ...
    'UniformOutput', false);

% Load images.
redChannelImgsCell = cellfun(@(x) imread([folderNameStr, x]), ...
    redChannelfileNameStrCell, 'UniformOutput', false);
greenChannelImgsCell = cellfun(@(x) imread([folderNameStr, x]), ...
    greenChannelfileNameStrCell, 'UniformOutput', false);

% Make montages for image processing.
redChannelMont = mat2gray(cat(2, redChannelImgsCell{:}));
greenChannelMont = mat2gray(cat(2, greenChannelImgsCell{:}));

% Wiener2
redChannelMont = wiener2(redChannelMont);
greenChannelMont = wiener2(greenChannelMont);

% Enhance contrast.
redChannelMont = imadjust(redChannelMont);
greenChannelMont = imadjust(greenChannelMont); 


% Subtract background.
redChannelMont = imtophat(redChannelMont, strel('ball', 50, 50));
greenChannelMont = imtophat(greenChannelMont, strel('ball', 50, 50));

% Stack.
noImages = numel(redChannelImgsCell);
redChannelStack = mat2gray(reshape(redChannelMont, [512, 512, noImages]));
greenChannelStack = mat2gray(reshape(greenChannelMont, [512, 512, noImages]));
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
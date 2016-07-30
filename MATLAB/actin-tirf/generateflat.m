function flatIm = generateflat(folderNameStr, fileNameStr)

% Load images.
rawImCll = cellfun(@(x) im2double(imread([folderNameStr, x])), ...
    fileNameStr, 'UniformOutput', false);

meanIm = mean(cat(3, rawImCll{:}), 3);
flatIm = meanIm / mean(meanIm(:));
end
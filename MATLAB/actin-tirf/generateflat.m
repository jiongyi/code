function flatIm = generateflat(folderNameStr, fileNameStr)

% Load images.
rawImCll = cellfun(@(x) im2double(imread([folderNameStr, x])), ...
    fileNameStr, 'UniformOutput', false);

medianIm = median(cat(3, rawImCll{:}), 3);
flatIm = medianIm / mean(medianIm(:));
end
function A = imstack(stackFilePathStr)
info = imfinfo(stackFilePathStr);
num_images = numel(info);
[m, n] = size(imread(stackFilePathStr, 1, 'Info', info));
A = zeros(m, n, num_images);
for k = 1 : num_images
    A(:, :, k) = imread(stackFilePathStr, k, 'Info', info);
end
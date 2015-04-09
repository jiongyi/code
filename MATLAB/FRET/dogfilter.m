function [backSubIm, bwIm] = dogfilter(rawIm)

% Smooth image using a rolling ball.
diskFiltIm = imfilter(rawIm, fspecial('disk', 6), 'symmetric');

% Binarize.
normIm = mat2gray(diskFiltIm);
% At least two levels are necessary to take care of multiple cells in FOV.
[threshold, metric] = multithresh(normIm, 2);
disp(num2str(metric));
seg_I = imquantize(normIm, threshold);

% Show segmentation results.
% RGB = label2rgb(seg_I);
% figure; imshowpair(normIm, RGB, 'montage');
% axis off;

% Subtract background.
% blurrIm = imfilter(rawIm, fspecial('gaussian', 6, 2), 'symmetric');
snrIm = rawIm ./ mean(rawIm(seg_I == 1));
backThreshold = 1 + 0 * std(snrIm(seg_I == 1));
% figure; imshow(snrIm, []); colorbar;

backSubIm = rawIm - median(rawIm(snrIm >= backThreshold));
backSubIm(backSubIm < 0) = 0;
% backSubIm = imfilter(backSubIm, fspecial('gauss', 6, 2), 'symmetric');
% figure; imshow(backSubIm, []); colorbar;
bwIm = seg_I == 1;
% backSubIm = medfilt2(backSubIm, [2, 2]);
% backSubIm = imfilter(backSubIm, fspecial('gauss', 6, 2), 'symmetric');
end

function bwIm = maskcontacts(rawIm, objWidth)
rawIm = im2double(rawIm);
% Convert to local SNR image.
snrIm = rawIm ./ imopen(rawIm, strel('sq', objWidth));
snrIm = adapthisteq(mat2gray(snrIm));
medIm = medfilt2(snrIm);
% Binarize
normIm = mat2gray(medIm);
bwIm = im2bw(normIm, graythresh(normIm));
bwIm = imopen(bwIm, strel('sq', 3));
% figure; imshowpair(rawIm, bwIm, 'montage');
end
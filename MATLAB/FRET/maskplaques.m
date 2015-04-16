function maskplaques(im)

im = im2double(im);
im = mat2gray(im);

psfFilteredIm = imfilter(im, fspecial('gaussian', 3, 1), 'symmetric');
backFilteredIm = imfilter(im, fspecial('gaussian', 300, 100), 'symmetric');
im = mat2gray(psfFilteredIm - backFilteredIm);
thresholdRow = multithresh(im, 10);
labeledIm = imquantize(im, thresholdRow);
rgbIm = label2rgb(labeledIm);
figure;
imshowpair(im, rgbIm, 'montage');
function maskplaques(rawIm, objPixWidth)

% Convert and double and scale to [0, 1].
rawIm = im2double(rawIm);
rawIm = mat2gray(rawIm);
rawIm = medfilt2(rawIm);

% Apply difference-of-gaussian filter.
psfFilteredIm = imfilter(rawIm, fspecial('gaussian', 3, 1), 'symmetric');
backFilteredIm = imfilter(rawIm, ...
    fspecial('average', objPixWidth), 'symmetric');
dogIm = imsubtract(psfFilteredIm, backFilteredIm);
dogIm(rawIm < 0) = 0;
dogIm = mat2gray(dogIm);

% Convert to signal-to-noise ratio representation.
bwIm = im2bw(dogIm, graythresh(dogIm));
snrIm = dogIm / mean(dogIm(~bwIm));

snrIm = snrIm - mean(snrIm(bwIm));
snrIm(snrIm < 0) = 0;
figure('color', 'w');
imshow(snrIm, []);
colorHandle = colorbar;
colorTitleHandle = get(colorHandle, 'Title');
set(colorTitleHandle, 'String', 'SNR');
axis square off;
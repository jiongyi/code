function isPlaqueIm = maskplaques(rawIm, objPixWidth)

% Convert and double and scale to [0, 1].
rawIm = im2double(rawIm);
rawIm = mat2gray(rawIm);
rawIm = medfilt2(rawIm);

% Apply difference-of-gaussian filter.
psfFilteredIm = imfilter(rawIm, fspecial('gaussian', 3, 1), 'symmetric');
backFilteredIm = imfilter(rawIm, ...
    fspecial('gaussian', 3 * objPixWidth, objPixWidth), 'symmetric');
dogIm = imsubtract(psfFilteredIm, backFilteredIm);
dogIm(rawIm < 0) = 0;
dogIm = mat2gray(dogIm);

% Convert to signal-to-noise ratio representation.
bwIm = im2bw(dogIm, graythresh(dogIm));
snrIm = dogIm / mean(dogIm(~bwIm));

% Watershed.
maxIm = imextendedmax(snrIm, 0.5 * std(snrIm(bwIm)));
compIm = imcomplement(snrIm);
modIm = imimposemin(compIm, ~bwIm | maxIm);
shedIm = watershed(modIm);
isPlaqueIm = shedIm > 1;
isPlaqueIm = imclose(isPlaqueIm, strel('sq', 3));

% Display result.
figure('color', 'white');
grayIm = imcomplement(mat2gray(rawIm));
perimIm = bwperim(isPlaqueIm);
rbIm = grayIm .* ~perimIm;
imshow(cat(3, grayIm, rbIm, grayIm));
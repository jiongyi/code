%% Opening images in MATLAB.
cadherinIm = imread('cadherin.tif');
nucleusIm = imread('hoescht.tif');
%% Displaying images in MATLAB.
% Create a new window.
figure;
% Show image. The [] argument autoscales the image histogram.
imshow(cadherinIm, []);
title('Raw image');
%% Image bit-depth in MATLAB.
% Display histogram of pixel intensities.
figure;
imhist(cadherinIm);
title('Histogram of the raw image');
% The range of the histogram depends on the bit depth of the image. The bit
% depth is the number of bits that can be used to represent pixel intensity
% values. We can look up the bit depth:
bitDepth = class(cadherinIm);
disp(bitDepth);
% Images that have a 16-bit depth are class uint16 in MATLAB. This class
% stores numbers ranging from (0 to 2^16 - 1). There is also a function
% that determines the maximum numerical value that can be stored by a given
% class.
maxValue = intmax(bitDepth);
disp(maxValue);
%% Intensity-based thresholding of raw images.
% Thresholding splits a distribution of pixel intensities into a background
% and a foreground sub-distribution. All pixel intensities less than the
% chosen threshold value become background pixels, and those greater than
% this value become foreground pixels.
% There are many ways to calculate this threshold value. One of the most
% common ways to do it is using Otsu's method. The threshold calculated
% using this method minimizes the sum of the variances of the background
% and foreground sub-distributions. MATLAB can calculate this threshold,
% but we have to normalize the raw image.
normCadIm = mat2gray(cadherinIm); % Normalizes the raw image to [min, max]
figure;
imhist(normCadIm);
title('Histogram of the normalized image');
otsuThreshold = graythresh(normCadIm);
disp(otsuThreshold);
% The following lines just display the threshold line that splits the
% intensity distribution.
hold on;
yLimRow = get(gca, 'ylim');
plot([otsuThreshold, otsuThreshold], [yLimRow(1), yLimRow(2)], ...
    'r--');
hold off;
% Let's try thresholding the image using the calculated threshold.
threshIm = im2bw(normCadIm, otsuThreshold);
figure;
imshow(threshIm);
title('Otsu threshold applied to normalized image');
%% Processing the normalized image to improve thresholding results.
% Simple thresholding of the normalized raw image rarely every works. In
% nearly all cases images have to be manipulated to make the identification
% of foreground objects more accurate.
%% Contrast enhancement using histogram equalization.
% Pixel intensities rarely every take up the whole dynamic range (bit
% depth) captured by the camera. To improve contrast, the histogram of the
% raw image can be flattened to take up the unused range. This process is
% called histogram equalization.
eqCadIm = adapthisteq(normCadIm);
figure;
imhist(eqCadIm);
title('Histogram of the histogram-equalized image');
figure;
imshowpair(normCadIm, eqCadIm, 'montage'); % Shows images side-by-side.
%% Thresholding the histogram-equalized image.
% Practice: calculate threshold value using Otsu's method; threshold
% eqCadIm; display threshIm and the new thresholded eqCadIm side by side.
%% Background subtraction.
% The major downfall of contrast-enhancement is that it increases noise as
% well. There are many types of image noise; for example, cameras introduce
% high frequency noise (salt-and-pepper), while lower frequency noise can
% result from unwanted localization of signal and imaging artifacts. Since
% there are many types of noise, there are equally many ways of subtracting
% it.
%% Background substraction by rolling-ball (ImageJ).
% This method is equivalent to ImageJ/Fiji's default rolling-ball
% substraction. imtophat performs a morphological operation called opening
% to estimate the local background, which is then subtracted from the
% original image. We'll go over morphological operations later.
ballRadius = 5;
rollBallSE = strel('ball', ballRadius, 1);
tophatIm = imtophat(eqCadIm, rollBallSE);
figure; imshowpair(eqCadIm, tophatIm, 'montage');
%% Background substraction by local average intensity.
% This is another simple method that substracts the local average intensity
% from the original image. This method works well when the size of the
% local window is large enough to determine the local background intensity
% accurately. Thus, this method has a hard time when foreground objects are
% really close to each other.
objRadius = 5;
averageFiltObj = fspecial('average', objRadius);
localBackIm = imfilter(eqCadIm, averageFiltObj, 'replicate', 'same');
localBackSubIm = eqCadIm - localBackIm;
figure; imshowpair(eqCadIm, localBackSubIm, 'montage');
%% Background substraction by difference of gaussians.
% Probably one of the better simple filters out there because it takes care
% of low and high frequency noise.
smallSigma = 2;
bigSigma = 50;
smallGaussFiltObj = fspecial('gaussian', 6 * smallSigma + 1, smallSigma);
bigGaussFiltObj = fspecial('gaussian', 6 * bigSigma + 1, bigSigma);
figure; imshow(smallGaussFiltObj, [], 'InitialMagnification', 'fit');
colormap jet;
figure; imshow(bigGaussFiltObj, [], 'InitialMagnification', 'fit');
colormap jet;
smallGaussIm = imfilter(eqCadIm, smallGaussFiltObj, 'replicate', 'same');
bigGaussIm = imfilter(eqCadIm, bigGaussFiltObj, 'replicate', 'same');
dogIm = smallGaussIm - bigGaussIm;
figure; imshowpair(eqCadIm, dogIm, 'montage');
%% Practice: Do the backgrond substraction methods improve thresholding?
% Tip: Background substraction can generate pixels with negative
% intensity values. Use matgray() to normalize the pixel intensities to [0, 1].
%% Watershed segmentation
% The principle behind watershed segmentation is analogous to flooding some 
% sort of terrain, where the basins are filled up with water first, and when 
% the water overflows these basins at their ridges, the algorithm marks these 
% ridges as the boundaries between objects.
% The name of the game in this type of segmentation is to mark these basin 
% regions and where the ridges should be. In fluorescent cadherin images, the 
% cell bodies could be treated as the basins, and the contacts could be the 
% ridges. In this sense, these basins could be marked as the regional minima 
% in the image like so:
isBasinIm = imregionalmin(eqCadIm);
% The next trick is to make sure that the watershed or flooding begins at the 
% same depth, so what is typically done is to impose global minima at the 
% locations of the basins:
minIm = imposemin(eqCadIm, isBasinIm);
% This function imposes minima by setting the pixel values at local minima to 
% negative infinity. At this point, one can also mark up the ridges by perhaps 
% finding the local maxima in the image, but one can still try the watershed 
% process using an image where the basins have been marked:
waterIm = watershed(minIm);
% One can display the results of the segmentation by labeling each object using
% a specific color:
rgbIm = label2rgb(waterIm, 'jet', 'w', 'shuffle');


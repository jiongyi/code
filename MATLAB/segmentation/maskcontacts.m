function bwIm = maskcontacts(rawIm, objWidth, regMinThreshold)
% Jiongyi Tan
% 2015 May 20
% rawIm: input grayscale image.
% objWidth: pixel-width of local background. Shoot for ~10X the size of 
%           what you want to mask.
% regMinThreshold: intensity value ([0, 1]) of regional minima to suppress.
%                  Start with lower values and increase them if results are
%                  oversegmented.
%--------------------------------------------------------------------------
% Convert to double-precision and re-scale.
rawIm = im2double(rawIm);
% Calculate local signal-to-noise ratios.
% In a way this corrects for uneven illumination.
snrIm = rawIm ./ imfilter(rawIm, fspecial('average', objWidth), ...
    'replicate');
% Enhance contrast by adaptive histogram equalization.
eqIm = adapthisteq(mat2gray(snrIm));
% Filter specke noise using a 3x3 median filter.
medIm = medfilt2(eqIm);
% Suppress regional minima to mark the basins for the watershed algorithm.
% The cell-cell contacts are supposed to be the ridges.
imposedIm = imhmin(medIm, regMinThreshold);
% Apply watershed algorithm.
waterIm = watershed(imposedIm);
% Create binary mask of cell-cell contacts.
% The contacts are one pixel-wide, and thickness estimation needs to be
% implemented in the future.
bwIm = waterIm == false;
bwIm = imdilate(bwIm, strel('sq', 3));

% Display results.
[m, n] = size(bwIm);
greenIm = cat(3, zeros(m, n), bwIm, zeros(m, n));
figure('color', 'w');
imshowpair(rawIm, greenIm, 'blend'); axis off;
end
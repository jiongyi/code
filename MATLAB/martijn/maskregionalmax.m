function isRegMaxIm = maskregionalmax(rawIm, objWidth)
% Normalize and flatten image.
eqIm = adapthisteq(mat2gray(im2double(rawIm)));
dogIm = dogfilter(eqIm, objWidth);
% Open-close median-filtered image.
openClosedIm = imopenclose(dogIm, objWidth);
% Watershed.
isRegMaxIm = imerode(imregionalmax(openClosedIm), strel('sq', 5));
bwIm = im2bw(openClosedIm, graythresh(openClosedIm));
minIm = imimposemin(imcomplement(openClosedIm), ~bwIm | isRegMaxIm);
shedIm = watershed(minIm);
isRegMaxIm = imclearborder(shedIm > 1);
end
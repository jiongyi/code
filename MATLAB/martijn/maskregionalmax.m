function isRegMaxIm = maskregionalmax(rawIm, objWidth)
% Normalize and flatten image.
flatIm = imflat(rawIm, objWidth, 10 * objWidth);
% Open-close median-filtered image.
openClosedIm = imopenclose(flatIm, 2);
isRegMaxIm = imopen(imregionalmax(openClosedIm), strel('sq', 3));
end
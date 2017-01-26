function dogIm = imdog(rawIm, pxRadius)

grayIm = im2double(rawIm);
dogIm = imcomplement(imfilter(grayIm, fspecial('log', ...
    6 * pxRadius + 1, pxRadius), 'replicate'));
end
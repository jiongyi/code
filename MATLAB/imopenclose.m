function openClosedIm = imopenclose(rawIm, objWidth)
% Open-closes rawIm using a square structuring element of width objWidth.
% Convert to double if rawIm is still uint*.
if strcmp(class(rawIm), 'double')
    rawIm = im2double(rawIm);
end
% Open-close median-filtered image.
erodedIm = imerode(rawIm, strel('square', objWidth));
openedIm = imreconstruct(erodedIm, rawIm);
dilatedIm = imdilate(openedIm, strel('square', objWidth));
openClosedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
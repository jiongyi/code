function openClosedIm = imopenclose(rawIm, objWidth)
% Open-close median-filtered image.
erodedIm = imerode(rawIm, strel('square', objWidth));
openedIm = imreconstruct(erodedIm, rawIm);
dilatedIm = imdilate(openedIm, strel('square', objWidth));
openClosedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
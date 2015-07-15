function openClosedIm = imopenclose(rawIm, objWidth)
% Open-close median-filtered image.
erodedIm = imerode(rawIm, strel('disk', objWidth));
openedIm = imreconstruct(erodedIm, rawIm);
dilatedIm = imdilate(openedIm, strel('disk', objWidth));
openClosedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
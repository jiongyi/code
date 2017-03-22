function openClosedIm = imopenclose(rawIm, radius)
% Open-closes rawIm using a square structuring element of width objWidth.

% Open by reconstruction.
structEl = strel('disk', radius);
erodedIm = imerode(rawIm, structEl);
openedIm = imreconstruct(erodedIm, rawIm);

% Close by reconstruction.
dilatedIm = imdilate(openedIm, structEl);
openClosedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
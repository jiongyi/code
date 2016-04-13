function openClosedIm = imopenclose(rawIm, radius)
% Open-closes rawIm using a square structuring element of width objWidth.
% Convert to double if rawIm is still uint*.
if strcmp(class(rawIm), 'double')
    rawIm = im2double(rawIm);
end
% Open by reconstruction.
structEl = strel('disk', radius, 0);
erodedIm = imerode(rawIm, structEl);
openedIm = imreconstruct(erodedIm, rawIm);

% Close by reconstruction.
dilatedIm = imdilate(openedIm, structEl);
openClosedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(openedIm)));
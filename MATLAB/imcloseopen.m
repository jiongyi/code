function closedOpenedIm = imcloseopen(rawIm, radius)

% Change to type double.
if strcmp(class(rawIm), 'double')
    rawIm = im2double(rawIm);
end

% Create structuring element.
structEl = strel('disk', radius);

% Close by reconstruction.
dilatedIm = imdilate(rawIm, structEl);
closedIm = imcomplement(imreconstruct(imcomplement(dilatedIm), ...
    imcomplement(rawIm)));

% Open by reconstruction.
erodedIm = imerode(closedIm, structEl);
closedOpenedIm = imreconstruct(erodedIm, closedIm);

end
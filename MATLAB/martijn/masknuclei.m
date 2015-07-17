function isNucleusIm = masknuclei(nucleusIm, objWidth)
eqIm = mat2gray(im2double(nucleusIm));
dogIm = dogfilter(eqIm, objWidth);
openClosedIm = imopenclose(dogIm, objWidth);
bwIm = im2bw(openClosedIm, graythresh(openClosedIm));
bwIm = imclearborder(bwIm);
bwIm = imfill(bwIm, 'holes');
% Clean up nuclei too big or too small, too dim or too bright.
labeledIm = bwlabel(bwIm);
Stats = regionprops(bwIm, nucleusIm, 'Area', 'MeanIntensity');
areaRow = [Stats(:).Area];
areaBoundaryRow = prctile(areaRow, [0.15, 99.85]);
idxIgnoreAreaRow = find(areaRow <= areaBoundaryRow(1) | ...
    areaRow >= areaBoundaryRow(2));
meanIntensityRow = [Stats(:).MeanIntensity];
intensityBoundaryRow = prctile(meanIntensityRow, [0.15, 99.85]);
idxIgnoreIntensityRow = find(...
    meanIntensityRow <= intensityBoundaryRow(1) | ...
    meanIntensityRow >= intensityBoundaryRow(2));
idxIgnoreRow = union(idxIgnoreAreaRow, idxIgnoreIntensityRow);
bwIm(ismember(labeledIm, idxIgnoreRow)) = false;
isNucleusIm = bwIm;
end
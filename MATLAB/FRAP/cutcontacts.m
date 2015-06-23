function cutcontacts(isContactIm)
dilatedIm = imdilate(isContactIm, strel('square', 3));
thinIm = bwmorph(dilatedIm, 'thin', inf);
cutIm = dilatedIm - thinIm;
figure; imshow(label2rgb(watershed(cutIm)));
% branchIm = bwmorph(thinIm, 'branchpoints');
% [~, idxBackIm] = bwdist(~isContactIm);
% bwIm = and(thinIm, imdilate(branchIm, strel('square', 3)));
% bwIm = imdilate(branchIm, strel('square', 5));
% idxBranchRow = find(bwIm);
% noBranches = numel(idxBranchRow);
% cutIm = false(size(isContactIm));
% for i = 1 : noBranches
%     cutIm(idxBackIm == idxBackIm(idxBranchRow(i))) = true;
% end
% cutIm = bwmorph(cutIm, 'thin', inf);
end
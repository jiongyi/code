function filteredIm = dogfilter(rawIm)
psfFilteredIm = imfilter(rawIm, fspecial('gaussian', 6, 2), ...
    'symmetric');
backFilteredIm = imfilter(rawIm, fspecial('gaussian', 600, 200), ...
    'symmetric');
filteredIm = imsubtract(psfFilteredIm, backFilteredIm);
filteredIm(filteredIm < 0) = 0;
end

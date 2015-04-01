function filteredIm = dogfilter(rawIm)
psfFilteredIm = imfilter(rawIm, fspecial('gaussian', ...
    6, 2), 'replicate');
backFilteredIm = imfilter(rawIm, fspecial('gaussian', ...
    900, 300), 'replicate');
filteredIm = imsubtract(psfFilteredIm, backFilteredIm);
end

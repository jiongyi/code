function lfdIm = imbfd(bwIm, objWidth)
% normIm = mat2gray(rawIm);
% bwIm = im2bw(normIm, graythresh(normIm));
lfdIm = nlfilter(bwIm, [objWidth, objWidth], @computelfd);
end

function lfd = computelfd(subIm)
if sum(subIm(:)) > 0
    [N, r] = boxcount(subIm);
    x = -log(r);
    xMu = mean(x);
    y = log(N);
    yMu = mean(y);
    lfd = dot(x - xMu, y - yMu) / dot(x - xMu, x - xMu);
else
    lfd = 0;
end
end
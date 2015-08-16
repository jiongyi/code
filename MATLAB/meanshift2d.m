function meanShiftIm = meanshift2d(rawIm, sigma, kernelRad, threshold)
% Check if double.
if ~strcmp(class(rawIm), 'double')
  rawIm = im2double(rawIm);
end

% Check if argument values have been specified.
if exist('kernelRad', 'var')
    if isempty(kernelRad)
        kernelRad = 3;
        disp('Setting kernel radius to 3 pixels');
    elseif ~exist('kernelRad', 'var')
        kernelRad = 3;
        disp('Setting kernel radius to 3 pixels');
    end
end

if exist('sigma', 'var')
    if isempty(sigma)
        sigma = mean(mean(stdfilt(rawIm, true(2 * kernelRad + 1))));
        disp(['Setting bandwidth to average local standard deviation: ', ...
            num2str(sigma, '%.1e')]);
    elseif ~exist('sigma', 'var')
        sigma = mean(mean(stdfilt(rawIm, true(2 * kernelRad + 1))));
        disp(['Setting bandwidth to average local standard deviation: ', ...
            num2str(sigma, '%.1e')]);
    end
end

if exist('threshold', 'var')
    if isempty(threshold)
        threshold = 1e-3;
        disp('Setting threshold to 1e-3');
    elseif ~exist('threshold', 'var')
        threshold = 1e-3;
        disp('Setting threshold to 1e-3');
    end
end

% Initialize variables for while loop.
[noRows, noCols] = size(rawIm);
currIm = rawIm;
currPadIm = padarray(currIm, [noRows, noCols],'symmetric');
nextIm = zeros(noRows, noCols);

done = false;
iterationNo = 0;
maxNoIterations = 100;
meanShiftIm = zeros(noRows, noCols);
while ~done && (iterationNo <= maxNoIterations)
    iterationNo = iterationNo + 1;
    for i = 1 : noRows
        for j = 1 : noCols
            neighIm = currPadIm((noRows + i - kernelRad) : ...
                (noRows + i + kernelRad), (noCols + j - kernelRad) : ...
                (noCols + j + kernelRad));
            sqDiffIm = (neighIm - ...
                neighIm(kernelRad + 1, kernelRad + 1)).^2;
            weightIm = exp(-0.5 * sqDiffIm / (sigma^2));
            weightSum = sum(weightIm(:));
            nextIm(i, j) = sum(weightIm(:) .* neighIm(:)) / weightSum;
        end
    end
    gap = mean(abs(nextIm(:) - currIm(:)));
    disp(['Gap = ', num2str(gap, '%.1e'), ' at iteration #', ...
        num2str(iterationNo)]);
    done = gap <= threshold;
    if done
        meanShiftIm = nextIm;
    else
        currIm = nextIm;
        currPadIm = padarray(currIm, [noRows, noCols],'symmetric');
    end
end
figure('color', 'white');
imshow(meanShiftIm, []);
colormap summer;
colorbar;

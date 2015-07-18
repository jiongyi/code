function plotlinks(nucleusStack, Tracks)
nFrames = size(nucleusStack, 3);
nTracks = numel(Tracks);
F(nFrames - 1) = struct('cdata',[],'colormap',[]);
colorMat = jet(nTracks);
for iFrame = 1 : nFrames
    imshow(nucleusStack(:, :, iFrame), []);
    hold on;
    for iTrack = 1 : nTracks
        idxLast = min(iFrame, size(Tracks(iTrack).centroidCol, 1));
        plot(Tracks(iTrack).centroidCol(1 : idxLast, 1)', ...
            Tracks(iTrack).centroidCol(1 : idxLast, 2)', ...
            'color', colorMat(iTrack, :), 'linewidth', 2);
    end
    hold off;
    F(iFrame) = getframe;
end
close gcf;
implay(F);
end
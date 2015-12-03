function mat2movie(Contact, movieNameStr)

noFrames = length(Contact);
videoObj = VideoWriter(movieNameStr);
videoObj.FrameRate = 7;
open(videoObj);
figure;
for i = 1 : noFrames
    imshow(imcomplement(Contact(i).flatIm));
%     ellipseonbw(Contact(i).bwIm);
    longaxison(Contact(i).bwIm);
    writeVideo(videoObj, getframe(gca));
end
close(videoObj);
end

function ellipseonbw(bw)
s = regionprops(bw, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

hold on
phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

for k = 1:length(s)
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    plot(x,y,'r','LineWidth',2);
end
hold off
end

function longaxison(bw)
s = regionprops(bw, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');
hold on
theta = abs(vertcat(s(:).Orientation) * pi / 180);
xyMat = vertcat(s(:).Centroid);
aMat = vertcat(s(:).MajorAxisLength) / 2;
quiver(xyMat(:, 1), xyMat(:, 2), ...
    aMat .* cos(theta), aMat .* sin(theta), 0);
hold off
end
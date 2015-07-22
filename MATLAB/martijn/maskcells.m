function [Contact, Nucleus] = maskcells(contactIm, nucleusIm, ...
    contactWidth, nucleusWidth)
% Initialize structures.
Contact.rawIm = contactIm;
Nucleus.rawIm = nucleusIm;

% Normalize and equalize histograms.
Contact.normIm = mat2gray(im2double(Contact.rawIm));
Contact.eqIm = adapthisteq(Contact.normIm);

Nucleus.normIm = mat2gray(im2double(Nucleus.rawIm));
Nucleus.eqIm = adapthisteq(Nucleus.normIm);

% Difference-of-gaussian filter.
Contact.sigma1 = 2;
Contact.sigma2 = Contact.sigma1 + contactWidth;
Contact.dogIm = dogfilter(Contact.eqIm, Contact.sigma1, Contact.sigma2);

Nucleus.sigma1 = 2;
Nucleus.sigma2 = Nucleus.sigma1 + nucleusWidth;
Nucleus.dogIm = dogfilter(Nucleus.eqIm, Nucleus.sigma1, Nucleus.sigma2);

% Segment nuclei.
Nucleus.bwIm = im2bw(Nucleus.dogIm, graythresh(Nucleus.dogIm));

% Impose minima.
Contact.minIm = imimposemin(Contact.dogIm, ...
    imerode(Nucleus.bwIm, strel('square', 3)));

% Watershed.
Contact.waterIm = watershed(Contact.minIm);
Contact.bwIm = imclearborder(Contact.waterIm > 1);

% Display.
figure;
imshowpair(Contact.minIm, ...
    label2rgb(Contact.waterIm, 'jet', 'w', 'shuffle'), 'montage');
end
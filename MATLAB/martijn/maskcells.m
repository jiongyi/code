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
Contact.dogIm = dogfilter(Contact.eqIm, contactWidth);
Nucleus.dogIm = dogfilter(Nucleus.eqIm, nucleusWidth);

% Open-close images.
Contact.ocIm = mat2gray(imopenclose(Contact.dogIm, contactWidth));
Nucleus.ocIm = mat2gray(imopenclose(Nucleus.dogIm, nucleusWidth));

% Segment nuclei.
Nucleus.bwIm = im2bw(Nucleus.ocIm, graythresh(Nucleus.ocIm));

% Impose minima.
Contact.minIm = imimposemin(Contact.ocIm, ...
    imerode(Nucleus.bwIm, strel('square', 3)));

% Watershed.
Contact.waterIm = watershed(Contact.minIm);
Contact.bwIm = imclearborder(Contact.waterIm > 1);

% Make fused image.
Contact.outIm = cat(3, zeros(size(Contact.bwIm)), bwperim(Contact.bwIm), ...
    zeros(size(Contact.bwIm)));
Contact.fusedIm = imfuse(Contact.ocIm, Contact.outIm, 'blend');
end
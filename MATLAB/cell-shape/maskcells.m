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

% Flatten images.
Contact.flatIm = mat2gray(dogfilter(Contact.eqIm, contactWidth));
Nucleus.flatIm = mat2gray(dogfilter(Nucleus.eqIm, nucleusWidth));

% Open-close images.
Contact.ocIm = mat2gray(imopenclose(Contact.flatIm, contactWidth));
Nucleus.ocIm = mat2gray(imopenclose(Nucleus.flatIm, nucleusWidth));

% Segment nuclei.
Nucleus.bwIm = im2bw(Nucleus.ocIm, graythresh(Nucleus.ocIm));

% Impose minima.
Contact.minIm = imimposemin(Contact.ocIm, ...
    imerode(Nucleus.bwIm, strel('square', 3)));

% Watershed.
Contact.waterIm = watershed(Contact.minIm);
Contact.bwIm = imclearborder(Contact.waterIm > 1);

% Make fused image.
Contact.fusedIm = imoverlay(Contact.minIm, ...
    imdilate(bwperim(Contact.waterIm == 0), strel('square', 3)), ...
    [0, 1, 0]);
end
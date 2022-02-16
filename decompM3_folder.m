function decompM3_folder(signaldir,M,normalizationoption,varargin)
% FUNCTION: 
%   Using linear unmixing, derive the protein/lipid/water fractions from
%   background subtracted data
%   Decomposition tif output maps concentration [0 1] (as mass or volume
%   fraction depending on the decomposition matrix M) to [0 2^13] 
% INPUT CONVENTION & SPECIFICATION
%   (1) signaldir
%       holds the path (ending with filesep) of the 
%       directory with background subtraction processed files.
%       this version assumes that the files have been digitized to uint16.
%       
%   (2) M
%       holds the decomposition struct. For details of this struct
%       specificatio, see decomp_data_bg.m
%   (3) normalizationoption
%       NoRI normalization is ON or OFF. OFF output is same as conventional 
%       spectral decomposition.
%       
% OUTPUT CONVENTION & SPECIFICATION
%   matlab output saves the concentration as mass(or volume) fraction
%   depending on how M was originally generated. volume fraction is the usual
%   practice. The resulting double value is cast into uint32 by the
%   CONVERSION_FACTOR.
% HISTORY
%   2015-05-16 updated for efficiency and readability.
%   2019-06-19 image description is copied as well.
%   2022-02-15 edited for readability.

DECOMP_CONVERSION_FACTOR = 2^13; %(2^13 = 8192)

% this to preserve backward compatibility
p = inputParser;
addParameter(p, 'verbose', true, @islogical);


if isempty(normalizationoption)
    normalizationoption='on';
end

outputunit = 'vv';
if nargin < 4
    strw = 'channel_water';strp='channel_protein';strl='channel_lipid';
    decompdirnamesuffix = [];

else
     suffixstring=varargin{1};
     strw=suffixstring{1}; strp=suffixstring{2}; strl=suffixstring{3};
     if nargin > 4
         decompdirnamesuffix = varargin{2};
     else
         decompdirnamesuffix = [];
     end

     % For backward compatibility
     if nargin > 5
         parse(p, varargin{3:end});
     else
         parse(p, 'verbose', true);
     end
     
end

decompdir = [signaldir '..' filesep 'decomp' decompdirnamesuffix filesep];

if ~exist(decompdir, 'dir')
    mkdir(decompdir); 
end


imagelist = dir(strcat(signaldir,'*',strw,'.tif'));
for img_idx=1:length(imagelist)
    % Input file names
    imgWfn = imagelist(img_idx).name;

    prefix = imgWfn(1:strfind(imgWfn, strw)-1);

    imgLfn = [prefix strl '.tif'];
    imgPfn = [prefix strp '.tif'];
    imgCfn = [prefix '.tif'];
    
    outputWfn = [decompdir imgWfn];
    outputPfn = [decompdir imgPfn];
    outputLfn = [decompdir imgLfn];
    outputCfn = [decompdir imgCfn];
    
    if exist(outputWfn, 'file') && exist(outputPfn, 'file') && exist(outputLfn, 'file')
        if p.Results.verbose
            fprintf('image %s (water channel with associated protein/lipid) already exists...\n', imgWfn);
        end
    else
        fprintf('image %s (water channel with associated protein/lipid) being processed...\n', imgWfn);

        info = imfinfo(strcat(signaldir,filesep,imgLfn));
        num_pages = numel(info); % assumes multiplage info
        
        if exist([signaldir imgLfn], 'file') && exist([signaldir imgPfn], 'file')
            
            imgL = fasttifread([signaldir imgLfn],0); 
            imgP = fasttifread([signaldir imgPfn],0);
            imgW = fasttifread([signaldir imgWfn],0);
            
            [decomp_l, decomp_p, decomp_w] = decomp1(M,imgL,imgP,imgW,normalizationoption,outputunit);

            writeTIFF(uint16(DECOMP_CONVERSION_FACTOR*decomp_w), outputWfn, 'w');
            writeTIFF(uint16(DECOMP_CONVERSION_FACTOR*decomp_p), outputPfn, 'w');
            writeTIFF(uint16(DECOMP_CONVERSION_FACTOR*decomp_l), outputLfn, 'w');          
            
        else
            fprintf(' -- ERROR: either protein or lipid signal missing for image %s...\n', imgWfn);
        end
    end
end
% save the decomposition matrix for reference
save(strcat(decompdir,'M.mat'),'M');

% Write log
fileID = fopen(strcat(decompdir,'note.txt'),'w');
str1=sprintf('Normalization is ''%s''.\n',normalizationoption);
str2=sprintf('Output format is ''%s''.\n',outputunit);
str3=sprintf('Tiff image conversion factor is %d.\n', DECOMP_CONVERSION_FACTOR);
fprintf(fileID,[str1 str2 str3]);
fclose(fileID);

disp('Decomposition completed...');
end
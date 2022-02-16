function writeTIFF(data, filename,overwriteflag, varargin)
% FUNCTION: 
%   write a 2D/3D-image using TIFF library of MATLAB.
% INPUT CONVENTION & SPECIFICATION
%   (1) data
%       2D or 3D-matrix holding monochrome channel info in 16-bit
%   (2) filename
%       target full path of the file to write.
%   (3) overwriteflag
%       'w' for overwrite, 'a' for append. For our purposes, 'w' is enough.
%   (4) PageName (optional) : meta information
%   (5) ImageDescription (optional) : meta information
%
% OUTPUT CONVENTION & SPECIFICATION
%   A non-compressed TIFF file readable by ImageJ
% HISTORY
%   2015-05-15 updated from writeTIFF which wrote in single floating
%   dimension. We found that this was not necessary. Modified so that Tiff
%   library is utilized at full extent (multi-page writing faster)
%   2015-06-05 updated to detect the input data type. If the input is integer
%   the output is saved as uint16. If floating point variable, the output
%   is saved as single.
% SEE ALSO
% * http://linuxtoosx.blogspot.com/2012/09/writing-floating-point-multi-channel.html
% * http://stackoverflow.com/questions/23163048/matlab-write-multipage-tiff-exponentially-slow
% * http://www.mathworks.com/help/matlab/import_export/exporting-to-images.html#br_c_iz-1

    if overwriteflag == 'w'
       t = Tiff(filename, 'w');
    elseif overwriteflag == 'a'
       t = Tiff(filename, 'a');
    end
    
    meta_str = '';
    if (nargin > 3)
        meta_str = varargin{1}; % PageName
    end
    
    meta_str2 = '';
    if (nargin > 4)
        meta_str2 = varargin{2}; % ImageDescription
    end
      
    if isinteger(data)
        bitdepth = 16;
    elseif isfloat(data)
        data=single(data);
        bitdepth = 32;
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    end
    
    tagstruct.ImageLength = size(data, 1);
    tagstruct.ImageWidth = size(data, 2);
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack; 
    tagstruct.BitsPerSample =  bitdepth;                        
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    if ~isempty(meta_str)
        tagstruct.PageName = meta_str;
    end
    if ~isempty(meta_str2)
        tagstruct.ImageDescription = meta_str2;
    end
    t.setTag(tagstruct);
   

    if ndims(data) < 3 
        t.write(data(:,:));
    else % assume 3-D.
        t.write(data(:,:,1));
        numframes = size(data,3);
        for i=2:numframes
            t.writeDirectory();
            t.setTag(tagstruct);
            t.write(data(:,:,i));
        end
    end
    t.close();
end
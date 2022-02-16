function [FinalImage NumberImages]=fasttifread(FileTif,varargin)
tic;
warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
warning('off','MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning');

InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
if InfoImage(1).BitDepth == 16
    FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
elseif InfoImage(1).BitDepth == 32
    FinalImage=zeros(nImage,mImage,NumberImages,'single');
else 
    FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
end

if isempty(varargin)
    verbose=0;
else
    verbose=1;
end
[pathstr, name, ext] = fileparts(FileTif);

TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
   if verbose==1;
        if i==1
            fprintf('');
        else
            fprintf(repmat('\b',1,length(verbosestr)));
        end
        verbosestr = sprintf('    Read page %g of %g from %s%s',i,NumberImages,name,ext);
        fprintf('%s',verbosestr);
        if i==NumberImages
            fprintf('\n')
        end
    end
end
TifLink.close();
warning('on','MATLAB:imagesci:tiffmexutils:libtiffWarning');
warning('on','MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning');


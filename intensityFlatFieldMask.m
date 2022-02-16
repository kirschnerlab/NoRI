function IMmask=intensityFlatFieldMask(IM,varargin)
% Usage:
% IMmask=intensityFlatFieldMask(IM,numrow,numcol)
switch nargin
    case 1
        numrow=512;
        numcol=512;
        zoom=1;
    case 2
        numrow=varargin{1};
        numcol=numrow;
        zoom=1;
    case 3
        numrow=varargin{1};
        numcol=varargin{2};
        zoom=1;
    case 4
        numrow=varargin{1};
        numcol=varargin{2};
        zoom=varargin{3}; % Applies when zoom factor of sample image is different from cal
        
end

% apply zoom factor
[numrow1 numcol1 numz1]=size(IM);
IM=IM(0.5*numrow1+(1-0.5*numrow1/zoom:0.5*numrow1/zoom),0.5*numcol1+(1-0.5*numcol1/zoom:0.5*numcol1/zoom));
% make binning mask
step = 4;
mask = zeros(size(IM));
cc = 1;
for  c = 1:step:size(IM,1)-step+1
    for r = 1:step:size(IM,2)-step+1
        mask(c:c+step-1,r:r+step-1)=cc;
        cc = cc+1;
    end
    
end
% imagesc(mask)
[x,y,z]=parxyz(mask, IM);
x=double(x);
y=double(y);
z=double(z);
warning('off','curvefit:fit:equationBadlyConditioned');
f1 = fit([x' y'],z','poly34');
ix = size(IM,2);
iy = size(IM,1);
y1 = linspace(1,iy,numrow);
Y = repmat(y1, [numcol, 1]);
x1 = linspace(1,ix,numcol);
X = repmat(x1, [1, numrow]);
X = X(:);
Y = Y(:);
f = feval(f1,[X,Y]);
Bg = reshape(f,numrow,numcol);
Bg = Bg';

IMmask=Bg/max(Bg(:));

    function [x,y,z]=parxyz(mask,Phase)
        stat = regionprops(mask, Phase, 'Centroid', 'MeanIntensity');
        count = 0;
        for iter = 1:length(stat)
            if ~isnan(stat(iter).MeanIntensity)
                count = count+1;
                x(count) = stat(iter).Centroid(1);
                y(count) = stat(iter).Centroid(2);
                z(count) = stat(iter).MeanIntensity;
            end
        end
    end
end
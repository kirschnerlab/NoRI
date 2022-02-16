function [data, name] = readcalstackmax2(targetfolder,varargin)
% Returns the xy-average value of the image from the maximum value z plane of the image
% stacks for protein sample, lipid sample and water sample.
% Return the xy-average value of the image from the middle z plane of the
% image stacks of d-methanol.
% This version uses the z plane position of the maximum for each channel.
% [data name] = readcalstack(targetfolder,{'channel names'},{'sample names'})
% It is assumed that the file name is in the format of 
%               'sample name'_'channel name'.tif
% Example
% channelnames = {'channel_lipid','channel_protein','channel_water'}
% samplenamestr = {'sample_BSA30','sample_dmethanol','sample_DOPC15','sample_water'}
% [caldata name] = readcalstackmax(targetfolder,channelnames,samplenamestr)
% optional page flag for choosing the page number in multi page tiff is
% removed from the previous version.


if isempty(varargin);
    channelnames={'channel_lipid','channel_protein','channel_water'};
    channelnumber=3;
    samplenamestr={'sample_BSA','sample_dmethanol','sample_DOPC','sample_water'}; 
    samplenumber =4;
else
    channelnumber = length(varargin{1});
    channelnames =varargin{1};
    samplenumber = length(varargin{2});
    samplenamestr=varargin{2};
end

if targetfolder(end)~=filesep
    targetfolder=strcat(targetfolder,filesep);
end
%%
data=[];
name=[];
indmidlist=[];
meanval_all=[];
diffmeanval_all=[];
for iter=1:samplenumber
    repeats=[];
    for iterch=1:channelnumber
        dirout = dir(strcat(targetfolder,samplenamestr{iter},'*',channelnames{iterch},'*.tif'));
        repeats(iterch)=length(dirout);
    end
    for iter2 =1:1
        
        for iterch=1:channelnumber
            dirout = dir(strcat(targetfolder,samplenamestr{iter},'*',channelnames{iterch},'*.tif'));
            imgfn = dirout(iter2).name;
            img=double(fasttifread(strcat(targetfolder,imgfn)));
            disp(['Reading ' imgfn]);
            
            
            
            [numrow numcol numz]=size(img);
            rangerow = round(numrow*0.25):round(numrow*0.75);
            rangecol = round(numcol*0.25):round(numcol*0.75);
            rangez = 1:numz;
            meanval=squeeze(mean(mean(img(rangerow,rangecol,rangez),1),2));
            [M0 indmeanmax] = max(meanval);
            
            meanval_all(iterch,iter,:)=meanval;
            indmeanmax_all(iterch,iter)=indmeanmax;
            
            N=length(meanval);
            
            diffmeanval = diff(meanval);
            diffmeanval_all(iterch,iter,:)=diffmeanval;
            [M1 indmax]=max(diffmeanval(1:round(N/2))); % Assumes that the the
            % entrance to the sample happened in the first half of z stack
            [M2 indmin]=min(diffmeanval((round(N/2):end)));
            indmin = indmin + round(N/2)-1;
            indmid = round(0.5*(indmax+indmin));
            
            
            % Exception handling for weak signal of
            % sample_lipid at channel_water
            if (iter ==1 & iterch == 3) 
                if abs(indmid - mean(indmidlist(1:2,iter,1))) > 2
                    indmid = round(mean(indmidlist(1:2,iter,1)));
                end
            end
            
            
            val = meanval(indmid);
            indmidlist(iterch,iter,1)=indmid;
            indmidlist(iterch,iter,2)=indmax;
            indmidlist(iterch,iter,3)=indmin;
            
            % Exception handling for weak signal of methanol
            if (iter ==4 & iterch == 3)
                if abs(indmidlist(1,iter,1) - mean(indmidlist(2:3,iter,1))) > 2
                    indmidlist(1,iter,1) = round(mean(indmidlist(2:3,iter,1)));
                    data(1,4)= meanval_all(1,iter,indmidlist(1,iter,1));
                end
            end
            
         

          
            if isempty(data);
                data(iterch,1) = val;
                name{iterch,1} = imgfn;
            else
                if iterch ==1;
                    data(iterch,end+1) = val;
                    name{iterch,end+1} = imgfn;
                else
                    data(iterch,end) = val;
                    name{iterch,end} = imgfn;
                end
            end
        end
    end
end    
indmeanmax_final = indmeanmax_all;
indmeanmax_final = indmidlist(:,:,1);
iter = 1; % BSA sample
    indmeanmax_final(1,iter) = indmeanmax_all(1,iter);
    indmeanmax_final(2,iter) = indmeanmax_all(2,iter);
    indmeanmax_final(3,iter) = indmeanmax_all(3,iter);
    data(1,iter) = meanval_all(1,iter,indmeanmax_final(1,iter));
    data(2,iter) = meanval_all(2,iter,indmeanmax_final(2,iter));
    data(3,iter) = meanval_all(3,iter,indmeanmax_final(3,iter));
iter = 3; % DOPC sample
    indmeanmax_final(1,iter) = indmeanmax_all(1,iter);
    indmeanmax_final(2,iter) = indmeanmax_all(2,iter);
    indmeanmax_final(3,iter) = indmeanmax_all(3,iter);
    data(1,iter) = meanval_all(1,iter,indmeanmax_final(1,iter));
    data(2,iter) = meanval_all(2,iter,indmeanmax_final(2,iter));
    data(3,iter) = meanval_all(3,iter,indmeanmax_final(3,iter));

iter = 4; % water sample
    indmeanmax_final(1,iter) = indmeanmax_all(3,iter);
    indmeanmax_final(2,iter) = indmeanmax_all(3,iter);
    indmeanmax_final(3,iter) = indmeanmax_all(3,iter);
    data(1,iter) = meanval_all(1,iter,indmeanmax_final(1,iter));
    data(2,iter) = meanval_all(2,iter,indmeanmax_final(2,iter));
    data(3,iter) = meanval_all(3,iter,indmeanmax_final(3,iter));


% Plot z profile of mean value
colorstr='krbcmgy';
figure(110)
for iter = 1: samplenumber
    for iterch=1:channelnumber
        meanval = squeeze(meanval_all(iterch,iter,:));
        diffmeanval=squeeze(diffmeanval_all(iterch,iter,:));
        indmid = indmidlist(iterch,iter,1);
        indmax = indmidlist(iterch,iter,2);
        indmin = indmidlist(iterch,iter,3);
        indmeanmax = indmeanmax_final(iterch,iter);
        maxval = data(iterch,iter);
        M1=diffmeanval(indmax);
        M2=diffmeanval(indmin);
        subplot(1,samplenumber,iter)
        plot(meanval,'Color',colorstr(iterch),'linestyle','-')
        hold on
        plot(indmeanmax,maxval,'Color',colorstr(iterch),'marker','*')
        grid on
        xlim([0 N])
        ylim([0 3000])
        title(strrep(samplenamestr{iter},'_',' '))
    end
end 


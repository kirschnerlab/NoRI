%% Add Matlab functions path

rootpath =   'Z:\NoRI\Seungeun\20220215 code package\';
calpath  =   'Z:\NoRI\Seungeun\20220215 code package\cal\';
bgfilepath=[ calpath 'signalX\bg.tif'];

%%  Detect sample directories
subdirinfo = dir(rootpath);
tf = ismember( {subdirinfo.name}, {'.', '..','cal'});
subdirinfo(tf) = [];
subdirtf = [subdirinfo.isdir];
subdirinfo(~subdirtf) = [];

%%  BACKGROUND SUBTRACTION

disp([char(datetime) ' ## Background subtraction...']);

[IMbg NumberImages]=fasttifread(bgfilepath);
bglevel=mean(IMbg(:));

for itersubfolders = 1:length(subdirinfo)
    raw_data_files = dir([rootpath subdirinfo(itersubfolders).name filesep 'signalX\*.tif']);
    
    bg_output_folder  = [rootpath subdirinfo(itersubfolders).name filesep 'signal_bg'];
    if ~exist( bg_output_folder )
        mkdir( bg_output_folder );
    end
    
    for iter=1:length( raw_data_files )
        ipath = [ raw_data_files(iter).folder filesep raw_data_files(iter).name ];
        fname = raw_data_files(iter).name;
        oname = [bg_output_folder filesep fname];
        if ~exist(oname, 'file') && ~contains(fname, '_channel_confocal.tif')
            metainfo = imfinfo(ipath); 
            [IM NumberImages]=fasttifread(ipath,1);
            IMout=single(IM)-bglevel;  
            if isfield(metainfo(1), 'ImageDescription')
                writeTIFF(IMout, oname, 'w', '', metainfo(1).ImageDescription);
            else
                writeTIFF(IMout, oname, 'w');
            end
        else
            if ~contains(fname, '_channel_confocal.tif')
                disp([fname ' already bg subtracted according to the name...']);
            end
        end
    end
end

% Write log
fileID = fopen(strcat(bg_output_folder,'bgsubtraction_info.txt'),'w');
str1=sprintf('background level is ''%s''.\n',bglevel);
fprintf(fileID,[str1]);
fclose(fileID);

%%  FLATFIELD CORRECTION 
disp([char(datetime) ' ## Loading flat field correction masks...']);


raw_data_files = dir([calpath 'signalX\*.tif']);
    
bg_output_folder  = [calpath 'signal_bg'];
if ~exist( bg_output_folder, 'dir' )
    mkdir( bg_output_folder );
end
 
if ~exist( [bg_output_folder filesep 'maxz.mat'] )
    calculate_z_flag = 1;
else
    calculate_z_flag = 0;
end

for iter=1:length( raw_data_files )
    ipath = [ raw_data_files(iter).folder filesep raw_data_files(iter).name ];
    fname = raw_data_files(iter).name;
    opath = [bg_output_folder filesep fname];
    if ~exist(opath, 'file')
        [IM NumberImages]=fasttifread(ipath,1);
        IMout=single(IM)-bglevel;  % the actual subtraction
        writeTIFF(IMout, opath, 'w');
        
        if (calculate_z_flag)
            if strcmpi(fname, 'sample_DOPC35backup_channel_lipidUP.tif')
                [dummy,lipid_index]=max(squeeze(mean(mean(IMout,1),2)));
            end

            if strcmpi(fname, 'sample_BSA30new_channel_proteinUP.tif')
                [dummy,protein_index]=max(squeeze(mean(mean(IMout,1),2)));
            end

             if strcmpi(fname, 'sample_BSA30new_channel_waterHP.tif')
                [dummy,water_index]=max(squeeze(mean(mean(IMout,1),2)));
             end
        end
    elseif (calculate_z_flag)
            if strcmpi(fname, 'sample_DOPC35backup_channel_lipidUP.tif')
                [IMout NumberImages]=fasttifread(opath,1);
                [dummy,lipid_index]=max(squeeze(mean(mean(IMout,1),2)));
            end

            if strcmpi(fname, 'sample_BSA30new_channel_proteinUP.tif')
                [IMout NumberImages]=fasttifread(opath,1);
                [dummy,protein_index]=max(squeeze(mean(mean(IMout,1),2)));
            end

            if strcmpi(fname, 'sample_BSA30new_channel_waterUP.tif')
                [IMout NumberImages]=fasttifread(opath,1);
                [dummy,water_index]=max(squeeze(mean(mean(IMout,1),2)));
            end        
    end
end

if (calculate_z_flag)
    save( [bg_output_folder filesep 'maxz.mat'], 'lipid_index', 'protein_index', 'water_index' );
else
    load( [bg_output_folder filesep 'maxz.mat'] );
end


% Make Flat field correction Mask
% Need to define for EACH channel, the maximum of the z.

n_lipid   = imread( [calpath 'signal_bg' filesep 'sample_DOPC35backup_channel_lipidUP.tif'], lipid_index);
n_protein = imread( [calpath 'signal_bg' filesep 'sample_BSA30new_channel_proteinUP.tif'], protein_index);
n_water   = imread( [calpath 'signal_bg' filesep 'sample_BSA30new_channel_waterHP.tif'] ,water_index);


disp([char(datetime) ' ## Flatfield correction start.']);

IMmask_channel_protein_1024=intensityFlatFieldMask(n_protein,1024,1024);
IMmask_channel_lipid_1024=intensityFlatFieldMask(n_lipid,1024,1024);
IMmask_channel_water_1024=intensityFlatFieldMask(n_water,1024,1024);
IMmask_channel_protein_800=intensityFlatFieldMask(n_protein,800,800);
IMmask_channel_lipid_800=intensityFlatFieldMask(n_lipid,800,800);
IMmask_channel_water_800=intensityFlatFieldMask(n_water,800,800);
IMmask_channel_protein_512=intensityFlatFieldMask(n_protein,512,512);
IMmask_channel_lipid_512=intensityFlatFieldMask(n_lipid,512,512);
IMmask_channel_water_512=intensityFlatFieldMask(n_water,512,512);
IMmask_channel_protein_640=intensityFlatFieldMask(n_protein,640,640);
IMmask_channel_lipid_640=intensityFlatFieldMask(n_lipid,640,640);
IMmask_channel_water_640=intensityFlatFieldMask(n_water,640,640);
IMmask_channel_protein_256=intensityFlatFieldMask(n_protein,256,256);
IMmask_channel_lipid_256=intensityFlatFieldMask(n_lipid,256,256);
IMmask_channel_water_256=intensityFlatFieldMask(n_water,256,256);

for itersubfolders = 1:length(subdirinfo)
    subdirpath = [rootpath subdirinfo(itersubfolders).name filesep 'signal_bg' filesep '*.tif'];
    dirinfo = dir(subdirpath);
    tf = ismember( {dirinfo.name}, {'.', '..'});
    dirinfo(tf) = [];
    
    disp(['Traversing to directory: ' subdirinfo(itersubfolders).name]);
    
    for iter = 1:length(dirinfo)
        target = dirinfo(iter);
        if target.isdir == 0 && strcmpi(target.folder(end-8:end),'signal_bg') ...
                && strcmpi(target.name(end-2:end),'tif')
            savefolderpath = [target.folder '_ffc2' filesep];  
            if ~exist(savefolderpath)
                mkdir(savefolderpath)
            end
            savefilename = [savefolderpath target.name];
            
            if ~exist(savefilename)
                metainfo = imfinfo([target.folder filesep target.name]);
                [IM NumberImages]=fasttifread([target.folder filesep target.name],1);
                IM = single(IM);
                
                if size(IM,1)==1024 && size(IM,2)==1024
                    IMmask_channel_protein=IMmask_channel_protein_1024;
                    IMmask_channel_lipid=IMmask_channel_lipid_1024;
                    IMmask_channel_water=IMmask_channel_water_1024;
                elseif size(IM,1)==800 && size(IM,2)==800
                    IMmask_channel_protein=IMmask_channel_protein_800;
                    IMmask_channel_lipid=IMmask_channel_lipid_800;
                    IMmask_channel_water=IMmask_channel_water_800;
                elseif size(IM,1)==512 && size(IM,2)==512
                    IMmask_channel_protein=IMmask_channel_protein_512;
                    IMmask_channel_lipid=IMmask_channel_lipid_512;
                    IMmask_channel_water=IMmask_channel_water_512;
                elseif size(IM,1)==640 && size(IM,2)==640
                    IMmask_channel_protein=IMmask_channel_protein_640;
                    IMmask_channel_lipid=IMmask_channel_lipid_640;
                    IMmask_channel_water=IMmask_channel_water_640;                    
                end
                
                if ~isempty(strfind(target.name,'channel_protein')) && size(IM,1)==size(IM,2)
                    IMffc = IM./repmat(IMmask_channel_protein,1,1,size(IM,3));
                elseif ~isempty(strfind(target.name,'channel_lipid')) && size(IM,1)==size(IM,2)
                    IMffc = IM./repmat(IMmask_channel_lipid,1,1,size(IM,3));
                elseif ~isempty(strfind(target.name,'channel_water')) && size(IM,1)==size(IM,2)
                    IMffc = IM./repmat(IMmask_channel_water,1,1,size(IM,3));
                else
                    IMffc = IM;
                end
                
                if isfield(metainfo(1), 'ImageDescription') 
                    writeTIFF(IMffc, savefilename,'w','', metainfo(1).ImageDescription); 
                else
                    writeTIFF(IMffc, savefilename,'w'); 
                end
            end
        end
    end
end

%%  LOAD DECOMPOSITION MATRIX
disp([char(datetime) ' ## Loading decomposition matrix...']);
if ~exist([rootpath filesep 'cal' filesep 'M_bgffc2.mat'], 'file')
    M = getdecompmatrix([rootpath filesep 'cal' filesep ],'decomp_data_bg');
    save([rootpath filesep 'cal' filesep 'M_bgffc2.mat'],'M');
else
    load([rootpath filesep 'cal' filesep  'M_bgffc2.mat']);
end

%%  DECOMPOSITION SAMPLE DATA

for itersubfolders = 1:length(subdirinfo)
    channelnamesstr = {'channel_waterHP','channel_proteinUP','channel_lipidUP'};
    signaldir = [rootpath subdirinfo(itersubfolders).name filesep 'signal_bg_ffc2' filesep];
    decompM3_folder(signaldir,M,'on',channelnamesstr,'_bg_ffc2');
    
end

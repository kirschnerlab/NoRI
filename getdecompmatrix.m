function caldatastruct = getdecompmatrix(pathname, varargin)
% _caldata_ format:
% columns 1 = BSA sample, column 2 = lipid sample, column 3 = water sample
% row 1 = lipid channel Raman signal, row 2 = protein channel Raman signal,
% row 3 = H2O channel Raman signal
% Raman signal is normalized to water channel signal of the water sample
% _Conc_ format:
% column 1 = BSA sample, column 2 = lipid sample, column 3 = water sample
% row 1 = lipid concentrations, row 2 = protein concentrations, row 3 = H2O
% concentrations
% _varargin_ can specify the file name of  decomposition data.
% For example: getdecompdata(datapath,'decomp_data_test')
whereami = pwd;
[pathstr, name, ext] = fileparts([pathname filesep]);
cd(pathstr)
if isempty(varargin)
    filename = 'decomp_data';
else
    filename = varargin{1};
end
[ caldata name Conc Density caldataraw calpath] = eval(filename);

M=Conc/caldata;

M=M(1:3,:); % 4th row is for methanol-D and is ignored.
caldatastruct.name=name;
caldatastruct.concentration = Conc;
caldatastruct.density = Density;
caldatastruct.SRSsignal = caldata;
caldatastruct.M = M;
caldatastruct.source = pathname;
caldatastruct.SRSsignal_Rawdata=caldataraw;
caldatastruct.calpath=calpath;
cd(whereami)
end
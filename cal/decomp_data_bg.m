function [caldatafinal name Conc Density varargout]=decomp_data(varargin)
%% Concentrations

Density=eye(3,3);
Density(2,2)=1.364256;
Density(1,1) = 1.010101; % g/ml,


% Protein sample: 30% BSA in 150 mM PB (w/w) with 0.05% sodium azide
Solute_gram = 1.7708;
Solvent_gram = 5.3744 - Solute_gram;
Solute_density = 1.364256; % g/ml,
Solvent_density = 1.0116; % g/ml,
Solute_volumefraction1 = Solute_gram/Solute_density/(Solute_gram/Solute_density+Solvent_gram/Solvent_density);
Solute_volumefraction = Solute_volumefraction1 / 1;
Conc4(:,1) = [0 Solute_volumefraction  1-Solute_volumefraction 0]';

% Methanol
Conc4(:,2) = [0 0  0 1]';


% Lipid sample: 35% DOPC in D-Methanol standard 
Solute_gram = 1.0219 ;
Solvent_gram = 2.7346-Solute_gram;
Solute_density = 1.010101; % g/ml,
Solvent_density = 0.888; % g/ml,
Solute_volumefraction = Solute_gram/Solute_density/(Solute_gram/Solute_density+Solvent_gram/Solvent_density);
Conc4(:,3) = [Solute_volumefraction 0 0 1-Solute_volumefraction]';

% Water sample: H2O
Conc4(:,4) = [0 0 1 0];

% Conc in the order of lipid, protein, water, methanol-D4
Density(1,1)=Solute_density;

%% Read signals
calibration_data_path = 'Z:\NoRI\Seungeun\20220215 code package\cal\';
colorstr='krbcmgy';linestylestr={'-','- ','-','-'};
targetfolder1 = [calibration_data_path 'signal_bg_ffc2' filesep];
samplenamestr = {'sample_BSA30new','sample_dmethanol','sample_DOPC35backup','sample_water'};
channelnames = {'channel_lipidUP','channel_proteinUP','channel_waterHP'};

[caldataraw name] = readcalstackmax2(targetfolder1,channelnames,samplenamestr);
[numwavelengths numsamples]=size(caldataraw);
caldatarel2=caldataraw./repmat([caldataraw(3,4)],numwavelengths,numsamples);

if nargout >4
    varargout{1}=caldataraw;
    varargout{2}=calibration_data_path;
end

caldatarelall = caldatarel2;
caldatafinal = mean(caldatarelall,3);
Conc = Conc4;

if ~isempty(varargin)
    fignumber=varargin{1};
    figure(fignumber);hold off;
    for j=1:size(caldatarelall,3)
        for k=1:numsamples;
            plot(caldatarelall(:,k,j),'Color',colorstr(k),'Marker','.','MarkerFaceColor',colorstr(k),'LineStyle',linestylestr{j});
            hold on
        end
    end
    set(gca,'XTick',[1 2 3],'XTickLabel',{'CH2','CH3','H2O'},'XLim',[0.9 3.1])
    legendstr={'protein','methanol','lipid','water'};
    legend(legendstr,'location','best')
end
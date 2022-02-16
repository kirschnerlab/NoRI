function [decomp_l, decomp_p, decomp_w, decomp_m] = decomp1(caldatastruct,data_lch,data_pch,data_wch,normalizationoption,varargin)
%% decomp1 applies decomposition matrix _M_ on Raman signal data set
% consists of lipid channel, protein channel and water channel.
% The output concentration is normalized to make the total of lipid,
% protein and water equals 1, provided that the decomposition matrix and
% output is in the unit of volume fraction.
% _normalizationoption_ flag is either 'on' or 'off and switches the output
% normalization.
% Varargin is an option for choosing output by volume fraction 'vv' or
% 'v/v' in ml/ml by concentration 'wv' or 'w/v' in g/ml

if ~isequal(size(data_lch), size(data_pch), size(data_wch))
    disp('input data dimension mismatch');
    return;
end

data_lch=double(data_lch);
data_pch=double(data_pch);
data_wch=double(data_wch);
data = [data_lch(:)'; data_pch(:)'; data_wch(:)'];
if isstruct(caldatastruct)
    M=caldatastruct.M;
else
    M=caldatastruct;
end
decomp_output = M*data;

if isequal(normalizationoption,'on')
    total = sum(decomp_output,1);
else
    total = 100;
end

if isempty(varargin)
    unitconversion = [1 1 1 1];
elseif strcmpi(varargin{1},'v/v') || strcmpi(varargin{1},'vv')
    unitconversion = [1 1 1 1];
elseif strcmpi(varargin{1},'w/v')  || strcmpi(varargin{1},'wv')
    densityval = caldatastruct.density;
    unitconversion = densityval([1 5 9]);
end

decomp_l = unitconversion(1)*reshape(decomp_output(1,:)./total,size(data_lch));
decomp_p = unitconversion(2)*reshape(decomp_output(2,:)./total,size(data_lch));
decomp_w = unitconversion(3)*reshape(decomp_output(3,:)./total,size(data_lch));
if size(decomp_output,1)==4
    decomp_m = unitconversion(3)*reshape(decomp_output(4,:)./total,size(data_lch));
else
    decomp_m = NaN;
end

end

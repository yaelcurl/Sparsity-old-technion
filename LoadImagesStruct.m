function [ images ] = LoadImagesStruct( db_path,file_pattern,sigma,dicts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
images = dir(fullfile(db_path,file_pattern));
images = rmfield(images,{'isdir','datenum','date'});
image_dir = cellstr(repmat(db_path,length(images),1));
[images.dir] = image_dir{:}; 
% dict = struct('name',cell(1,length(dicts)),'Idenoise',[],'PSNROut',[],'KSVD',...
%     struct('Idenoise',[],'traniedDict',[],'PSNROut',[]));
dict = struct('name',cell(1,length(dicts)),'Idenoise',[],'nz',[],'PSNROut',[],'SSIM',[],'KSVD_Idenoise',[],...
    'KSVD_trainedDict',[],'KSVD_PSNROut',[],'KSVD_SSIM',[]);
dict = orderfields(dict);
% dict = repmat({dict},1,length(sigma));
sig = struct('value',num2cell(sigma'),'use',[],'dict',dict,'Inoise',[],'PSNRIn',[]);
sig = repmat({sig}, 1,length(images));
[images.sigma]=sig{:};
images(length(images)).original = [];
images(length(images)).use = [];
images = orderfields(images);
denoising_dir = fullfile(db_path, 'Denoising');
if ~exist(denoising_dir,'dir')
    mkdir(denoising_dir)
end

end


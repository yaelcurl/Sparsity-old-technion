function [ images ] = DenoisingExperiments( images,image_choise,sigma,params,dicts,dicts_choise,initKSVD )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% images = dir(fullfile(db_path,file_pattern));
% images = rmfield(images,{'isdir','datenum','date'});
% image_dir = cellstr(repmat(db_path,length(images),1));
% [images.dir] = image_dir{:}; 

dicts_use = zeros(length(dicts),1);
dicts_use(dicts_choise) = 1;
dicts_use = num2cell(dicts_use);
[dicts.use] = dicts_use{:};

KSVD_use = zeros(length(dicts),1);
KSVD_use(initKSVD)=1;
KSVD_use = num2cell(KSVD_use);
[dicts.initKSVD] = KSVD_use{:};

image_use = zeros(length(images),1);
image_use(image_choise) = 1;
image_use = num2cell(image_use);
[images.use] = image_use{:};
% dict = struct('name',cell(1,length(dicts)),'Idenoise',[],'PSNROut',[],'KSVD',...
%     struct('Idenoise',[],'traniedDict',[],'PSNROut',[]));
% % dict = repmat({dict},1,length(sigma));
% sig = struct('value',num2cell(sigma'),'use',[],'dict',dict,'Inoise',[],'PSNRIn',[]);
% sig = repmat({sig}, 1,length(images));
% [images.sigma]=sig{:};
% images(length(images)).original = [];

params.maxval = 255;
params.noisemode = 'sigma';    
params.trainnum = 70000;
% params.iternum = 20;
params.memusage = 'high';

for i = image_choise
%     image = load('tmp_image.mat');
%     image = image.image;
    image = DenoiseImage(images(i),params,sigma,dicts);
%     save(fullfile(image.dir,strcat('tmp_image.mat')),'image','-mat');
    images(i) = image;
%     IMin0 = double(imread(fullfile(db_path,images(i).name)));
%     images(i).original = IMin0;
%     [~, name,ext] = fileparts(images(i).name);
%     for s = 1:1:length(sigma)
%         images(i).sigma(s).value = sigma(s);
%         Inoise=IMin0+sigma(s)*randn(size(IMin0));
%         images(i).sigma(s).Inoise = Inoise;
%         images(i).sigma(s).PSNRIn =20*log10(params.maxval * sqrt(numel(IMin0)) / norm(IMin0(:)-Inoise(:)));  
%         imwrite(Inoise/params.maxval, fullfile(db_path,strcat(name,'_sig',int2str(sigma(s)),'_noisy','_PSNR',...
%             num2str(images(i).sigma(s).PSNRIn ,'%.2f'),ext)));
%         params.x = Inoise;
%         params.sigma = sigma(s);
%         for d = 1:length(dicts)
%             if (dicts(d).use)
%                 params.dict = dicts(d).value;
%                 images(i).sigma(s).dict(d).name = dicts(d).name;
%                 images(i).sigma(s).dict(d).Idenoise = ompdenoise2(params);
%                 images(i).sigma(s).dict(d).PSNROut = 20*log10(params.maxval * sqrt(numel(IMin0)) / ...
%                     norm(IMin0(:)-images(i).sigma(s).dict(d).Idenoise(:)));
%                 imwrite(images(i).sigma(s).dict(d).Idenoise/params.maxval, fullfile(db_path,strcat(name,'_sig', ...
%                     int2str(sigma(s)),'_denoised_',dicts(d).name,'_PSNR',...
%                     num2str(images(i).sigma(s).dict(d).PSNROut,'%.2f'),ext)));
%                 %KSVD 
%                 params.initdict = dicts(d).value;
%                 [images(i).sigma(s).dict(d).KSVD.Idenoise,images(i).sigma(s).dict(d).KSVD.traniedDict] = ksvddenoise(params);
%                 images(i).sigma(s).dict(d).KSVD.PSNROut = 20*log10(params.maxval * sqrt(numel(IMin0)) / ...
%                     norm(IMin0(:)-images(i).sigma(s).dict(d).KSVD.Idenoise(:)));          
%                 imwrite(images(i).sigma(s).dict(d).KSVD.Idenoise/params.maxval, fullfile(db_path,...
%                     strcat(name,'_sig',int2str(sigma(s)),'_denoised_',dicts(d).name,'_KSVD','_PSNR',...
%                     num2str(images(i).sigma(s).dict(d).KSVD.PSNROut,'%.2f'),ext)));
%             end
%         end

%     end
end
end


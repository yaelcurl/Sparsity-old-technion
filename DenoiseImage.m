function [ image ] = DenoiseImage( image,params,sigma,dicts )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~, name,ext] = fileparts(image.name);
denoising_dir = fullfile(image.dir, 'Denoising');

dict = struct('name',cell(1,length(dicts)),'Idenoise',[],'PSNROut',[],'SSIM',[],'KSVD_Idenoise',[],...
    'KSVD_trainedDict',[],'KSVD_PSNROut',[],'KSVD_SSIM',[]);
if (~isfield(image,'original') || isempty(image.original) )
    image.original = double(imread(fullfile(image.dir,image.name)));
end
for s = sort(1:length(sigma),'descend') 
%     if (~(isfield(image,'sigma')) || (isfield(image,'sigma') && length(image.sigma)<s ))
%         image.sigma(s).value = sigma(s);
%     end
    s
    if (length(image.sigma)<s)
        image.sigma(s).value = sigma(s);
        image.sigma(s).dict = dict;
    end
    if  (~(isfield(image.sigma(s),'Inoise')) || isempty(image.sigma(s).Inoise))
        Inoise=image.original+sigma(s)*randn(size(image.original));
        image.sigma(s).Inoise = Inoise;
    end
    if (~(isfield(image.sigma(s),'PSNRIn')) || isempty(image.sigma(s).PSNRIn))
        image.sigma(s).PSNRIn =20*log10(params.maxval * sqrt(numel(image.original)) / norm(image.original(:)-Inoise(:)));
%         imwrite(Inoise/params.maxval, fullfile(denoising_dir,strcat(name,'_sig',int2str(sigma(s)),'_noisy','_PSNR',...
%             num2str(image.sigma(s).PSNRIn,'%.2f'),ext)));
    end
    if (~(isfield(image.sigma(s),'SSIMIn')) || isempty(image.sigma(s).SSIMIn))
        image.sigma(s).SSIMIn = ssim(image.sigma(s).Inoise,image.original);
    end
    params.x = image.sigma(s).Inoise;
    params.sigma = sigma(s);
    for d = sort(1:length(dicts),'descend')
        d
        if (length(image.sigma(s).dict)<d || ~strcmp(image.sigma(s).dict(d).name,dicts(d).name))
            image.sigma(s).dict(d).name = dicts(d).name;
        end
        if (~isempty(dicts(d).use) && dicts(d).use && ...
                (~isfield(image.sigma(s),'dict') || (isfield(image.sigma(s),'dict')...
                && (isempty(image.sigma(s).dict) || isempty(image.sigma(s).dict(d).Idenoise)))))
            image.sigma(s).dict(d).name = dicts(d).name;
            if ~ischar(dicts(d).value)
                params.dict = dicts(d).value;
                [image.sigma(s).dict(d).Idenoise,image.sigma(s).dict(d).nz] = ompdenoise2(params);
                image.sigma(s).dict(d).PSNROut = 20*log10(params.maxval * sqrt(numel(image.original)) / ...
                    norm(image.original(:)-image.sigma(s).dict(d).Idenoise(:)));
                image.sigma(s).dict(d).SSIM = ssim(image.sigma(s).dict(d).Idenoise,image.original);
%                 filename = fullfile(denoising_dir,strcat(name,'_sig',...
%                     int2str(sigma(s)),'_denoised_',dicts(d).name,'_PSNR',...
%                     num2str(image.sigma(s).dict(d).PSNROut,'%.2f'),ext));
%                 imwrite(image.sigma(s).dict(d).Idenoise/params.maxval, filename);
            end
            %KSVD 
            if (~isempty(dicts(d).initKSVD) && dicts(d).initKSVD)
                params.initdict = dicts(d).value;
                [image.sigma(s).dict(d).KSVD_Idenoise,image.sigma(s).dict(d).KSVD_trainedDict] = ksvddenoise(params);
                image.sigma(s).dict(d).KSVD_PSNROut = 20*log10(params.maxval * sqrt(numel(image.original)) / ...
                    norm(image.original(:)-image.sigma(s).dict(d).KSVD_Idenoise(:)));
                image.sigma(s).dict(d).KSVD_SSIM = ssim(image.sigma(s).dict(d).KSVD_Idenoise,image.original);
%                 imwrite(image.sigma(s).dict(d).KSVD_Idenoise/params.maxval, fullfile(denoising_dir,...
%                     strcat(name,'_sig',int2str(sigma(s)),'_denoised_',dicts(d).name,'_KSVD','_PSNR',...
%                     num2str(image.sigma(s).dict(d).KSVD_PSNROut,'%.2f'),ext)));
            end
        end
    end



end


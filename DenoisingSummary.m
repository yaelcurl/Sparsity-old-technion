function [ PSNR_data,SSIM_data ] = DenoisingSummary( image )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dicts_num = 1+length([image.sigma(1).dict.PSNROut]);
% KSVD_dicts_num = length([image.sigma(1).dict.KSVD_PSNROut]);
PSNR_data = cell(1+length(image.sigma)*2,2+dicts_num);
SSIM_data = cell(1+length(image.sigma)*2,2+dicts_num);

% PSNRIn = double([image.sigma.PSNRIn]);
% SSIMIn = double([image.sigma.SSIMIn]);

PSNR_data(1,1) = {'Sigma'};
PSNR_data(1,2) = {'PSNRIn'};
PSNR_data(2:2:end,1) = {image.sigma.value};
PSNR_data(3:2:end,1) = {image.sigma.value};
PSNR_data(2:2:end,2) = {image.sigma.PSNRIn};
PSNR_data(3:2:end,2) = {image.sigma.PSNRIn};

SSIM_data(1,1) = {'Sigma'};
SSIM_data(1,2) = {'SSIMIn'};
SSIM_data(2:2:end,1) = {image.sigma.value};
SSIM_data(3:2:end,1) = {image.sigma.value};
SSIM_data(2:2:end,2) = {image.sigma.SSIMIn};
SSIM_data(3:2:end,2) = {image.sigma.SSIMIn};

% data(1:2:end,2) = mat2cell(vertcat(PSNRIn,SSIMIn),2,ones(1,length(SSIMIn)));
% data(2:2:end,2) = mat2cell(vertcat(PSNRIn,SSIMIn),2,ones(1,length(SSIMIn)));


for s = 1:length(image.sigma)
    row = 2*s;
    dind = 0;   
    for d=1:length(image.sigma(s).dict)
        if (~isempty(image.sigma(s).dict(d).SSIM) || ~isempty(image.sigma(s).dict(d).KSVD_SSIM))
            dind=dind+1;
            col = 2+dind;
            PSNR_data(1,col) = cellstr(image.sigma(s).dict(d).name);
            SSIM_data(1,col)= cellstr(image.sigma(s).dict(d).name);
            if ~isempty(image.sigma(s).dict(d).SSIM)            
                PSNR_data(row,col) = num2cell(image.sigma(s).dict(d).PSNROut);
                SSIM_data(row,col)= num2cell(image.sigma(s).dict(d).SSIM);
            end
            if ~isempty(image.sigma(s).dict(d).KSVD_SSIM)
                PSNR_data(row+1,col) = num2cell(image.sigma(s).dict(d).KSVD_PSNROut);
                SSIM_data(row+1,col) = num2cell(image.sigma(s).dict(d).KSVD_SSIM);
            end    
       end
    end
  
%     PSNR_data(ind,3:(2+dicts_num)) =  {image.sigma(s).dict.PSNROut};
%     SSIM_data(ind,3:(2+dicts_num)) = ({image.sigma(s).dict.SSIM});
% %     PSNR_data(ind,3:(2+dicts_num)) = mat2cell(vertcat(PSNROut,SSIM),2,ones(1,length(SSIM)));
%     PSNR_data(ind+1,3:(2+dicts_num)) =  ({image.sigma(s).dict.KSVD_PSNROut});
%     SSIM_data(ind+1,3:(2+dicts_num)) = ({image.sigma(s).dict.KSVD_SSIM});
%     PSNR_data(ind+1,3:(2+KSVD_dicts_num)) = mat2cell(vertcat(PSNROut_KSVD,SSIM_KSVD),2,ones(1,length(SSIM_KSVD)));
end
% dicts_ind = find(~cellfun(@isempty,{image.sigma(1).dict.SSIM}));
% dicts_names = {image.sigma(1).dict.name};
% dicts_names = (dicts_names(dicts_ind));
% PSNR_data(1,:) = [{'sigma','PSNRIn'},cellstr(dicts_names)];
% SSIM_data(1,:) = [{'sigma','SSIMIn'},cellstr(dicts_names)];

% data_table = cell2table(data,'VariableNames', col_names);
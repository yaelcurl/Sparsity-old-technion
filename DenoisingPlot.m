function [  ] = DenoisingPlot(image,params,sigma_choise,dicts_choise,toprint,figures_path)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% sig_ind = find([image.sigma(:).value] == sig);
% sig_ind = find([image.sigma(:).use] == 1);
[~,name,ext]=fileparts(image.name);
    for s = sigma_choise
%         plots_num = 2*length(image.sigma(s).dict)+2;
%         m = 2;
%         n = ceil(plots_num / m);
%         l = 1;
        fig=figure;
%         suptitle(strcat(image.name,' sigma = ',int2str(image.sigma(s).value)));
%         subplot(m,n,l);
        imshow(image.original/params.maxval);
        truesize;
%         if toprint
%             imwrite(image.original/params.maxval, fullfile(figures_path,strcat(name,'_original',ext)));
%         title('original image');
        title({'original image'},'interpreter','none');
%         ax = gca;
%         outerpos = ax.OuterPosition;
%         ti = ax.TightInset; 
%         left = outerpos(1) + ti(1);
%         bottom = outerpos(2) + ti(2);
%         ax_width = outerpos(3) - ti(1) - ti(3);
%         ax_height = outerpos(4) - ti(2) - ti(4);
%         ax.Position = [left bottom ax_width ax_height];
        fig.PaperUnits = 'points';
        fig.PaperPosition = [0 0 250 250];
        fig.PaperPositionMode = 'manual';
        if toprint
%             saveas(fig,fullfile(print_path,strcat(name,'_original','.tiff')));
            print(fullfile(figures_path,strcat(name,'_original')),'-dtiff');
        end
%         l = l+1;
%         subplot(m,n,l);
        fig=figure;
        imshow(image.sigma(s).Inoise/params.maxval);
        truesize(fig);
        fig.PaperUnits = 'points';
        fig.PaperPosition = [0 0 250 250];
        fig.PaperPositionMode = 'manual';
        title({'noisy image',strcat('(PSNR=',num2str(image.sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
                    num2str(image.sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
            int2str(image.sigma(s).value),')')});
        if toprint
            print(fig,fullfile(figures_path,strcat(name,'_',int2str(image.sigma(s).value),'_noisy')),'-dtiff');
%             imwrite(image.sigma(s).Inoise/params.maxval, fullfile(figures_path,strcat(name,'_sig',...
%                 int2str(image.sigma(s).value),'_noisy','_PSNR',...
%                 num2str(image.sigma(s).PSNRIn,'%.2f'),'_SSIMIn',num2str(image.sigma(s).SSIMIn,'%.4f'),ext)));

        end
        for d = dicts_choise
%             l = l+1;
%             subplot(m,n,l);
            if (~isempty(image.sigma(s).dict(d).Idenoise))
                fig=figure;
                imshow(image.sigma(s).dict(d).Idenoise/params.maxval);
                truesize(fig);
                fig.PaperUnits = 'points';
                fig.PaperPosition = [0 0 250 250];
                fig.PaperPositionMode = 'manual';
                title({strcat('denoised with ',strrep(image.sigma(s).dict(d).name,'_', '\_')),...
                    strcat('(PSNR=',num2str(image.sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
                    num2str(image.sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
                    int2str(image.sigma(s).value),')')});     
            if toprint
%                 filename = fullfile(figures_path,strcat(name,'_sig',...
%                     int2str(image.sigma(s).value),'_denoised_',image.sigma(s).dict(d).name,'_PSNR',...
%                     num2str(image.sigma(s).dict(d).PSNROut,'%.2f'),'_SSIM',...
%                     num2str(image.sigma(s).dict(d).SSIM,'%.4 f'),ext));
%                 imwrite(image.sigma(s).dict(d).Idenoise/params.maxval, filename);
%                             
                print(fig,fullfile(figures_path,strcat(name,'_',int2str(image.sigma(s).value),...
                    image.sigma(s).dict(d).name)),'-dtiff');
            end
    %             l = l+1;
    %             subplot(m,n,l);
            end
            if (~isempty(image.sigma(s).dict(d).KSVD_Idenoise))         
                fig=figure;
                imshow(image.sigma(s).dict(d).KSVD_Idenoise/params.maxval);
                truesize(fig);
                title({strcat('KSVD denoised, initialized ',...
                    strrep(image.sigma(s).dict(d).name,'_','\_')),strcat('(PSNR=',...
                    num2str(image.sigma(s).dict(d).KSVD_PSNROut,'%.2f'),' db, SSIM= ',...
                    num2str(image.sigma(s).dict(d).KSVD_SSIM,'%.4f'), ' \sigma = ', ...
                int2str(image.sigma(s).value),')')});
                figure;
                showdict(image.sigma(s).dict(d).KSVD_traniedDict,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
                title({strcat('KSVD trained dict on ',image.name),strcat('initilized ',image.sigma(s).dict(d).name)}, 'Interpreter', 'none');
        
            end
        end
    end
end
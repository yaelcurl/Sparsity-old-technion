clear all; close all;

%path
project_path = fullfile('E:\Dropbox\Project B - Sparcity');
code_path = fullfile(project_path,'code');
db_path = fullfile(code_path, 'database');
db_path_test = fullfile(db_path,'test_images');
db_path_brodatz=fullfile(db_path,'brodatz_stochastic_small');
file_pattern_brodatz = '*.gif';
db_path_synth_fbm = fullfile(db_path,'synthetic fbm');
db_path_mcgill_stochastic = fullfile(db_path,'mcgill_textures_stochastic_small');
file_pattern_mcgill = '*.jpg';
db_path_portilla = fullfile(db_path_test,'standard_portilla');
file_pattern_portilla = '*.png';
figures_path = fullfile(project_path, 'book figures');
cartoon_path = fullfile(db_path,'cartoon');
mca_path = fullfile(db_path,'mca_images');

%load
dicts = load('dicts');
dicts = dicts.dicts;

portilla_images = load('portilla_images.mat');
portilla_images = portilla_images.portilla_images;
mcgill_images = load('mcgill_images.mat');
mcgill_images = mcgill_images.mcgill_images;
mcgill_images_small = load('mcgill_images_small');
mcgill_images_small = mcgill_images_small.mcgill_images_small;
cartoon = load('cartoon');
cartoon = cartoon.cartoon;
images_png = load('images_png');
images_png = images_png.images_png;
ims2 = load('ims2');
ims2 = ims2.ims2;



%save
save(fullfile(code_path,'dicts',strcat('dicts.mat')),'dicts','-mat');
save(fullfile(db_path_portilla,strcat('portilla_images.mat')),'portilla_images','-mat');
dumvar=0;
save(fullfile(db_path_mcgill_stochastic,'Denoising',strcat('mcgill_images.mat')),'mcgill_images','-mat','dumvar','-v7.3');
save(fullfile(db_path_mcgill_stochastic,'Denoising','mcgill_images_small.mat'),'mcgill_images_small','-mat','dumvar','-v7.3');
save(fullfile(cartoon_path,'Denoising','cartoon.mat'),'cartoon','-mat');
save(fullfile(db_path_test,'Denoising','images_jpg.mat'),'images_jpg','-mat');
save(fullfile(db_path_test,'Denoising','images_png.mat'),'images_png','-mat');
save(fullfile(db_path_test,'Denoising','images_gif.mat'),'images_gif','-mat');
save(fullfile(db_path_test,'Denoising','ims.mat'),'ims','-mat');
save(fullfile(code_path,'dicts2',strcat('dicts2.mat')),'dicts2','-mat');
    
%% dicts

% Globaly trained dictionary by Michael Elad
dicts(1).name = 'Global';
global_dict = load('globalTrainedDictionary.mat');
dicts(1).value = global_dict.currDictionary;
clear global_dict;
figure();
showdict(dicts(1).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title('Global Trained dictionary - Michael Elad');

%  DCT dictionary
dicts(2).name = 'DCT';
dicts(2).value = CreateDict('DCT',params);
% save(fullfile(code_path,'dicts',strcat('dict_',dicts(2).name,'.mat')),'-struct','dicts(2)','value','-mat');
figure(2);
showdict(dicts(2).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title('initial DCT dictionary');

%FBM
params.dictsize = 256;
dicts(5).name = 'fBM';
dicts(5).value = CreateSynthFbmDict( params ,[0,1]);
figure;
showdict(dicts(3).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title('large fBM H>0.2 dictionary');

%FBM trained on synthetic fbms
fbm_data_num = 30;
data_size = 512;
CreateSynthFbmData(db_path_synth_fbm,data_size,fbm_data_num);
max_images = 30;
params.trainnum = 20000;
file_pattern_fbm = '*.mat';
fbm_train_data = CreateBlocksFromDB(db_path_synth_fbm,file_pattern_fbm,params,max_images);
save(fullfile(db_path_synth_fbm,strcat('fbm_train_data.mat')),'fbm_train_data','-mat');
params.data = fbm_train_data;
% param.iternum = 50;
params.Tdata = 6; % following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
params = rmfield(params,'initdict');
dicts(4).name = 'fbm_trained_initData';
dicts(4).value = ksvd(params);
figure;
showdict(dicts(4).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title('Dictionary Trained on synth FBM, initialized Data, L=6');

%trained on mcgill texture stochastic
max_images = 48;
params.trainnum = 10000;
mcgill_train_data = CreateBlocksFromDB(db_path_mcgill_stochastic,file_pattern_mcgill,params,max_images);
save(fullfile(db_path_mcgill_stochastic,strcat('mcgill_train_data.mat')),'mcgill_train_data','-mat');
params.data = mcgill_train_data;
% param.iternum = 50;
params.Tdata = 6; % following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
params = rmfield(params,'initdict');
dicts(6).name = 'mcgill';
dicts(6).value = ksvd(params);
figure;
showdict(dicts(6).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title({'Dictionary Trained on mcgill stochastic','initialized data, L=6'});

%combined DCT + mcgill
dicts(7).name = 'mcgill and DCT';
dicts(7).value = [dicts(6).value,dicts(2).value];

%combined DCT + highfBM
dicts(8).name = 'highfBM and DCT';
dicts(8).value = [dicts(3).value,dicts(2).value];

%combined trained FBM + mcgill
dicts(9).name = 'brodatz and DCT';
dicts(9).value = [dicts(5).value,dicts(2).value];

%combined trained FBM + mcgill
dicts(10).name = 'fBMtrained and DCT';
dicts(10).value = [dicts(4).value,dicts(2).value];

%combined DCT + mcgill
dicts(11).name = 'mcgill & global';
dicts(11).value = [dicts(6).value,dicts(1).value];

%combined DCT + highfBM
dicts(12).name = 'highfBM & global';
dicts(12).value = [dicts(3).value,dicts(1).value];

%combined trained FBM + mcgill
dicts(13).name = 'brodatz & global';
dicts(13).value = [dicts(5).value,dicts(1).value];

%combined trained FBM + mcgill
dicts(14).name = 'fBMtrained & global';
dicts(14).value = [dicts(4).value,dicts(1).value];

dicts(15).name = 'fBMtrained & brodatz & mcgill';
dicts(15).value = [dicts(4).value,dicts(5).value,dicts(6).value];

dicts(13).name = 'DCT_and_highfBM';
dicts(13).value = [dicts(2).value dicts(4).value];

dicts(14).name = 'Global_and_highfBM';
dicts(14).value = [dicts(1).value dicts(4).value];


%init data
dicts(15).name = 'data';
dicts(15).value = 'data';


%trained on brodatz
params.trainnum = 20000;
max_images_brodatz = 45;
blk_matrix_brodatz = CreateBlocksFromDB(db_path_brodatz,file_pattern_brodatz,params,max_images_brodatz);
params.data = blk_matrix_brodatz;
% param.iternum = 50;
params.Tdata = 6; % following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
params = rmfield(params,'initdict');
dicts(5).name = 'brodatz';
dicts(5).value = brodatznew;
figure();
showdict(dicts(5).value,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
title({'Dictionary Trained on Brodatz stochastic', 'initialized with data elements, L=6'});

%% Denoising Experiments
redundency_factor = 4;
params = struct('x',[],'blocksize',8,'dictsize',redundency_factor*8^2, ...
    'sigma',[],'trainnum',[],'initdict',[],'maxval', 255, 'noisemode','sigma');
sigma = [2 5 10 15 20 25 50 75 100]; %following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
% dicts = struct('name',cell(1,8),'value',[],use,[],'initKSVD',[]);
KSVD_use = [1 2 3 8 9 13];
sigma = [20 50];


dicts_choise = [1,2,3,7,6,9,12,11,10,13]; 
portilla_images = LoadImagesStruct( db_path_portilla,file_pattern_portilla,sigma,dicts );
portilla_images = DenoisingExperiments( portilla_images,[1:1:length(portilla_images)],sigma,params,dicts,13,13 );

DenoisingPlot(portilla_images(3),params,[7],[2 9 10 14]);
DenoisingPlot(portilla_images(4),params,[20],dicts_choise);

portilla_images = load('portilla_images.mat');
portilla_images = portilla_images.portilla_images;
portilla_images = DenoisingExperiments( portilla_images,[3,4],sigma,params,dicts,[2] );
DenoisingPlot(portilla_images(3),params,[5],[2]);
DenoisingPlot(portilla_images(4),params,[5],[2]);


mcgill_images = LoadImagesStruct(db_path_mcgill_stochastic,file_pattern_mcgill,sigma,dicts);
mcgill_images = DenoisingExperiments( mcgill_images,[1,14],sigma,params,dicts,[3,8] );
save(fullfile(db_path_mcgill_stochastic,'Denoising',strcat('mcgill_images.mat')),'mcgill_images','-mat');
DenoisingPlot(mcgill_images(1),params,5,[3,8]);
DenoisingPlot(mcgill_images(14),params,5,[3,8]);
DenoisingPlot(mcgill_images(5),params,6,[1,3,12]);

    
mcgill_images = DenoisingExperiments( mcgill_images,[1],sigma,params,dicts,[1,2] );
DenoisingPlot(mcgill_images(1),params,5,[1,2]);

data_table = DenoisingSummary( image );

mcgill_images = DenoisingExperiments( mcgill_images,[1,5,14],sigma,params,dicts,[9] );
mcgill_images = DenoisingExperiments( mcgill_images,[1,5,14,22],sigma,params,dicts,[1,2,3,7,6,9,12,11,10,13],KSVD_use );
mcgill_images = DenoisingExperiments( mcgill_images,[14],sigma,params,dicts,[1,2,3,7,6,9,12,11,10,13] );
mcgill_images = DenoisingExperiments( mcgill_images,[14],sigma,params,dicts,8,[] );
mcgill_images = DenoisingExperiments( mcgill_images,[1,5,14,22],sigma,params,dicts,[8],[] );

portilla_images = LoadImagesStruct(db_path_portilla,file_pattern_portilla,sigma,dicts);
portilla_images = DenoisingExperiments( portilla_images,[1:length(portilla_images)],sigma,params,dicts,[3,8] );
portilla_images = DenoisingExperiments( portilla_images,[1,3,4],sigma,params,dicts,[14],14 );

DenoisingPlot(mcgill_images(5),params,[2 3 10 12],[2 50]);

mcgill_images_small = LoadImagesStruct(db_path_mcgill_stochastic,file_pattern_mcgill,sigma,dicts);
mcgill_images_small=DenoisingExperiments( mcgill_images_small,[1:length(mcgill_images_small)],sigma,params,dicts,1:length(dicts)-1,[] );
mcgill_images_small=DenoisingExperiments( mcgill_images_small,[1:length(mcgill_images_small)],sigma,params,dicts,[11 12 13 14],[] );

%% summary
table5 = DenoisingSummary( mcgill_images(5) );
[barb,barb_cols] = DenoisingSummary( portilla_images(1) );
[ PSNR_data_,SSIM_data ] = DenoisingSummary( mcgill_images_small(137) );
DenoisingPlot(mcgill_images_small(137),params,[6 ],[1 2 4 12],1,figures_path)
%% help codes
for i=1:length(mcgill_images)
    for s=1:length(sigma)
        for d=1:length(dicts)
            if ~isempty(mcgill_images(i).sigma(s).dict(d).Idenoise)                
                mcgill_images(i).sigma(s).SSIMIn = ssim(mcgill_images(i).sigma(s).Inoise,mcgill_images(i).original);
%                 mcgill_images(i).sigma(s).dict(d).SSIM = ssim(mcgill_images(i).sigma(s).dict(d).Idenoise,mcgill_images(i).original);
%                 mcgill_images(i).sigma(s).dict(d).KSVD_SSIM = ssim(mcgill_images(i).sigma(s).dict(d).KSVD_Idenoise,mcgill_images(i).original);
            end
        end
    end
end

%% 
barb1 = double(imread(fullfile(db_path_test,'barbara1.png')));
barb1_noisy = barb1 + 25*randn(size(barb1));
params.x = barb1_noisy;
params.dict = dicts(2).value;
params.sigma=25;
barb1_denoised_DCT = ompdenoise2(params);
figure;
subplot(131); imshow(barb1/255); title('original');
subplot(132); imshow(barb1_noisy/255); title('noisy \sigma=25');
subplot(133); imshow(barb1_denoised_DCT/255); title('denoised with DCT dict');

b = fspecial('gaussian',3,0.7); % blur filter
B = convcircmat2(b,params.blocksize,params.blocksize);

ex2 = double(imread(fullfile(db_path_test,'image416_1.png')));
ex2_noisy = ex2+50*randn(size(ex2));
params.x = ex2_noisy;
params.dict = dicts(4).value;
params.sigma=50;
ex2_den_haar = ompdenoise2(params);
figure;
subplot(131); imshow(ex2/255); title('original');
subplot(132); imshow(ex2_noisy/255); title('noisy \sigma=50');
subplot(133); imshow(ex2_den_haar/255); title('denoised with Haar dict');

ex2 = double(imread(fullfile(db_path_test,'samplepippin0020_gray (2).jpg')));
ex2_noisy = ex2+50*randn(size(ex2));
params.x = ex2_noisy;
params.dict = dicts(5).value;
params.sigma=50;
ex2_den_haar = ompdenoise2(params);
figure;
subplot(131); imshow(ex2/255); title('original');
subplot(132); imshow(ex2_noisy/255); title('noisy \sigma=50');
subplot(133); imshow(ex2_den_haar/255); title('denoised with fBM dict');

imfilter(im{i}.orig,b,'replicate') + im{i}.noiseim*sig;

images_jpg = LoadImagesStruct(db_path_test,'*.jpg',sigma,dicts);
images_jpg = DenoisingExperiments(images_jpg,1:length(images_jpg),sigma,params,dicts,1:15,[]);
images_png = LoadImagesStruct(db_path_test,'*.png',sigma,dicts);
images_png = DenoisingExperiments(images_png,1:length(images_png),sigma,params,dicts,1:3,[]);
images_gif = LoadImagesStruct(db_path_test,'*.gif',sigma,dicts);
images_gif = DenoisingExperiments(images_gif,1:length(images_gif),sigma,params,dicts,1:15,[]);

figure;
subplot(221); imshow(images_jpg(3).original/255); title({images_jpg(3).name,'original'},'interpreter','none');
subplot(222); imshow(images_jpg(3).sigma(2).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_jpg(3).sigma(2).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_jpg(3).sigma(2).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(3).sigma(2).value),')')});
subplot(223); imshow(images_jpg(3).sigma(2).dict(1).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(3).sigma(2).dict(1).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(3).sigma(2).dict(1).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(3).sigma(2).dict(1).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(3).sigma(2).value),')')});     
subplot(224); imshow(images_jpg(3).sigma(2).dict(15).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(3).sigma(2).dict(15).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(3).sigma(2).dict(15).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(3).sigma(2).dict(15).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(3).sigma(2).value),')')});     

i=1;
figure;
subplot(141); imshow(images_jpg(i).original/255); title({images_jpg(i).name,'original'},'interpreter','none');
subplot(142); imshow(images_jpg(i).sigma(2).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_jpg(i).sigma(2).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_jpg(i).sigma(2).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});
d=11;
subplot(143); imshow(images_jpg(i).sigma(2).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(2).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(2).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(2).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});     
d=12;
subplot(144); imshow(images_jpg(i).sigma(2).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(2).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(2).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(2).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});     


i=2;
s=1;
figure;
subplot(221); imshow(images_png(i).original/255); title({images_png(i).name,'original'},'interpreter','none');
subplot(222); imshow(images_png(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_png(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_png(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});
d=3;
subplot(223); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     
d=13;
subplot(224); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     


i=5;
s=2;
figure;
subplot(221); imshow(images_png(i).original/255); title({images_png(i).name,'original'},'interpreter','none');
subplot(222); imshow(images_png(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_png(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_png(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});
d=1;
subplot(223); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     
d=3;
subplot(224); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     

i=8;
s=2;
figure;
subplot(221); imshow(images_png(i).original/255); title({images_png(i).name,'original'},'interpreter','none');
subplot(222); imshow(images_png(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_png(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_png(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});
d=4;
subplot(223); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     
d=14;
subplot(224); imshow(images_png(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_png(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_png(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_png(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_png(i).sigma(s).value),')')});     


i=3;
figure;
subplot(141); imshow(images_jpg(i).original/255); title({images_jpg(i).name,'original'},'interpreter','none');
subplot(142); imshow(images_jpg(i).sigma(2).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_jpg(i).sigma(2).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_jpg(i).sigma(2).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});
d=9;
subplot(143); imshow(images_jpg(i).sigma(2).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(2).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(2).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(2).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});     
d=15;
subplot(144); imshow(images_jpg(i).sigma(2).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(2).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(2).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(2).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(2).value),')')});     

i=4;
s=1;
figure;
subplot(141); imshow(images_jpg(i).original/255); title({images_jpg(i).name,'original'},'interpreter','none');
subplot(142); imshow(images_jpg(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_jpg(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_jpg(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});
d=2;
subplot(143); imshow(images_jpg(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});     
d=13;
subplot(144); imshow(images_jpg(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});     


i=2;
s=2;
figure;
subplot(141); imshow(images_gif(i).original/255); title({images_gif(i).name,'original'},'interpreter','none');
subplot(142); imshow(images_gif(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_gif(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_gif(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_gif(i).sigma(s).value),')')});
d=2;
subplot(143); imshow(images_gif(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_gif(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_gif(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_gif(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_gif(i).sigma(s).value),')')});     
d=10;
subplot(144); imshow(images_gif(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_gif(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_gif(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_gif(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_gif(i).sigma(s).value),')')});     

images_jpg(5).dir = db_path_test;
images_jpg(5).name = 'flinstones_1.jpg';
images_jpg(5) = DenoiseImage( images_jpg(5),params,sigma,dicts );



i=5;
s=1;
figure;
subplot(141); imshow(images_jpg(i).original/255); title({images_jpg(i).name,'original'},'interpreter','none');
subplot(142); imshow(images_jpg(i).sigma(s).Inoise/255); 
title({'noisy image',strcat('(PSNR=',num2str(images_jpg(i).sigma(s).PSNRIn,'%.2f'),' db, SSIM= ',...
            num2str(images_jpg(i).sigma(s).SSIMIn,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});
d=1;
subplot(143); imshow(images_jpg(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});     
d=3;
subplot(144); imshow(images_jpg(i).sigma(s).dict(d).Idenoise/255); 
title({strcat('denoised with ',strrep(images_jpg(i).sigma(s).dict(d).name,'_', '\_')),...
    strcat('(PSNR=',num2str(images_jpg(i).sigma(s).dict(d).PSNROut,'%.2f'),' db, SSIM= ',...
    num2str(images_jpg(i).sigma(s).dict(d).SSIM,'%.4f'), ' \sigma = ', ...
    int2str(images_jpg(i).sigma(s).value),')')});     

dicts(16).name = 'Haar';
Haar= full(Generate_Haar_Matrix(params.blocksize)); % haar wavelets, for cartoon
for i = 1:size(Haar,2)
    Haar(:,i) = Haar(:,i)/norm(Haar(:,i));
end
dicts(16).value = Haar;
ims2 = LoadImagesStruct(db_path_test,'*.*',sigma,dicts);
ims = DenoisingExperiments(ims,1:length(ims),sigma,params,dicts,[16 2 3], []); 
DenoisingSubPlot( ims(7),2,[2 3 16] );

dicts2 = dicts;
b = fspecial('gaussian',3,0.7); % blur filter
B = convcircmat2(b,params.blocksize,params.blocksize);
imfilter(im{i}.orig,b,'replicate') + im{i}.noiseim*sig;
lam=0.3;
sparsecode = @(x) sparsecode_handle(x,lam,dict,B); % call BPDN per patch
P0=8; Q=3; % patch size parameters
P = P0-2*Q;

image=ims2(6);
for s = sort(1:length(sigma),'descend') 
    s
    if (length(image.sigma)<s)
        image.sigma(s).value = sigma(s);
        image.sigma(s).dict = dict;
    end
    if  (~(isfield(image.sigma(s),'Inoise')) || isempty(image.sigma(s).Inoise))
        Inoise=imfilter(image.original,b,'replicate')+sigma(s)*randn(size(image.original));
        image.sigma(s).Inoise = Inoise;
    end
    if (~(isfield(image.sigma(s),'PSNRIn')) || isempty(image.sigma(s).PSNRIn))
        image.sigma(s).PSNRIn =20*log10(params.maxval * sqrt(numel(image.original)) / norm(image.original(:)-Inoise(:)));
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
        if ((~isfield(image.sigma(s),'dict') || (isfield(image.sigma(s),'dict')...
                && (isempty(image.sigma(s).dict) || isempty(image.sigma(s).dict(d).Idenoise)))))
            image.sigma(s).dict(d).name = dicts(d).name;
            if ~ischar(dicts(d).value)
                params.dict = dicts(d).value;
                image.sigma(s).dict(d).Idenoise = blockproc(image.sigma(s).Inoise,P*[1 1],...
                    sparsecode, 'bordersize',Q*[1 1],...
        'padpartialblocks',1,'padmethod','symmetric','trimborder',1,...
        'useparallel',1);
                image.sigma(s).dict(d).PSNROut = 20*log10(params.maxval * sqrt(numel(image.original)) / ...
                    norm(image.original(:)-image.sigma(s).dict(d).Idenoise(:)));
                image.sigma(s).dict(d).SSIM = ssim(image.sigma(s).dict(d).Idenoise,image.original);
            end
        end
    end
end




i=13;

%% mca

params = struct('blocksize',8,'path',fullfile(mca_path,'res'),...
    'y0',[],'y',[],'sigma',[],'name',[],'ext',[]);

%winter0003
params.sigma = 10;
params.y0=imread(fullfile(mca_path,'winter0003.jpg'));
N=min(size(params.y0)  );
params.y0=imcrop(double(params.y0),[0 0 N N]); 
params.y0=params.y0;
noise=randn(N,N);
params.y=params.y0+params.sigma*noise; % add noise
params.dict(1) = dicts(2);
params.dict(2) = dicts(3);
params.name = 'winter0003';
params.ext = '.jpg';
[outputs]=Local_MCA_KSVD(params);

%sig=50
params.blocksize=8;
params.sigma = 10;
params.y0=imread(fullfile(mca_path,'melon.jpg'));
N=min(size(params.y0)  );
params.y0=imcrop(double(params.y0),[0 0 N N]); 
params.y0=params.y0;
noise=randn(N,N);
params.y=params.y0+params.sigma*noise; % add noise
params.dict = dicts(3);
% params.dict(2) = dicts(3);
params.name = 'melon';
params.ext = '.jpg';
outputs=Local_MCA_KSVD(params);

%	0005 
params.sigma = 10;
params.y0=imread(fullfile(mca_path,'winter0003.jpg'));
N=min(size(params.y0)  );
params.y0=imcrop(double(params.y0),[0 0 N N]); 
params.y0=params.y0;
noise=randn(N,N);
params.y=params.y0+params.sigma*noise; % add noise
params.dict = dicts(2);
% params.dict(2) = dicts(3);
params.name = 'winter';
params.ext = '.jpg';
[outputs]=Local_MCA_KSVD(params);

%D2
params.sigma = 10;
params.y0=rgb2gray(imfuse(imread(fullfile(mca_path,'boy.tif')),imread(fullfile(mca_path,'texture4.tif'))));
N=min(size(params.y0)  );
params.y0=imcrop(double(params.y0),[0 0 N N]); 
params.y0=params.y0;
noise=randn(N,N);
params.y=params.y0+params.sigma*noise; % add noise
params.dict = dicts(2);
% params.dict(2) = dicts(3);
params.name = 'adar';
params.ext = '.gif';
[outputs]=Local_MCA_KSVD(params);

%image377
params.dictsize = 256;
params.blocksize = 16;
params.sigma = 10;
params.y0=imread(fullfile(mca_path,'tomandjerry_fingerprint.png'));
N=min(size(params.y0)  );
params.y0=imcrop(double(params.y0),[0 0 N N]); 
params.y0=params.y0;
noise=randn(N,N);
params.y=params.y0+params.sigma*noise; % add noise
DCT16.name = 'DCT16';
DCT16.value = CreateDict( 'DCT',params );
params.dict = DCT16;
% params.dict(2) = dicts(3);
params.name = 'tomandjerry_fingerprint';
params.ext = '.png';
[outputs]=Local_MCA_KSVD(params);

%% fBM figures
fbm1 = zeros(64,256);
fbm2 = zeros(64,256);
for i=1:256
    H = rand(1,1);
    blk1 = synth2(8,H);
    blk2 = synth2(8,H);
    fbm1(:,i) = blk1(:);
    fbm2(:,i) = blk2(:);
end
figure; subplot(121); showdict(fbm1,[1 1]*8,round(sqrt(256)),round(sqrt(256)),'highcontrast');
 subplot(122); showdict(fbm2,[1 1]*8,round(sqrt(256)),round(sqrt(256)),'highcontrast');

 
fbm = zeros(64,256);
H=linspace(0.0001,0.999,32);
for i=1:32
    h=H(i);
    for j=1:8
        blk1 = synth2(8,h);
        fbm(:,(i-1)*8+j) = blk1(:);
    end
end
figure; showdict(fbm,[1 1]*8,round(sqrt(64)),32,'highcontrast'); truesize;

fbm1 = zeros(64,256);
fbm2 = zeros(64,256);
H=linspace(0.0001,0.999,256);
for i=1:256
    blk1 = synth2(8,H(i));
    blk2 = synth2(8,H(i));
    fbm1(:,i) = blk1(:);
    fbm2(:,i) = blk2(:);
end
figure; subplot(121); showdict(fbm1,[1 1]*8,round(sqrt(256)),round(sqrt(256)),'highcontrast');
 subplot(122); showdict(fbm2,[1 1]*8,round(sqrt(256)),round(sqrt(256)),'highcontrast');
trusize;

     
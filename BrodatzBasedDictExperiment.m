function [ ] = BrodatzBasedDictExperiment( db_path,atom_size,data_size,DCT_dict )

db_path_brodatz=fullfile(db_path,'brodatz');
file_pattern_brodatz = '*.gif';

max_block_per_image_brodatz = 40000;
max_images_brodatz = 10;
blk_matrix_brodatz = CreateBlocksFromDB(db_path_brodatz,file_pattern_brodatz,atom_size,max_block_per_image_brodatz,max_images_brodatz);
param.K = data_size;
% param.numIteration = 180; % following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
param.numIteration = 50;
param.errorFlag = 0; % no information on noise, use fixed nember of coeff
param.L = 6; % following "IMAGE DENOISING VIA SPARSE AND REDUNDANT REPRESENTATIONS"
param.preserveDCAtom = 0;
param.initialDictionary = DCT_dict(:,1:param.K );
param.InitializationMethod =  'GivenMatrix';
param.displayProgress = 1;
[brodatz_trained_dict, brodatz_output] = KSVD(blk_matrix_brodatz, param);
figure;
displayDictionaryElementsAsImage(brodatz_trained_dict, floor(sqrt(atom_num)), floor(sqrt(atom_num)),atom_size,atom_size,0);
end


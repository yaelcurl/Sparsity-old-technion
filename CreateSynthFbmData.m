function [  ] = CreateSynthFbmData( folder_path,data_size,data_num )

Hs = linspace(0.2+1/data_num,1-1/data_num,data_num);
for H= Hs
    fbm = synth2(data_size,H);
    save(fullfile(folder_path,strcat('H_',strrep(num2str(H),'.','-'),'.mat')),'fbm','-mat');
    clear fbm;
end


end

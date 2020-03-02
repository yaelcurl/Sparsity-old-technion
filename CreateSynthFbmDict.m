function [ synth_fbm_dict ] = CreateSynthFbmDict( params,range )

synth_fbm_dict = zeros(params.blocksize^2,params.dictsize);
Hs = linspace(range(1)+1/params.dictsize,min(1-1/params.dictsize,range(2)),params.dictsize);
for i = 1:params.dictsize
    fbm = synth2(params.blocksize,Hs(i));
    fbm = reshape(fbm,params.blocksize^2,1);
    fbm = fbm - mean(fbm);
    synth_fbm_dict(:,i) = fbm / norm(fbm);
    
end

end


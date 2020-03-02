function [ dict ] = CreateDict( dict_type,params )

if strcmpi( dict_type,  'DCT')
    DCT_dict=zeros(params.blocksize,floor(sqrt(params.dictsize)));
    for k=0:1:sqrt(params.dictsize)-1,
        V=cos([0:1:params.blocksize-1]'*k*pi/floor(sqrt(params.dictsize)));
        if k>0, V=V-mean(V); end;
        DCT_dict(:,k+1)=V/norm(V);
    end;
    DCT_dict=kron(DCT_dict,DCT_dict);
    dict=DCT_dict; 
end

if strcmpi( dict_type,  'FBM')
    fbm_dict = CreateSynthFbmDict(params);
    dict = fbm_dict;
end 


end
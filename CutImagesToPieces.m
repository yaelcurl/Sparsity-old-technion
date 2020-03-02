function [  ] = CutImagesToPieces( dir_path,new_path, new_size,max_pieces )
NM = new_size(1);
NN = new_size(2);
if ~exist(new_path,'dir')
    mkdir(new_path)
end
files = dir(fullfile(dir_path));
for file = files'
    [~, name,ext] = fileparts(file.name);
    if sum(strcmp(ext,{'.jpg','.jpeg','.gif','.png','.tif','.bmp'}))
        im = (imread((fullfile(dir_path,file.name))));
        [M,N] = size(im);
        if (max_pieces >= (ceil(M/NM)*ceil(N/NN)))
            i = 0;
            for ymin=1:NM:M 
                for xmin=1:NN:N
                    i = i+1;
                    cropped = imcrop(im,[min(xmin,N-NN+1) min(ymin,M-NM+1) (NM-1) (NN-1)]);
                    imwrite(cropped, fullfile(new_path,strcat(name,'_',int2str(i),ext)));
                end
            end
        else
            ymin = randperm(M,max_pieces);
            xmin = randperm(N,max_pieces);
            for i=1:max_pieces
                cropped = imcrop(im,[min(xmin(i),N-NN+1) min(ymin(i),M-NM+1) (NM-1) (NN-1)]);
                imwrite(cropped, fullfile(new_path,strcat(name,'_',int2str(i),ext)));
            end
        end
    end
end

end




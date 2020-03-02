function [  ] = ConvertAllFilesToGray(dir_path )
files = dir(fullfile(dir_path));
for file = files'
    [~, name,ext] = fileparts(file.name);
    if sum(strcmp(ext,{'.jpg','.jpeg','.gif','.png','.tif','.bmp'}))
        im = (imread((fullfile(dir_path,file.name))));
        if numel(size(im))>2
            im = rgb2gray(im);
            imwrite(im, fullfile(dir_path,file.name));
%             if (overwrite == 1)
%                 delete(fullfile(dir_path,file.name));
%             end
        end
    end
end

end


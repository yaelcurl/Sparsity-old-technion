 function [ joint_blk_matrix ] = CreateBlocksFromDB( db_path,file_pattern,params,max_images )
 
slidingDis = 1;
reduceDC = 1;

cnt = 0;
files = dir(fullfile(db_path,file_pattern));
joint_blk_matrix = zeros(params.blocksize^2,params.trainnum*length(files));

for file = files'
    cnt = cnt + 1;
    [~,name,ext] = fileparts(file.name);
    if (strcmp(ext,'.mat'))
        IMin0 = load(fullfile(db_path,file.name));
        data = fieldnames(IMin0);
        IMin0 = getfield(IMin0,data{1});
    else
        [IMin0,pp]=imread(fullfile(db_path,file.name));
        IMin0=double(IMin0);
    end
    
%     while (prod(floor((size(IMin0)-blk_size)/slidingDis)+1)>maxBlocksToConsider)
%         slidingDis = slidingDis+1;
%     end    
%     [blocks,idx] = my_im2col(IMin0,[blk_size,blk_size],slidingDis);
    
    if(prod(size(IMin0)-params.blocksize+1)> params.trainnum)
        randPermutation =  randperm(prod(size(IMin0)-params.blocksize+1));
        selectedBlocks = randPermutation(1:params.trainnum);

        blk_matrix = zeros(params.blocksize^2,params.trainnum);
        for i = 1:params.trainnum
            [row,col] = ind2sub(size(IMin0)-params.blocksize+1,selectedBlocks(i));
            currBlock = IMin0(row:row+params.blocksize-1,col:col+params.blocksize-1);
            blk_matrix(:,i) = currBlock(:);
        end
    else
        blk_matrix = im2col(IMin0,[params.blocksize,params.blocksize],'sliding');
    end    
    
    if (reduceDC)
        vecOfMeans = mean(blk_matrix);
        blk_matrix = blk_matrix-ones(size(blk_matrix,1),1)*vecOfMeans;
    end    

    joint_blk_matrix(:,((cnt-1)*params.trainnum+1):(cnt*params.trainnum)) = blk_matrix;
    
    if cnt >= max_images
        break
    end
end


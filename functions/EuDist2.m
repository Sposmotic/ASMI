function D = EuDist2(fea_a, fea_b, bSqrt)
% EuDist2 高效计算欧几里得距离矩阵
%   D = EuDist(fea_a, fea_b)
%   fea_a:    nSample_a * nFeature  - 第一个样本集的特征矩阵
%   fea_b:    nSample_b * nFeature  - 第二个样本集的特征矩阵
%   D:        nSample_a * nSample_a 或 nSample_a * nSample_b  - 计算得到的欧几里得距离矩阵
%   bSqrt:    是否计算平方根
%       bSqrt = 1: 计算欧几里得距离
%       bSqrt = 0: 计算欧几里得距离的平方
%   
%   编写者：Deng Cai (dengcai@gmail.com)

if ~exist('bSqrt','var')
    bSqrt = 1; 
    % bSqrt=1: 计算欧几里得距离；bSqrt=0: 计算欧几里得距离的平方
end

if (~exist('fea_b','var')) || isempty(fea_b)
    % 如果fea_b为空，则计算fea_a之间的欧几里得距离
    aa = sum(fea_a .* fea_a, 2);  % 计算fea_a中每个样本的平方和
    ab = fea_a * fea_a';          % 计算fea_a之间的内积
    if issparse(aa)
        aa = full(aa);
    end    
    D = bsxfun(@plus, aa, aa') - 2 * ab;  % 利用广播计算每一对样本之间的距离
    D(D < 0) = 0;  % 防止浮动误差导致的负值
    if bSqrt
        D = sqrt(D);  % 计算欧几里得距离
    end
    D = max(D, D');  % 保证对称
else
    % 如果fea_b不为空，则计算fea_a和fea_b之间的欧几里得距离
    aa = sum(fea_a .* fea_a, 2);  % 计算fea_a中每个样本的平方和
    bb = sum(fea_b .* fea_b, 2);  % 计算fea_b中每个样本的平方和
    ab = fea_a * fea_b';          % 计算fea_a与fea_b之间的内积
    if issparse(aa)
        aa = full(aa);
        bb = full(bb);
    end
    D = bsxfun(@plus, aa, bb') - 2 * ab;  % 利用广播计算每一对样本之间的距离
    D(D < 0) = 0;  % 防止浮动误差导致的负值
    if bSqrt
        D = sqrt(D);  % 计算欧几里得距离
    end
end

function D = EuDist2(fea_a, fea_b, bSqrt)
% EuDist2 Efficiently computes the Euclidean distance matrix
%   D = EuDist2(fea_a, fea_b)
%   fea_a:    nSample_a × nFeature  - Feature matrix of the first sample set
%   fea_b:    nSample_b × nFeature  - Feature matrix of the second sample set
%   D:        nSample_a × nSample_a or nSample_a × nSample_b  - Resulting Euclidean distance matrix
%   bSqrt:    Whether to compute square root
%       bSqrt = 1: Compute Euclidean distance
%       bSqrt = 0: Compute squared Euclidean distance

if ~exist('bSqrt','var')
    bSqrt = 1; 
    % bSqrt=1: Compute Euclidean distance; bSqrt=0: Compute squared Euclidean distance
end

if (~exist('fea_b','var')) || isempty(fea_b)
    % If fea_b is empty, compute Euclidean distance within fea_a
    aa = sum(fea_a .* fea_a, 2);  % Compute squared sum for each sample in fea_a
    ab = fea_a * fea_a';          % Compute inner product within fea_a
    if issparse(aa)
        aa = full(aa);
    end    
    D = bsxfun(@plus, aa, aa') - 2 * ab;  % Compute pairwise distances using broadcasting
    D(D < 0) = 0;  % Prevent negative values due to floating-point errors
    if bSqrt
        D = sqrt(D);  % Compute Euclidean distance
    end
    D = max(D, D');  % Ensure symmetry
else
    % If fea_b is not empty, compute Euclidean distance between fea_a and fea_b
    aa = sum(fea_a .* fea_a, 2);  % Compute squared sum for each sample in fea_a
    bb = sum(fea_b .* fea_b, 2);  % Compute squared sum for each sample in fea_b
    ab = fea_a * fea_b';          % Compute inner product between fea_a and fea_b
    if issparse(aa)
        aa = full(aa);
        bb = full(bb);
    end
    D = bsxfun(@plus, aa, bb') - 2 * ab;  % Compute pairwise distances using broadcasting
    D(D < 0) = 0;  % Prevent negative values due to floating-point errors
    if bSqrt
        D = sqrt(D);  % Compute Euclidean distance
    end
end

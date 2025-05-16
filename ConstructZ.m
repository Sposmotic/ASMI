%% Calculate intra-view similarity
function [Z] = ConstructZ(allSmp, anchor, k) 
% Input:
%   allSmp - Each row represents a sample (n×d)
%   anchor - Selected anchor points from allSmp (m×d)
%   k      - Number of neighbors
% Output:
%   Z      - Instance-to-anchor similarity matrix (n×m)

[n, ~] = size(allSmp); % Get total number of samples
[m, ~] = size(anchor); % Get number of anchor points

% Calculate squared Euclidean distance between all samples and anchors
Dist = EuDist2(allSmp, anchor, 0); 

% Set sigma value (for Gaussian kernel)
sigma = 1; % Alternative: 4*mean(mean(Dist)); Default sigma is 1

% Sort each row in ascending order and get top k neighbors
[~, idx] = sort(Dist, 2); 

idx = idx(:, 1:k); % Default self-connection (each sample is its own neighbor)

% Construct adjacency matrix G storing k neighbors for each sample
G = sparse(repmat([1:n]', [k, 1]), idx(:), ones(numel(idx), 1), n, m);

% Calculate Gaussian kernel weights
Z = (exp(-Dist/sigma)).*G; 
% Normalize each row
Z = bsxfun(@rdivide, Z, sum(Z, 2));

% Apply thresholding to similarity matrix to remove near-zero values
Z(Z < 1e-10) = 0;
end
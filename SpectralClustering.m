function Label = SpectralClustering(Z,M)
% Spectral Clustering
% Input:
%       Z        -instance-to-anchor similarity matrix
%       M  -number of clusters
% Output:
%       Label   -cluster labels by spectral clustering

A = Z*diag(1./sqrt(sum(Z,1)));
[B, Theta] = eigs(A'*A, M, 'LM'); % LM: Largest Magnitude
F = A*B*Theta^(-0.5);

Label = litekmeans((normcols(F'))',M,'Replicates',10,'MaxIter',20);
% Users can adopt 'litekmeans.m', which is a fast version.
Label = Label(:);
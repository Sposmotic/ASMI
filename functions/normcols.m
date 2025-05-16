function matout = normcols(matin)
% Normalizes each column of 'matin' to have unit L2 norm (Euclidean norm).
% Input:
%       matin   - A matrix
% Output:
%       matout  - A matrix with each column normalized to L2 norm = 1

% Compute L2 norms of columns (square root of sum of squares for each column)
l2norms = sqrt(sum(matin.^2,1));

% Replace zero norms with eps to prevent division by zero
l2norms(l2norms==0) = eps;

% Normalize each column by dividing by its L2 norm
matout = bsxfun(@rdivide,matin,l2norms);

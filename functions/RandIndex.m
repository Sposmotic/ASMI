function [AR,RI,MI,HI] = RandIndex(c1, c2)
%RANDINDEX - Calculate Rand indices to compare two partitions
%   ARI = RANDINDEX(c1, c2), where c1 and c2 are vectors representing class memberships,
%   returns the "Hubert & Arabie Adjusted Rand Index".
%   [AR, RI, MI, HI] = RANDINDEX(c1, c2) returns the Adjusted Rand Index, unadjusted Rand Index,
%   "Mirkin Index", and "Hubert Index".
%
%   See: L. Hubert and P. Arabie (1985) "Comparing Partitions", Journal of Classification 2:193-218.
%
%   (C) David Corney (2000)     D.Corney@cs.ucl.ac.uk

% Validate input arguments - both must be 1D vectors
if nargin < 2 || min(size(c1)) > 1 || min(size(c2)) > 1
   error('RandIndex: Requires two vector arguments')
   return
end

% Compute contingency matrix
C = Contingency(c1, c2); % Construct contingency matrix for c1 and c2

n = sum(sum(C));  % Total number of samples (sum of all elements in contingency matrix)
nis = sum(sum(C, 2).^2);  % Sum of squared row sums
njs = sum(sum(C, 1).^2);  % Sum of squared column sums

t1 = nchoosek(n, 2);  % Calculate total number of sample pairs (combinations of 2 from n elements)
t2 = sum(sum(C.^2));  % Sum of squared elements in contingency matrix
t3 = 0.5 * (nis + njs);  % Average of squared row and column sums

% Calculate expected index (for adjustment)
nc = (n * (n^2 + 1) - (n + 1) * nis - (n + 1) * njs + 2 * (nis * njs) / n) / (2 * (n - 1));

A = t1 + t2 - t3;  % Number of agreeing pairs (same partition)
D = -t2 + t3;  % Number of disagreeing pairs (different partitions)

% Calculate Adjusted Rand Index
if t1 == nc
   AR = 0;  % Avoid division by zero; if t1 = nc, define Rand = 0
else
   AR = (A - nc) / (t1 - nc);  % Adjusted Rand Index - Hubert & Arabie (1985)
end

RI = A / t1;  % Rand Index 1971 - Probability of agreement
MI = D / t1;  % Mirkin Index 1970 - Probability of disagreement
HI = (A - D) / t1;  % Hubert Index 1977 - Agreement minus disagreement probability

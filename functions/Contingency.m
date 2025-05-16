function Cont = Contingency(Mem1, Mem2)

% CONTINGENCY - Computes contingency matrix
%   Cont = CONTINGENCY(Mem1, Mem2) returns the contingency matrix between two partitions Mem1 and Mem2,
%   which represents the intersection of the two partitions.

% Validate input arguments - both must be 1D vectors
if nargin < 2 || min(size(Mem1)) > 1 || min(size(Mem2)) > 1
   error('Contingency: Requires two vector arguments')
   return
end

% Initialize contingency matrix with dimensions based on maximum values in Mem1 and Mem2
Cont = zeros(max(Mem1), max(Mem2));

% Compute contingency matrix by counting co-occurrences
for i = 1:length(Mem1)
   Cont(Mem1(i), Mem2(i)) = Cont(Mem1(i), Mem2(i)) + 1;
end

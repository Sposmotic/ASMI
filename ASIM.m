function Label = ASIM(dataViews, ind, k, m, M)
% ASIM - Anchor Selection strategy with Missing Information
%
% Inputs:
%   dataViews - Cell array containing data matrices for each view (n×d_v)
%   ind       - Indicator matrix showing which samples are available in each view
%   k         - Number of anchor points to select
%   m         - Number of nearest neighbors for similarity construction
%   M         - Number of clusters
%
% Output:
%   Label     - Cluster assignment vector (n×1)

% Get number of views from input data
[~, numViews] = size(dataViews);

% Step 1: Anchor selection for each view
anchors = cell(1, numViews);  % Initialize cell array to store anchors
for v = 1:numViews
    % Select k anchor points for current view using GetAnchor function
    anchors{v} = GetAnchor(dataViews, ind, k, v);
end

% Step 2: Construct similarity matrices for each view
Z = cell(1, numViews);  % Initialize cell array to store similarity matrices
for v = 1:numViews
    % Build similarity matrix between samples and anchors for current view
    Z{v} = ConstructZ(dataViews{v}, anchors{v}, m);
end

% Step 3: Combine similarity matrices from all views
combinedZ = Z{1};  % Initialize with first view's similarity matrix
for v = 2:numViews
    % Add similarity matrices from other views (simple view combination)
    combinedZ = combinedZ + Z{v};
end

% Step 4: Perform spectral clustering on the combined similarity matrix
% M specifies the number of clusters to find
Label = SpectralClustering(combinedZ, M);

end
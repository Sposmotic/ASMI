function [anchor] = GetAnchor(data, ind, k, viewIndex)
    % Input/Output specifications remain the same as original function
    
    [nSamples, nViews] = size(ind);
    assert(viewIndex <= nViews, 'Specified view index exceeds valid range');
    
    % --- Step 1: Count sample occurrences (vectorized operation) ---
    sampleCount = sum(ind, 2);  % Directly compute view occurrence count per sample
    
    % --- Step 2: Construct set Q{v} (using cell array to avoid dynamic expansion) ---
    Q = cell(nViews + 1, 1);
    for i = 1:nSamples
        idx = sampleCount(i) + 1;  % Map to A's index
        if isempty(Q{idx})
            Q{idx} = i;
        else
            Q{idx}(end+1) = i;  % Avoid horizontal concatenation, use vertical expansion
        end
    end
    
    % --- Step 3: Pre-allocate anchor matrix ---
    anchor = zeros(k, size(data{viewIndex}, 2));  % Pre-allocate k rows x feature dimension
    selectedCount = 0;
    
    % --- Step 4: Traverse A{v} from high to low, quickly select anchors ---
    for v = nViews + 1:-1:1
        if selectedCount >= k, break; end  % Early termination
        
        if isempty(Q{v}), continue; end
        
        % Extract candidate samples (existing in specified view)
        candidates = Q{v};
        validCandidates = candidates(ind(candidates, viewIndex) == 1);
        
        % Select according to global sorting order
        for i = 1:length(validCandidates)
            if selectedCount >= k, break; end
            selectedCount = selectedCount + 1;
            anchor(selectedCount, :) = data{viewIndex}(validCandidates(i), :);
        end
    end
    
    % --- Handle case when fewer than k anchors are found ---
    if selectedCount == 0
        warning('No suitable anchors found, returning empty matrix');
        anchor = [];
    elseif selectedCount < k
        anchor = anchor(1:selectedCount, :);  % Truncate pre-allocated space
    end
end
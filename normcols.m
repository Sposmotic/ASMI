function matout = normcols(matin)
% 对'matin'的每一列进行归一化，使得每列的L2范数为1。
% 输入:
%       matin   - 一个矩阵
% 输出:
%       matout  - 一个矩阵，每列的L2范数为1

% 计算每列的L2范数，即每列元素的平方和的平方根
l2norms = sqrt(sum(matin.^2,1));

% 如果某列的L2范数为0（即该列全为零），则将L2范数设置为一个很小的值（eps，防止除以零）
l2norms(l2norms==0) = eps;

% 将每列除以其对应的L2范数，实现列归一化
matout = bsxfun(@rdivide,matin,l2norms);

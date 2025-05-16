function Cont = Contingency(Mem1, Mem2)

% CONTINGENCY - 计算列联矩阵
%   Cont = CONTINGENCY(Mem1, Mem2) 返回两个划分 Mem1 和 Mem2 之间的列联矩阵，
%   该矩阵用于表示两个划分的交集。

% 检查输入参数的合法性，要求 Mem1 和 Mem2 为向量且维度为 1
if nargin < 2 || min(size(Mem1)) > 1 || min(size(Mem2)) > 1
   error('Contingency: Requires two vector arguments')
   return
end

% 初始化列联矩阵，大小为 Mem1 和 Mem2 中最大值的组合
Cont = zeros(max(Mem1), max(Mem2));

% 根据 Mem1 和 Mem2 中的对应元素计算列联矩阵
for i = 1:length(Mem1)
   Cont(Mem1(i), Mem2(i)) = Cont(Mem1(i), Mem2(i)) + 1;
end

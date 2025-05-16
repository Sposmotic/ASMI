function [AR,RI,MI,HI] = RandIndex(c1, c2)
%RANDINDEX - 计算 Rand 指数以比较两个划分
%   ARI = RANDINDEX(c1, c2)，其中 c1 和 c2 是表示类别成员的向量，
%   返回 "Hubert & Arabie 调整后的 Rand 指数"。
%   [AR, RI, MI, HI] = RANDINDEX(c1, c2) 返回调整后的 Rand 指数、未调整的 Rand 指数、
%   "Mirkin 指数" 和 "Hubert 指数"。
%
%   参见 L. Hubert 和 P. Arabie (1985) "Comparing Partitions"，《分类学期刊》2:193-218。
%
%   (C) David Corney (2000)     D.Corney@cs.ucl.ac.uk

% 检查输入参数的合法性，要求 c1 和 c2 为向量且维度为 1
if nargin < 2 || min(size(c1)) > 1 || min(size(c2)) > 1
   error('RandIndex: Requires two vector arguments')
   return
end

% 计算列联矩阵（Contingency Matrix）
C = Contingency(c1, c2); % 构造 c1 和 c2 的列联矩阵

n = sum(sum(C));  % 样本总数（列联矩阵中所有元素的总和）
nis = sum(sum(C, 2).^2);  % 每一行的元素和的平方之和
njs = sum(sum(C, 1).^2);  % 每一列的元素和的平方之和

t1 = nchoosek(n, 2);  % 计算总的样本对数（从 n 个元素中选择 2 个元素的组合数）
t2 = sum(sum(C.^2));  % 计算列联矩阵元素平方和
t3 = 0.5 * (nis + njs);  % 计算行和列元素平方和的平均值

% 计算期望指数（用于调整）
nc = (n * (n^2 + 1) - (n + 1) * nis - (n + 1) * njs + 2 * (nis * njs) / n) / (2 * (n - 1));

A = t1 + t2 - t3;  % 协议对数（相同划分的对数）
D = -t2 + t3;  % 不协议对数（不同划分的对数）

% 计算调整后的 Rand 指数
if t1 == nc
   AR = 0;  % 避免除以零的情况；如果 t1 = nc，定义 Rand = 0
else
   AR = (A - nc) / (t1 - nc);  % 调整后的 Rand 指数 - Hubert & Arabie (1985)
end

RI = A / t1;  % Rand 指数 1971 - 协议概率
MI = D / t1;  % Mirkin 指数 1970 - 不协议概率
HI = (A - D) / t1;  % Hubert 指数 1977 - 协议概率减去不协议概率

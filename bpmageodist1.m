function [ D ] = bpmageodist1(X,K)
%求利用最远距离求测地距离
%原理
%现求出点的邻域关系，然后根据邻域关系利用dijkstra算法确定点和非邻域点之间的最短路径
%输入
%矩阵X，每一列为一个点，
%K：邻域点的个数
%输出
%D,点与点之间的测地距离
%E，邻域关系图
%马丙鹏 2004-09-07
N=size(X,2);
Di = zeros(N*(K+1),1);      Dj = zeros(N*(K+1),1);       Ds = zeros(N*(K+1),1);
counter = 0;
for i=1:N
    % d = feval(d_func,i);
    d= l2_distance(X,X(:,i));
    [c,b] = sort(d.^(-1));
    Di(counter+(1:(K+1))) = i;
    Dj(counter+1) = i;
    Dj(counter+(2:(K+1))) = b((N-K+1):N);
    Ds(counter+1) = Inf;
    Ds(counter+(2:(K+1))) = c((N-K+1):N).^(-1);
    counter = counter+(K+1);
    %M(i)=mean(c(2:(K+1)));   %C-isomap
end
D = sparse(Di(1:counter), Dj(1:counter), Ds(1:counter));
% clear Di Dj Ds counter;
D=full(D);
for i=1:N
    for j=1:N
        if D(i,j)==0
            D(i,j)=100000;
        end
    end
end
D = min(D,D');    %% Make sure distance matrix is symmetric
D=sparse(D);
D = dijkstra(D,1:size(X,2));
D=full(D);
%D=D.^(-1);
% % for i=1:N
% %     D(i,i)=0;
% % end
function D = dijk(A,s,t)

error(nargchk(1,3,nargin));

[n,cA] = size(A);

if nargin < 2 | isempty(s), s = (1:n)'; else s = s(:); end
if nargin < 3 | isempty(t), t = (1:n)'; else t = t(:); end

if ~any(any(tril(A) ~= 0))			
   isAcyclic = 1;
elseif ~any(any(triu(A) ~= 0))	
   isAcyclic = 2;
else										
   isAcyclic = 0;
end

if n ~= cA
   error('A must be a square matrix');
elseif ~isAcyclic & any(any(A < 0))
   error('A must be non-negative');
elseif any(s < 1 | s > n)
   error(['''s'' must be an integer between 1 and ',num2str(n)]);
elseif any(t < 1 | t > n)
   error(['''t'' must be an integer between 1 and ',num2str(n)]);
end


A = A';		

D = zeros(length(s),length(t));
P = zeros(length(s),n);

for i = 1:length(s)
   j = s(i);
   
   Di = Inf*ones(n,1); Di(j) = 0;
   
   isLab = logical(zeros(length(t),1));
   if isAcyclic ==  1
      nLab = j - 1;
   elseif isAcyclic == 2
      nLab = n - j;
   else
      nLab = 0;
      UnLab = 1:n;
      isUnLab = logical(ones(n,1));
   end
   
   while nLab < n & ~all(isLab)
      if isAcyclic
         Dj = Di(j);
      else
         [Dj,jj] = min(Di(isUnLab));
         j = UnLab(jj);
         UnLab(jj) = [];
         isUnLab(j) = 0;
      end
      
      nLab = nLab + 1;
      if length(t) < n, isLab = isLab | (j == t); end
      
      [jA,kA,Aj] = find(A(:,j));
      Aj(isnan(Aj)) = 0;
            
      if isempty(Aj), Dk = Inf; else Dk = Dj + Aj; end
      
      P(i,jA(Dk < Di(jA))) = j;
      Di(jA) = min(Di(jA),Dk);
      
      if isAcyclic == 1			
         j = j + 1;
      elseif isAcyclic == 2
         j = j - 1;
      end
      
   end
   D(i,:) = Di(t)';
end


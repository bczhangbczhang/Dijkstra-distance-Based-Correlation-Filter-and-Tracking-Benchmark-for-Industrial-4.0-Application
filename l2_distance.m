function d = l2_distance(a,b,df)

if (nargin < 2)
   error('Not enough input arguments');
end

if (nargin < 3)
   df = 0;    
end

if (size(a,1) ~= size(b,1))
   error('A and B should be of same dimensionality');
end  

if ~(isreal(a)*isreal(b))
%    disp('Warning: running distance.m with imaginary numbers.  Results may be off.'); 
end

if (size(a,1) == 1)
  a = [a; zeros(1,size(a,2))]; 
  b = [b; zeros(1,size(b,2))]; 
end

aa=sum(a.*a); bb=sum(b.*b); ab=a'*b; 
d = sqrt(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab);
d = real(d); 

if (df==1)
  d = d.*(1-eye(size(d)));
end

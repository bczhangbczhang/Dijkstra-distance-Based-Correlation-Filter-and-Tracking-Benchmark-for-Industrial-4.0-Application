function H = fhog( I, binSize, nOrients, clip, crop )


if( nargin<2 ), binSize=8; end
if( nargin<3 ), nOrients=9; end
if( nargin<4 ), clip=.2; end
if( nargin<5 ), crop=0; end

softBin = -1; useHog = 2; b = binSize;

[M,O]=gradientMex('gradientMag',I,0,1);

H = gradientMex('gradientHist',M,O,binSize,nOrients,softBin,useHog,clip);

if( crop ), e=mod(size(I),b)<b/2; H=H(2:end-e(1),2:end-e(2),:); end

end

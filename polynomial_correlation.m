function kf = polynomial_correlation(xf, yf, a, b)

	xyf = xf .* conj(yf);
	xy = sum(real(ifft2(xyf)), 3);  

	kf = fft2((xy / numel(xf) + a) .^ b);

end


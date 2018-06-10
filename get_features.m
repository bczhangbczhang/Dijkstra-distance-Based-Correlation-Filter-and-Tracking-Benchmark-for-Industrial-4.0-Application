function x = get_features(im, features, cell_size, cos_window)

	if features.hog,
		x = double(fhog(single(im) / 255, cell_size, features.hog_orientations));
		x(:,:,end) = [];  
	end
	
	if features.gray,
		x = double(im) / 255;	
		x = x - mean(x(:));
	end
	

	if ~isempty(cos_window),
		x = bsxfun(@times, x, cos_window);
	end
	
end

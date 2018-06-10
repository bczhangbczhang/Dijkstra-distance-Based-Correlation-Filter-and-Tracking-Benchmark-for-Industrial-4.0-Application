function [positions, time] = tracker(video,video_path, img_files, pos, target_sz, ...
	padding, kernel, lambda, output_sigma_factor, interp_factor, cell_size, ...
	features, show_visualization)

	resize_image = (sqrt(prod(target_sz)) >= 100);  %diagonal size >= threshold
	if resize_image,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
	end

	window_sz = floor(target_sz * (1 + padding));

	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));

	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
	
	
	if show_visualization,  
		update_visualization = show_video(img_files, video_path, resize_image);
	end
	
	time = 0;  
	positions = zeros(numel(img_files), 2); 

	for frame = 1:numel(img_files),
		
		im = imread([video_path img_files{frame}]);
		if size(im,3) > 1,
			im = rgb2gray(im);
		end
		if resize_image,
			im = imresize(im, 0.5);
		end

		tic()

		if frame > 1,

			patch = get_subwindow(im, pos, window_sz);
			zf = fft2(get_features(patch, features, cell_size, cos_window));

			switch kernel.type
			case 'gaussian',
				kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
			case 'polynomial',
				kzf = polynomial_correlation(zf, model_xf, kernel.poly_a, kernel.poly_b);
			case 'linear',
				kzf = linear_correlation(zf, model_xf);
			end
			response = real(ifft2(model_alphaf .* kzf)); 
            a(frame)=max(response(:));

			[vert_delta, horiz_delta] = find(response == max(response(:)), 1);
			if vert_delta > size(zf,1) / 2,  
				vert_delta = vert_delta - size(zf,1);
			end
			if horiz_delta > size(zf,2) / 2,  
				horiz_delta = horiz_delta - size(zf,2);
			end
			pos = pos + cell_size * [vert_delta - 1, horiz_delta - 1];
        end
		patch = get_subwindow(im, pos, window_sz);
		xf = fft2(get_features(patch, features, cell_size, cos_window));


		switch kernel.type
		case 'gaussian',
			kf = gaussian_correlation(xf, xf, kernel.sigma);
		case 'polynomial',
			kf = polynomial_correlation(xf, xf, kernel.poly_a, kernel.poly_b);
		case 'linear',
			kf = linear_correlation(xf, xf);
		end
		alphaf = yf ./ (kf + lambda);   

		if frame == 1, 
			model_alphaf = alphaf;
			model_xf = xf;
		else
		
			model_alphaf = (1 - interp_factor) * model_alphaf + interp_factor * alphaf;
			model_xf = (1 - interp_factor) * model_xf + interp_factor * xf;
		end

		
		positions(frame,:) = pos;
		time = time + toc();

		
		if show_visualization,
			box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
			stop = update_visualization(frame, box);
			if stop, break, end  
			drawnow

		end
		
	end

	if resize_image,
		positions = positions * 2;
    end
    
end


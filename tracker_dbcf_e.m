function [positions, time] = tracker(video,video_path, img_files, pos, target_sz, ...
	padding, kernel, lambda, output_sigma_factor, interp_factor, cell_size, ...
	features, show_visualization,para)

	resize_image = (sqrt(prod(target_sz)) >= 100); 
	if resize_image
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
	end

	window_sz = floor(target_sz * (1 + padding));
	output_sigma = sqrt(prod(target_sz)) * output_sigma_factor / cell_size;
	yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
    model_alphaf=zeros(size(yf,1),size(yf,2),numel(img_files)+1);
    model_betaf=zeros(size(yf,1),size(yf,2),numel(img_files)+1);
    epsilon=zeros(1,numel(img_files)+1);
    delta=zeros(numel(img_files),1);
    delta(1)=para.delta1;
    num_f=para.num_f;
	cos_window = hann(size(yf,1)) * hann(size(yf,2))';	
	
	
	if show_visualization, 
		update_visualization = show_video(img_files, video_path, resize_image);
	end

	time = 0; 
	positions = zeros(numel(img_files), 4);  

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
            
			response = real(ifft2(model_alphaf(:,:,frame-1) .* kzf));  
            max_res(frame)=max(response(:));
			[vert_delta, horiz_delta] = find(response == max(response(:)), 1);
            a(frame)=max(response(:));
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
        interp_factor=(kf+lambda)./(kf+lambda+delta(frame));
		if frame == 1, 
			model_alphaf(:,:,frame) = alphaf;
            model_betaf(:,:,frame) = alphaf;
            epsilon_best=Inf;
            epsilon(frame)=Inf;
            ori_alphaf=alphaf;
			model_xf = xf;
        else
        
			model_alphaf(:,:,frame) = (1 - interp_factor) .* model_betaf(:,:,frame-1) + interp_factor.* alphaf;
			model_xf = (1 - 0.02) * model_xf + 0.02 * xf;
            mid1=reshape(model_alphaf(:,:,frame),1,[]);
            mid2=reshape(model_alphaf(:,:,frame-1),1,[]);
            epsilon(frame) =norm((mid1-mid2),2);
        end
            
            if epsilon(frame)<=epsilon_best&&delta(frame)<50
                delta(frame+1)=delta(frame);
                epsilon_best=epsilon(frame);
            else if epsilon(frame)>epsilon_best&&delta(frame)<50
                delta(frame+1)=delta(frame)*para.c;
                else 
                    delta(frame+1)=delta(frame);
                end
            end

            dis=0;
            sumweight=0;
            if frame<=4
                model_betaf(:,:,frame)=model_alphaf(:,:,frame);
            
            else if frame<=num_f&&frame>4
                 weight=zeros(frame-1,1);
                 diss=zeros(frame-1,1);
                 mid_a=reshape(model_alphaf(:,:,frame),1,[]);
                 mid_b=reshape(model_alphaf(:,:,1:frame-1),frame-1,[]);
                 diss=l2_distance(mid_b',mid_a');   
                 dis=sum(diss);
                                  
                 for kk=1:frame-1
                 weight(kk)=1-diss(kk)/dis;
                 sumweight=sumweight+weight(kk);
                 end
                 
                 for kk=1:frame-1
                 model_betaf(:,:,frame)=model_betaf(:,:,frame)+weight(kk)*model_alphaf(:,:,kk);
                 end
                 
                 if frame==num_f
                 sumsss=0;              
                 weight_weight=zeros(num_f,1);
                 for tt=1:frame
                     model_inter(tt)=norm(model_betaf(:,:,tt),1);
                 end

                 sumsss=sum(model_inter);
                 for tt=1:frame
                     weight_weight(tt)=norm(model_betaf(:,:,tt),1)./sumsss;
                 end
                 end
           else
                weight=zeros(num_f-1,1);
                mid_a=reshape(model_alphaf(:,:,frame),1,[]);
                mid_b=reshape(model_alphaf(:,:,frame-num_f:frame-1),num_f,[]);
                
                diss=l2_distance(mid_b',mid_a');                
                dis=sum(diss);

                for kk=frame-num_f:frame-1
                weight(kk-frame+num_f+1)=1-diss(kk-frame+num_f+1)/dis;
                sumweight=sumweight+weight_weight(kk-frame+num_f+1)*weight(kk-frame+num_f+1);
                end
                for kk=frame-num_f:frame-1
                weight(kk-frame+num_f+1)=weight_weight(kk-frame+num_f+1)*weight(kk-frame+num_f+1)/sumweight;
                model_betaf(:,:,frame)=model_betaf(:,:,frame)+weight(kk-frame+num_f+1)*model_alphaf(:,:,kk);
                end
                end
            end
        
		positions(frame,:) = [pos target_sz];
		time = time + toc();

		if show_visualization,
            figure(1)
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


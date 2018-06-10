
function [precision, fps] = run_tracker(video, kernel_type, feature_type, show_visualization, show_plots,k)

	base_path = '.\data';
	
	if nargin < 1, video = 'all'; end
	if nargin < 2, kernel_type = 'gaussian'; end
	if nargin < 3, feature_type = 'hog'; end    
	if nargin < 4, show_visualization = ~strcmp(video, 'all'); end
	if nargin < 5, show_plots = ~strcmp(video, 'all'); end

	kernel.type = kernel_type;
	
	features.gray = false;
	features.hog = false;
	
	padding =1.5;  
	lambda = 1e-4;  
	output_sigma_factor = 0.1; 
	
	switch feature_type
	case 'gray',
		interp_factor = 0.075;  

		kernel.sigma = 0.2;  
		
		kernel.poly_a = 1;  
		kernel.poly_b = 7;  
	
		features.gray = true;
		cell_size = 1;
		
	case 'hog',
		interp_factor = 0.02;
		
		kernel.sigma = 0.5;
		
		kernel.poly_a = 1;
		kernel.poly_b = 9;
		
		features.hog = true;
		features.hog_orientations = 9;
		cell_size = 4;
        para.c=1.55;
        para.delta1=5e-6;
        para.num_f=20;
		
	otherwise
		error('Unknown feature.')
	end

	assert(any(strcmp(kernel_type, {'linear', 'polynomial', 'gaussian'})), 'Unknown kernel.')

	switch video
	case 'choose',
		
		video = choose_video(base_path);
		if ~isempty(video),
			[precision, fps] = run_tracker(video, kernel_type, ...
				feature_type, show_visualization, show_plots);
			
			if nargout == 0,  
				clear precision
			end
		end
		
		
	case 'all',
		
		dirs = dir(base_path);
		videos = {dirs.name};
		videos(strcmp('.', videos) | strcmp('..', videos) | ...
			strcmp('anno', videos) | ~[dirs.isdir]) = [];

        tvideo_list=1:12;
        all_precisions = zeros(numel(tvideo_list),1); 
		all_fps = zeros(numel(tvideo_list),1);
           
		for k = 1:numel(tvideo_list),
			[all_precisions(k), all_fps(k)] = run_tracker(videos{tvideo_list(k)}, ...
				kernel_type, feature_type, show_visualization, show_plots,k);
        end,

        mean_precision = mean(all_precisions);
		fps = mean(all_fps);
        fprintf('\nAverage precision ((20)px):% 1.3f, Average FPS:% 4.2f\n\n', mean_precision, fps)
    
		
		if nargout > 0,
			precision = mean_precision;
		end
		
		
	case 'benchmark',
	
		seq = evalin('base', 'subS');
		target_sz = seq.init_rect(1,[4,3]);
		pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
		img_files = seq.s_frames;
		video_path = [];
		
        % use euclidean distance
		positions = tracker_dbcf_e(video_path, img_files, pos, target_sz, ...
			padding, kernel, lambda, output_sigma_factor, interp_factor, ...
			cell_size, features, show_visualization, para);
        
        % use  Dijkstra-distance       
        % [positions, time] = tracker_dbcf_g(video,video_path, img_files, pos, target_sz, ...
        % padding, kernel, lambda, output_sigma_factor, interp_factor, ...
        % cell_size, features, show_visualization,para);
        
        % use  KCF       
        % [positions, time] = tracker(video,video_path, img_files, pos, target_sz, ...
        % padding, kernel, lambda, output_sigma_factor, interp_factor, ...
        % cell_size, features, show_visualization);
        
		rects = [positions(:,2) - target_sz(2)/2, positions(:,1) - target_sz(1)/2];
		rects(:,3) = target_sz(2);
		rects(:,4) = target_sz(1);
		res.type = 'rect';u
		res.res = rects;
		assignin('base', 'res', res);
		

	otherwise

		[img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video);
        % use euclidean distance
		[positions, time] = tracker_dbcf_e(video,video_path, img_files, pos, target_sz, ...
			padding, kernel, lambda, output_sigma_factor, interp_factor, ...
			cell_size, features, show_visualization,para);
        
        % use  Dijkstra-distance       
        %[positions, time] = tracker_dbcf_g(video,video_path, img_files, pos, target_sz, ...
        %padding, kernel, lambda, output_sigma_factor, interp_factor, ...
        %cell_size, features, show_visualization,para);
        
        % use  KCF       
        % [positions, time] = tracker(video,video_path, img_files, pos, target_sz, ...
        % padding, kernel, lambda, output_sigma_factor, interp_factor, ...
        % cell_size, features, show_visualization);
        

		precisions = precision_plot(positions, ground_truth, video, show_plots,video);
        precisions=precisions(20);
		fps = numel(img_files) / time;

        fprintf('%12s - Precision (average(20)px):% 1.3f, FPS:% 4.2f\n', video, precisions, fps)

		if nargout > 0,		
			precision = precisions;
        end

	end
end

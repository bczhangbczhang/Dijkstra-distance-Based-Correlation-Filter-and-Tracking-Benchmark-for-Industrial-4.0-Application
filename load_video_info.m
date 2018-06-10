function [img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video)

	if numel(video) >= 2 && video(end-1) == '.' && ~isnan(str2double(video(end))),
		suffix = video(end-1:end); 
		video = video(1:end-2);  
	else
		suffix = '';
	end

	
	if base_path(end) ~= '/' && base_path(end) ~= '\',
		base_path(end+1) = '/';
	end
	video_path = [base_path video '/'];

	
	filename = [video_path 'groundtruth_rect' suffix '.txt'];
	f = fopen(filename);
	assert(f ~= -1, ['No initial position or ground truth to load ("' filename '").'])
	
	
	try
		ground_truth = textscan(f, '%f,%f,%f,%f', 'ReturnOnError',false);  
	catch  %#ok, try different format (no commas)
		frewind(f);
		ground_truth = textscan(f, '%f %f %f %f');  
	end
	ground_truth = cat(2, ground_truth{:});
	fclose(f);
	
	
	target_sz = [ground_truth(1,4), ground_truth(1,3)];
	pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);
	
	if size(ground_truth,1) == 1,
		
		ground_truth = [];
	else
		
		ground_truth = ground_truth(:,[2,1]) + ground_truth(:,[4,3]) / 2;
	end
	
	
	
	video_path = [video_path 'img/'];
	
	frames = {'David', 300, 770;
			  'Football1', 1, 74;
			  'Freeman3', 1, 460;
			  'Freeman4', 1, 283
               'Tiger1', 6, 354
              };
	
	idx = find(strcmpi(video, frames(:,1)));
	
	if isempty(idx),
		
		img_files = dir([video_path '*.png']);
		if isempty(img_files),
			img_files = dir([video_path '*.bmp']);
			assert(~isempty(img_files), 'No image files to load.')
		end
		img_files = sort({img_files.name});
	else
		
		if exist(sprintf('%s%04i.png', video_path, frames{idx,2}), 'file'),
			img_files = num2str((frames{idx,2} : frames{idx,3})', '%04i.png');
			
		elseif exist(sprintf('%s%04i.jpg', video_path, frames{idx,2}), 'file'),
			img_files = num2str((frames{idx,2} : frames{idx,3})', '%04i.jpg');
			
		else
			error('No image files to load.')
		end
		
		img_files = cellstr(img_files);
	end
	
end


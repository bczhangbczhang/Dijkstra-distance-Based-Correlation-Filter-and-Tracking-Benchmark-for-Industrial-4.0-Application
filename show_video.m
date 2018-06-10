function update_visualization_func = show_video(img_files, video_path, resize_image)

	num_frames = numel(img_files);
	boxes = cell(num_frames,1);

	[fig_h, axes_h, unused, scroll] = videofig(num_frames, @redraw, [], [], @on_key_press);  %#ok, unused outputs
	set(fig_h, 'Number','off', 'Name', ['Tracker - ' video_path])
	axis off;
	
	im_h = [];
	rect_h = [];
	
	update_visualization_func = @update_visualization;
	stop_tracker = false;
	

	function stop = update_visualization(frame, box)
		boxes{frame} = box;
		scroll(frame);
		stop = stop_tracker;
	end

	function redraw(frame)

		im = imread([video_path img_files{frame}]);
		if size(im,3) > 1,
			im = rgb2gray(im);
		end
		if resize_image,
			im = imresize(im, 0.5);
		end
		
		if isempty(im_h),  
			im_h = imshow(im, 'Border','tight', 'InitialMag',200, 'Parent',axes_h);
		else 
			set(im_h, 'CData', im)
		end
		
		if isempty(rect_h),  
			rect_h = rectangle('Position',[0,0,1,1], 'EdgeColor','g', 'Parent',axes_h);
		end
		if ~isempty(boxes{frame}),
			set(rect_h, 'Visible', 'on', 'Position', boxes{frame});
		else
			set(rect_h, 'Visible', 'off');
		end
	end

	function on_key_press(key)
		if strcmp(key, 'escape'),  
			stop_tracker = true;
		end
	end

end


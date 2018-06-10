function [fig_handle, axes_handle, scroll_bar_handles, scroll_func] = ...
	videofig(num_frames, redraw_func, play_fps, big_scroll, ...
	key_func, varargin)

	if nargin < 3 || isempty(play_fps), play_fps = 25; end  
	if nargin < 4 || isempty(big_scroll), big_scroll = 30; end 
	if nargin < 5, key_func = []; end
	

	check_int_scalar(num_frames);
	check_callback(redraw_func);
	check_int_scalar(play_fps);
	check_int_scalar(big_scroll);
	check_callback(key_func);

	click = 0;
	f = 1;  

	fig_handle = figure('Color',[.3 .3 .3], 'MenuBar','none', 'Units','norm', ...
		'WindowButtonDownFcn',@button_down, 'WindowButtonUpFcn',@button_up, ...
		'WindowButtonMotionFcn', @on_click, 'KeyPressFcn', @key_press, ...
		'Interruptible','off', 'BusyAction','cancel', varargin{:});
	

	scroll_axes_handle = axes('Parent',fig_handle, 'Position',[0 0 1 0.03], ...
		'Visible','off', 'Units', 'normalized');
	axis([0 1 0 1]);
	axis off
	

	scroll_bar_width = max(1 / num_frames, 0.01);
	scroll_handle = patch([0 1 1 0] * scroll_bar_width, [0 0 1 1], [.8 .8 .8], ...
		'Parent',scroll_axes_handle, 'EdgeColor','none', 'ButtonDownFcn', @on_click);
	

	play_timer = timer('TimerFcn',@play_timer_callback, 'ExecutionMode','fixedRate');
	

	axes_handle = axes('Position',[0 0.03 1 0.97]);
	

	scroll_bar_handles = [scroll_axes_handle; scroll_handle];
	scroll_func = @scroll;
	
	
	
	function key_press(src, event)  
		switch event.Key,  
		case 'leftarrow',
			scroll(f - 1);
		case 'rightarrow',
			scroll(f + 1);
		case 'pageup',
			if f - big_scroll < 1,  
				scroll(1);
			else
				scroll(f - big_scroll);
			end
		case 'pagedown',
			if f + big_scroll > num_frames,  
				scroll(num_frames);
			else
				scroll(f + big_scroll);
			end
		case 'home',
			scroll(1);
		case 'end',
			scroll(num_frames);
		case 'return',
			play(1/play_fps)
		case 'backspace',
			play(5/play_fps)
		otherwise,
			if ~isempty(key_func),
				key_func(event.Key);  
			end
		end
	end
	
	
	function button_down(src, event)  
		set(src,'Units','norm')
		click_pos = get(src, 'CurrentPoint');
		if click_pos(2) <= 0.03, 
			click = 1;
			on_click([],[]);
		end
	end

	function button_up(src, event) 
		click = 0;
	end

	function on_click(src, event)  
		if click == 0, return; end
		
		set(fig_handle, 'Units', 'normalized');
		click_point = get(fig_handle, 'CurrentPoint');
		set(fig_handle, 'Units', 'pixels');
		x = click_point(1);
		
	
		new_f = floor(1 + x * num_frames);
		
		if new_f < 1 || new_f > num_frames, return; end 
		
		if new_f ~= f, 
			scroll(new_f);
		end
	end

	function play(period)
		
		if strcmp(get(play_timer,'Running'), 'off'),
			set(play_timer, 'Period', period);
			start(play_timer);
		else
			stop(play_timer);
		end
	end
	function play_timer_callback(src, event)  
		
		if f < num_frames,
			scroll(f + 1);
		elseif strcmp(get(play_timer,'Running'), 'on'),
			stop(play_timer);  
		end
	end

	function scroll(new_f)
		if nargin == 1, 
			if new_f < 1 || new_f > num_frames,
				return
			end
			f = new_f;
		end
		
		
		scroll_x = (f - 1) / num_frames;
		
		
		set(scroll_handle, 'XData', scroll_x + [0 1 1 0] * scroll_bar_width);
		
		
		set(fig_handle, 'CurrentAxes', axes_handle);
		redraw_func(f);
		
		
		pause(0.001)
	end
	

	function check_int_scalar(a)
		assert(isnumeric(a) && isscalar(a) && isfinite(a) && a == round(a), ...
			[upper(inputname(1)) ' must be a scalar integer number.']);
	end
	function check_callback(a)
		assert(isempty(a) || strcmp(class(a), 'function_handle'), ...
			[upper(inputname(1)) ' must be a valid function handle.'])
	end
end


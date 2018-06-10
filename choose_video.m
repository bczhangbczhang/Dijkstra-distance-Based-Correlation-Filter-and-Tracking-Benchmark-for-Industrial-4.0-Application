function video_name = choose_video(base_path)

	if ispc(), base_path = strrep(base_path, '\', '/'); end
	if base_path(end) ~= '/', base_path(end+1) = '/'; end

	contents = dir(base_path);
   
	names = {};
	for k = 1:numel(contents),
		name = contents(k).name;
		if isdir([base_path name]) && ~any(strcmp(name, {'.', '..'})),
			names{end+1} = name;  
		end
	end
	
	
	if isempty(names), video_name = []; return; end
	
	
	choice = listdlg('ListString',names, 'Name','Choose video', 'SelectionMode','single');
	
	if isempty(choice),  
		video_name = [];
	else
		video_name = names{choice};
	end
	
end


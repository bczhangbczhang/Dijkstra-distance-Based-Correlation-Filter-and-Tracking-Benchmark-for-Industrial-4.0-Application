function precisions = precision_plot(positions, ground_truth, title, show,video)
	
	max_threshold = 50; 
	precisions = zeros(max_threshold, 1);
	
	if size(positions,1) ~= size(ground_truth,1),

		n = min(size(positions,1), size(ground_truth,1));
		positions(n+1:end,:) = [];
		ground_truth(n+1:end,:) = [];
	end
	
	
	distances = sqrt((positions(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions(:,2) - ground_truth(:,2)).^2);
	distances(isnan(distances)) = [];

	
	for p = 1:max_threshold,
		precisions(p) = nnz(distances <= p) / numel(distances);
	end
	
	
	if show == 1,
        figure(8)
		plot(precisions, 'k-', 'LineWidth',2)
		xlabel('Threshold'), ylabel('Precision')
	end
	
end


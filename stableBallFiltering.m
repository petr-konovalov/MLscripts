function est = stableBallFiltering(BPosHX, BPosHY, depth, alpha)
	global curTime oldTime;
	persistent X_est Y_est;
	if nargin <= 2
		depth = 5;
	end
	if nargin <= 3
		alpha = 0.9;
	end
	histLen = min(numel(BPosHX), numel(BPosHY));
	depth = min(depth, histLen);
	BPosHX = BPosHX(histLen-depth+1:histLen);
	BPosHY = BPosHY(histLen-depth+1:histLen);	
	X_med = median(BPosHX);
	Y_med = median(BPosHY);
	if isempty(X_est) || isempty(Y_est) || curTime - oldTime > 1 || norm([X_est, Y_est]-[X_med, Y_med]) > 200
		X_est = X_med;
		Y_est = Y_med;
	else
		X_est = X_est * alpha + X_med*(1-alpha);
		Y_est = Y_est * alpha + Y_med*(1-alpha);
	end
	est = [X_est, Y_est];
end

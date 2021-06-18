function [X_est, Y_est] = stableBallFiltering(BPosHX, BPosHY, depth, alpha)
	global curTime oldTime;
	persistent X_est Y_est;
	if nargin <= 2
		depth = 5;
	end
	if naring <= 3
		alpha = 0.9;
	end
	histLen = min(numel(BPosHX), numel(BPosHY));
	depth = min(depth, histLen);
	BPosHX = BPosHX(histLen-depth+1:histLen);
	BPosHY = BPosHY(histLen-depth+1:histLen);	
	if isempty(X_est) || isempty(Y_est) || curTime - oldTime > 1
		X_est = median(BPosHX);
		Y_est = median(BPosHY);
	else
		X_est = X_est * alpha + median(BPosHX)*(1-alpha);
		Y_est = Y_est * alpha + median(BPosHY)*(1-alpha);
	end
end

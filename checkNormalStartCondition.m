function res = checkNormalStartCondition(sourcePnt, ballPos, vicinity, ballOutsideFramesThreshold)
	persistent ballOutsideFrames;
	if isempty(ballOutsideFrames)
		ballOutsideFrames = 0;
	end
	if nargin <= 2
		vicinity = 200;	
	end
	if nargin <= 3
		ballOutsideFramesThreshold = 5;	
	end
	if norm(ballPos - sourcePnt) > vicinity
		ballOutsideFrames = ballOutsideFrames + 1;
	else
		ballOutsideFrames = 0;
	end
	res = ballOutsideFrames >= ballOutsideFramesThreshold;
end

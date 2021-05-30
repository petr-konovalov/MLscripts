function newSpeed = changeSpeed(agent, oldTime, curTime, curSpeed, goalSpeed, maxAcc)
	if nargin <= 5
		maxAcc = 100;
	end
	dSpeed = goalSpeed - curSpeed;
	ndSpeed = norm(dSpeed);
	maxdSpeed = (curTime - oldTime) * maxAcc;
	if ndSpeed > maxdSpeed
		dSpeed = dSpeed / ndSpeed * maxdSpeed;
	end
	newSpeed = curSpeed + dSpeed;
end

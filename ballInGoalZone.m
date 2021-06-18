function res = ballInGoalZone(G, V, goalSizes, ball)
	res = pntInZone(ball, getGoalZone(G, V, goalSizes));
end

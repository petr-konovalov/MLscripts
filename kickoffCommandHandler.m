function ruls = kickoffCommandHandler(sd, coms, obstacles, kickoffTeam, ball, goals, Vs, field, BState, BPosHX, BPosHY)
	ball.z = [0, 0];
	ball.x = 0;
	ball.y = 0;
	if sd == kickoffTeam
		%active start
		%ruls = gameModel(sd, coms, obstacles, ball, goals, Vs, field, BState, BPosHX, BPosHY, 1);
		ruls = freeKick(coms(sd, :), ball, getKickPoint(sd, ball, coms, goals(3-sd, :), Vs(3-sd, :)), BPosHX, BPosHY, obstacles);
	else
		%passive start
		ruls = gameModel(sd, coms, obstacles, ball, goals, Vs, field, BState, BPosHX, BPosHY, 2);
	end
end

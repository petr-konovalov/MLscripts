function sd = getOurCommandSd(leftTeamIsBlue, ourCommandIsBlue)
	sd = 0;
	if leftTeamIsBlue == ourCommandIsBlue
		sd = 1;
	else
		sd = 2;
	end
end

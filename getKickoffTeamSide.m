function ks = getKickoffTeamSide(kickofTeamColorIndex, leftTeamIsBlue)
	blueColorIndex = 1;
	yellowColorIndex = 2;
	leftSideIndex = 1;
	rightSideIndex = 2;
	switch kickofTeamColorIndex
		case blueColorIndex
			if leftTeamIsBlue
				ks = leftSideIndex;
			else
				ks = rightSideIndex;
			end
		case yellowColorIndex
			if leftTeamIsBlue
				ks = rightSideIndex;
			else
				ks = leftSideIndex;
			end
	end
end

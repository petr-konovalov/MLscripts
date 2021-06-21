function copyRulsToRobotsRul(ruls1, ruls2, cId)
	global RP;
	global yellowIsActive;
	global blueIsActive;
	global leftTeamIsBlue;
	if yellowIsActive
		for k = 1: 6
			if leftTeamIsBlue
				RP.Yellow(cId(k)).rul = ruls2(k);
			else
				RP.Yellow(cId(k)).rul = ruls1(k);
			end
		end
	else
		for k = 1: 6
			RP.Yellow(k).rul = Crul(0, 0, 0, 0, 0);
		end
	end

	if blueIsActive
		for k = 1: 6
			if leftTeamIsBlue
				RP.Blue(cId(k+6)).rul = ruls1(k);
			else
				RP.Blue(cId(k+6)).rul = ruls2(k);
			end
		end
	else
		for k = 1: 6
			RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);
		end
	end
end

function copyRulsToRobotsRul(ruls1, ruls2)
	global RP;
	global yellowIsActive;
	global blueIsActive;
	global leftCommandIsBlue;
	if yellowIsActive
		for k = 1: 6
			if leftCommandIsBlue
				RP.Yellow(k).rul = ruls2(k);
			else
				RP.Yellow(k).rul = ruls1(k);
			end
		end
	else
		for k = 1: 6
			RP.Yellow(k).rul = Crul(0, 0, 0, 0, 0);
		end
	end

	if blueIsActive
		for k = 1: 6
			if leftCommandIsBlue
				RP.Blue(k).rul = ruls1(k);
			else
				RP.Blue(k).rul = ruls2(k);
			end
		end
	else
		for k = 1: 6
			RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);
		end
	end
end

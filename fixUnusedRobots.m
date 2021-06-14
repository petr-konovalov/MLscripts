global  curTime oldTime RP;

pntsb = [
	5800, -4350;
	5400, -4350;
	5000, -4350;
	4800, -4350;
	4400, -4350;
	4000, -4350;
	3600, -4350;
	3200, -4350;
	2800, -4350;
	2400, -4350;
	2000, -4350
];
for k = 1: numel(pntsb)/2
	RP.Blue(k).rul = MoveToWithFastBuildPath(RP.Blue(k), pntsb(k, :), 10, obstacles, 30, 0);
	rotRul = RotateToLinear(RP.Blue(k), RP.Blue(k).z+[0, 100], 3, 10, 0.02);
	RP.Blue(k).rul.SpeedR = rotRul.SpeedR;
end
pntsy = [
	-5800, -4350;
	-5400, -4350;
	-5000, -4350;
	-4800, -4350;
	-4400, -4350;
	-4000, -4350;
	-3600, -4350;
	-3200, -4350;
	-2800, -4350;
	-2400, -4350;
	-2000, -4350
];
for k = 1: numel(pntsy)/2
	RP.Yellow(k).rul = MoveToWithFastBuildPath(RP.Yellow(k), pntsy(k, :), 10, obstacles, 30, 0);
	rotRul = RotateToLinear(RP.Yellow(k), RP.Yellow(k).z+[0, 100], 3, 10, 0.02);
	RP.Yellow(k).rul.SpeedR = rotRul.SpeedR;
end

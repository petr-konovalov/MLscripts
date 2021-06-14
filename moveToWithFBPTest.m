global phase curTime oldTime RP;
if isempty(phase) || curTime - oldTime > 5
	phase = 0;
end
phase = phase + (curTime - oldTime)/10*pi;
%disp(phase);
cphase = cos(phase);
sphase = sin(phase);
phaseMat = [cphase, -sphase; sphase, cphase];
aim = -[4700, -3700];
aim2 = -[4500, -3000];
RP.Blue(1).rul = MoveToWithFastBuildPath(RP.Blue(1), aim2, 50, obstacles);
RP.Blue(2).rul = MoveToWithFastBuildPath(RP.Blue(2), aim, 50, obstacles);
pntsb = [
	-2000, 200;
	-1600, -600;
	-1200, 1000;
	-800, -1200;
	-400, 400;
	0, 700;
	400, 700;
	800, -300;
	1200, 400;
	1600, 600;
	2000, -400
]*1.9;
for k = 3: numel(pntsb)/2
	RP.Blue(k).rul = MoveToWithFastBuildPath(RP.Blue(k), pntsb(k, :) * phaseMat', 50, obstacles);
end
pntsy = [
	-1800, -800;
	-1400, 400;
	-1000, 500;
	-600, -800;
	-200, 0;
	200, 200;
	600, 100;
	1000, 400;
	1400, -600;
	1800, 200;
	2200, -600
]*1.9;
for k = 1: numel(pntsy)/2
	RP.Yellow(k).rul = MoveToWithFastBuildPath(RP.Yellow(k), pntsy(k, :) * phaseMat', 50, obstacles);
end

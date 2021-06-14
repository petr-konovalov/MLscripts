global gameStatus;
global BPosHX; %history of ball coordinate X
global BPosHY; %history of ball coordinate Y
global ballFastMoving;
global ballSaveDir;
global oldTime;
global curTime;
global obstacles;

[BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
RP.Ball.z = BPEstim;
RP.Ball.x = BPEstim(1);
RP.Ball.y = BPEstim(2);
%disp(BPEstim);

if norm(RP.Blue(1).z - RP.Ball.z) < 80
	RP.Blue(1).rul = Crul(0, 0, 0, 0, 0);
else
	RP.Blue(1).rul = attack(RP.Blue(1), RP.Ball, [0, 0]);
	RP.Blue(1).rul.KickForward = 0;
	RP.Blue(1).rul.KickUp = 0;
	RP.Blue(1).rul.AutoKick = 0;
end
%RP.Blue(1).rul = Crul(0, 0, 0, 0, 0);
RP.Blue(1).rul.EnableSpinner = 1;
RP.Blue(1).rul.SpinnerSpeed = 1000000000;


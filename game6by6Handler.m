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

cId = [1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6];

if leftCommandIsBlue
	coms = [RP.Blue(cId(7)), RP.Blue(cId(8)),  RP.Blue(cId(9)), RP.Blue(cId(10)), RP.Blue(cId(11)),  RP.Blue(cId(12)); RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)), RP.Yellow(cId(4)), RP.Yellow(cId(5)), RP.Yellow(cId(6))];
else
	coms = [RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)), RP.Yellow(cId(4)), RP.Yellow(cId(5)), RP.Yellow(cId(6)); RP.Blue(cId(7)), RP.Blue(cId(8)),  RP.Blue(cId(9)), RP.Blue(cId(10)), RP.Blue(cId(11)),  RP.Blue(cId(12))];
end

obsts = obstacles([cId(1:6), cId(7:12)+BCnt*ones(1, 6)], :);
G1 = [-4500 0];
G2 = [4500 0];
P1 = [-4500 -3000];
P2 = [4500 3000]; 
Left = min(P1(1), P2(1));
Right = max(P1(1), P2(1));
Up = max(P1(2), P2(2));
Down = min(P1(2), P2(2));
center = [(Left + Right) * 0.5, (Up + Down) * 0.5];
centerRadius = 500;
%disp(BPEstim);
field = [Left Down; Right Up];
height = abs(Left - Right);
width = abs(Up - Down);
V1 = [1, 0];
V2 = [-1, 0];

if isempty(gameStatus)
	gameStatus = 0;
end

ruls1 = [Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0)];
ruls2 = [Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0)];

%RefCommandForTeam == 1 -- for blue team
%RefCommandForTeam == 2 -- for yellow team
%RefCommandForTeam == 0 -- for all teams

haltCommand = 0;
stopCommand = 1;
forceStartCommand = 2;
timeoutCommand = 3;
endGameCommand = 4;
kickoffCommand = 5;
normalStartCommand = 6;
penaltyCommand = 7;
directKickCommand = 9;
indirectKickCommand = 10;
ballPlacementCommand = 11;

switch RefState
	case haltCommand
		[ruls1, ruls2] = haltCommandHandler();
	case stopCommand
		[ruls1, ruls2] = stopCommandHandler();
	case forceStartCommand
		[ruls1, ruls2] = forceStartCommandHandler();
	case timeoutCommand
		[ruls1, ruls2] = timeoutCommandHandler();
	case endGameCommand
		[ruls1, ruls2] = endGameCommandHandler();
	case normalStartCommand
		[ruls1, ruls2] = normalStartCommandHandler();
	case penaltyCommand
		[ruls1, ruls2] = penaltyCommandHandler();
	case directKickCommand
		[ruls1, ruls2] = directCommandHandler();
	case indirectKickCommand
		[ruls1, ruls2] = indirectCommandHandler();
	case ballPlacementCommand
		[ruls1, ruls2] = ballPlacementCommandHandler();
end

copyRulsToRobotsRul(ruls1, ruls2);




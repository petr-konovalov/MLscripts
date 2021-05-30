global gameStatus;
global BPosHX; %history of ball coordinate X
global BPosHY; %history of ball coordinate Y
global ballFastMoving;
global ballSaveDir;
global oldTime;
global curTime;

[BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
RP.Ball.z = BPEstim;
RP.Ball.x = BPEstim(1);
RP.Ball.y = BPEstim(2);
%disp(BPEstim);

cId = [1, 2, 3, 1, 2, 3];
coms = [RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)); RP.Blue(cId(4)), RP.Blue(cId(5)),  RP.Blue(cId(6))];
obsts = obstacles(cId, :);
G1 = [-6000 0];
G2 = [6000 0];
P1 = [-6000 -4500];
P2 = [6000 4500]; 
Left = min(P1(1), P2(1));
Right = max(P1(1), P2(1));
Up = max(P1(2), P2(2));
Down = min(P1(2), P2(2));
center = [(Left + Right) * 0.5, (Up + Down) * 0.5];
%disp(BPEstim);
centerRadius = 300;
field = [Left Down; Right Up];
height = abs(Left - Right);
width = abs(Up - Down);
V1 = [1, 0];
V2 = [-1, 0];

if isempty(gameStatus)
	gameStatus = 0;
end

ruls1 = [Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0)];
ruls2 = [Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0); Crul(0, 0, 0, 0, 0)];
switch gameStatus
	case 1 %Start game. First team is playing
	    [ruls1, ruls2] = startGame(center, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, centerRadius);
	case 2 %Start game. Second team is playing
	    [ruls1, ruls2] = startGame(center, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, centerRadius);
	case 3 %normal game
	    ruls1 = gameModel(1, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
	    ruls2 = gameModel(2, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
	case 4 %stop game
	    ruls1 = gameModel(1, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 4); 
	    ruls2 = gameModel(2, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 4); 
	case 5 %move ball to center
	    ruls = MoveBallToCenter(RP.Blue(cId([1, 2, 4, 5])), RP.Ball, center, centerRadius);
	    ruls1(1) = ruls(1);
	    ruls1(2) = ruls(2);
	    ruls2(1) = ruls(3);
	    ruls2(2) = ruls(4);
end

RP.Yellow(cId(1)).rul = ruls1(1);
RP.Yellow(cId(2)).rul = ruls1(2);
RP.Yellow(cId(3)).rul = ruls1(3);

RP.Blue(cId(4)).rul = ruls2(1);
RP.Blue(cId(5)).rul = ruls2(2);
RP.Blue(cId(6)).rul = ruls2(3);

if gameStatus == 0 %reset configuration
	Pnt = zeros(6, 2);
	Pnt(1, :) = G1 + V1 * 500 - [V1(2), -V1(1)] * width * 0.35;
	Pnt(2, :) = G1 + V1 * 500 + [V1(2), -V1(1)] * width * 0.35;
	Pnt(3, :) = G1 + V1 * 500;
	Pnt(4, :) = G2 + V2 * 500 - [V2(2), -V2(1)] * width * 0.35;
	Pnt(5, :) = G2 + V2 * 500 + [V2(2), -V2(1)] * width * 0.35;
	Pnt(6, :) = G2 + V2 * 500;
	for k = 1: 3
	    RP.Blue(cId(k)).rul = MoveToWithFastBuildPath(RP.Blue(cId(k)), Pnt(k+3, :), 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	    RP.Yellow(cId(k+3)).rul = MoveToWithFastBuildPath(RP.Yellow(cId(k+3)), Pnt(k, :), 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	end
end


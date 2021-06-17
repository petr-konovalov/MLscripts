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

switch gameStatus
	case 0
		[ruls1, ruls2] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);
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
	    ruls = MoveBallToCenter([RP.Yellow(cId([1, 2, 3, 4, 5])), RP.Blue(cId([7, 8, 9, 10, 11]))], RP.Ball, center, 50, obstacles);
	    ruls1(1) = ruls(1);
	    ruls1(2) = ruls(2);
	    ruls1(3) = ruls(3);
	    ruls1(4) = ruls(4);
	    ruls1(5) = ruls(5);
	    ruls2(1) = ruls(6);
	    ruls2(2) = ruls(7);
	    ruls2(3) = ruls(8);
	    ruls2(4) = ruls(9);
	    ruls2(5) = ruls(10);
end

copyRulsToRobotsRul(ruls1, ruls2);




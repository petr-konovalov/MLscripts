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
coms = [RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)), RP.Yellow(cId(4)), RP.Yellow(cId(5)), RP.Yellow(cId(6)); RP.Blue(cId(7)), RP.Blue(cId(8)),  RP.Blue(cId(9)), RP.Blue(cId(10)), RP.Blue(cId(11)),  RP.Blue(cId(12))];
obsts = obstacles([cId(1:6), cId(7:12)+BCnt*ones(1, 6)], :);
G1 = [-6000 0];
G2 = [6000 0];
P1 = [-6000 -4500];
P2 = [6000 4500]; 
Left = min(P1(1), P2(1));
Right = max(P1(1), P2(1));
Up = max(P1(2), P2(2));
Down = min(P1(2), P2(2));
center = [(Left + Right) * 0.5, (Up + Down) * 0.5];
centerRadius = 500;
%disp(BPEstim);`
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
%disp(gameStatus);
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

global yellowIsActive;
if yellowIsActive
	RP.Yellow(cId(1)).rul = ruls1(1);
	RP.Yellow(cId(2)).rul = ruls1(2);
	RP.Yellow(cId(3)).rul = ruls1(3);
	RP.Yellow(cId(4)).rul = ruls1(4);
	RP.Yellow(cId(5)).rul = ruls1(5);
	RP.Yellow(cId(6)).rul = ruls1(6);
else
	RP.Yellow(cId(1)).rul = Crul(0, 0, 0, 0, 0);
	RP.Yellow(cId(2)).rul = Crul(0, 0, 0, 0, 0);
	RP.Yellow(cId(3)).rul = Crul(0, 0, 0, 0, 0);
	RP.Yellow(cId(4)).rul = Crul(0, 0, 0, 0, 0);
	RP.Yellow(cId(5)).rul = Crul(0, 0, 0, 0, 0);
	RP.Yellow(cId(6)).rul = Crul(0, 0, 0, 0, 0);
end

RP.Blue(cId( 7)).rul = ruls2(1);
RP.Blue(cId( 8)).rul = ruls2(2);
RP.Blue(cId( 9)).rul = ruls2(3);
RP.Blue(cId(10)).rul = ruls2(4);
RP.Blue(cId(11)).rul = ruls2(5);
RP.Blue(cId(12)).rul = ruls2(6);

if gameStatus == 0 %reset configuration
	Pnt = zeros(6, 2);
	Pnt(1, :) = -V1 * 2000 - [V1(2), -V1(1)] * width * 0.5 * 0.15;
	Pnt(2, :) = -V1 * 2000 + [V1(2), -V1(1)] * width * 0.5 * 0.15;
	Pnt(3, :) = -V1 * 4000;
	Pnt(4, :) = -V1 * 3000 - [V1(2), -V1(1)] * width * 0.5 * 0.35;
	Pnt(5, :) = -V1 * 3000 + [V1(2), -V1(1)] * width * 0.5 * 0.35;
	Pnt(6, :) = G1 + V1 * 500;
		
	Pnt(7, :) = -V2 * 2000 - [V2(2), -V2(1)] * width * 0.5 * 0.15;
	Pnt(8, :) = -V2 * 2000 + [V2(2), -V2(1)] * width * 0.5 * 0.15;
	Pnt(9, :) = -V2 * 4000;
	Pnt(10, :) = -V2 * 3000 - [V2(2), -V2(1)] * width * 0.5 * 0.35;
	Pnt(11, :) = -V2 * 3000 + [V2(2), -V2(1)] * width * 0.5 * 0.35;
	Pnt(12, :) = G2 + V2 * 500;
	for k = 1: 6
		if r_dist_points(RP.Blue(cId(k)).z, RP.Ball.z) > 500
	    	RP.Blue(cId(k)).rul = MoveToWithFastBuildPath(RP.Blue(cId(k)), Pnt(k+6, :), 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	    else
	    	vec = normir(RP.Blue(cId(k)).z - RP.Ball.z)*1000;
	    	RP.Blue(cId(k)).rul = MoveToWithFastBuildPath(RP.Blue(cId(k)), RP.Blue(cId(k)).z + vec, 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	    end
	    if r_dist_points(RP.Yellow(cId(k+3)).z, RP.Ball.z) > 500
	    	RP.Yellow(cId(k+6)).rul = MoveToWithFastBuildPath(RP.Yellow(cId(k+6)), Pnt(k, :), 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	    else
	    	vec = normir(RP.Yellow(cId(k+3)).z - RP.Ball.z)*1000;
	    	RP.Yellow(cId(k+6)).rul = MoveToWithFastBuildPath(RP.Yellow(cId(k+6)), RP.Yellow(cId(k + 6)).z + vec, 90, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
	    end
	end
end


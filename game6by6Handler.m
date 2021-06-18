global RP gameStatus BPosHX BPosHY ballFastMoving ballSaveDir oldTime curTime obstacles leftTeamIsBlue ourCommandIsBlue gameStage kickOfTeam;

if isempty(gameStage) || curTime - oldTime > 1
	gameStage = 0; %Pre first half
end

[BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
RP.Ball.z = BPEstim;
RP.Ball.x = BPEstim(1);
RP.Ball.y = BPEstim(2);

cId = [1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6];

if leftTeamIsBlue
	coms = [RP.Blue(cId(7)), RP.Blue(cId(8)),  RP.Blue(cId(9)), RP.Blue(cId(10)), RP.Blue(cId(11)),  RP.Blue(cId(12)); RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)), RP.Yellow(cId(4)), RP.Yellow(cId(5)), RP.Yellow(cId(6))];
else
	coms = [RP.Yellow(cId(1)), RP.Yellow(cId(2)), RP.Yellow(cId(3)), RP.Yellow(cId(4)), RP.Yellow(cId(5)), RP.Yellow(cId(6)); RP.Blue(cId(7)), RP.Blue(cId(8)),  RP.Blue(cId(9)), RP.Blue(cId(10)), RP.Blue(cId(11)),  RP.Blue(cId(12))];
end

G1 = [-4500 0];
G2 = [4500 0]; 
Left = -4500;
Right = 4500;
Up = 3000;
Down = -3000;
center = [(Left + Right) * 0.5, (Up + Down) * 0.5];
centerRadius = 500;
field = [Left Down; Right Up];
height = abs(Left - Right);
width = abs(Up - Down);
V1 = [1, 0];
V2 = [-1, 0];

ruls = [getEmptyRuls(size(coms, 2))'; getEmptyRuls(size(coms, 2))'];
%RefCommandForTeam == 1 -- for blue team
%RefCommandForTeam == 2 -- for yellow team
%RefCommandForTeam == 0 -- for all teams

goalSizes = [1000, 2000];
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

sd = getOurCommandSd(leftTeamIsBlue, ourCommandIsBlue);
os = 3-sd;
disp(gameStage);
switch RefState
	case haltCommand
		if gameStage == 0
			[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);			
		else
			ruls(1, :) = haltCommandHandler(coms);
			ruls(2, :) = haltCommandHandler(coms);
		end
	case stopCommand
		if gameStage == 0
			[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);
		else
			ruls(1, :) = stopCommandHandler(1, coms, RP.Ball, [G1; G2], [V1; V2], obstacles, goalSizes);
			ruls(2, :) = stopCommandHandler(2, coms, RP.Ball, [G1; G2], [V1; V2], obstacles, goalSizes);
		end
	case forceStartCommand
		[ruls1, ruls2] = forceStartCommandHandler();
	case timeoutCommand
		[ruls1, ruls2] = timeoutCommandHandler();
	case endGameCommand
		[ruls1, ruls2] = endGameCommandHandler();
	case kickoffCommand
		gameStage = 1; %kickoff
		disp([RefCommandForTeam, leftTeamIsBlue]);
		kickOfTeam = getKickoffTeamSide(RefCommandForTeam, leftTeamIsBlue);
		disp(kickOfTeam);
		[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);
	case normalStartCommand
		if gameStage == 1
			ruls(1, :) = kickoffCommandHandler(1, coms, obstacles, kickOfTeam, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY);
			ruls(2, :) = kickoffCommandHandler(2, coms, obstacles, kickOfTeam, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY);	
			if checkNormalStartCondition([0, 0], RP.Ball.z)
				gameStage = 2;
			end
		elseif gameStage == 2
			ruls(1, :) = gameModel(1, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
			ruls(2, :) = gameModel(2, coms, obsts, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
		end
	case penaltyCommand
		[ruls1, ruls2] = penaltyCommandHandler();
	case directKickCommand
		[ruls1, ruls2] = directCommandHandler();
	case indirectKickCommand
		[ruls1, ruls2] = indirectCommandHandler();
	case ballPlacementCommand
		[ruls1, ruls2] = ballPlacementCommandHandler();
end

copyRulsToRobotsRul(ruls(1, :), ruls(2, :));


global RP BPosHX BPosHY ballFastMoving ballSaveDir oldTime curTime obstacles leftTeamIsBlue ourCommandIsBlue gameState kickOfTeam prevRefState kickPoint;

if isempty(kickPoint)
	kickPoint = [0, 0];
end

if isempty(prevRefState) || curTime - oldTime > 1 && RefState == 0
	prevRefState = 0;	
end

if isempty(gameState) || curTime - oldTime > 1 && RefState == 0
	gameState = 0; %Pre first half
end

[BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
RP.Ball.z = BPEstim;
RP.Ball.x = BPEstim(1);
RP.Ball.y = BPEstim(2);

cId = [5, 2, 3, 4, 1, 6, 5, 2, 3, 4, 1, 6];

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

goalSizes = [1200, 2400];
haltCommand = 0;
stopCommand = 1;
forceStartCommand = 2;
timeoutCommand = 3;
endGameCommand = 4;
kickoffCommand = 5;
normalStartCommand = 6;
penaltyCommand = 7;
penaltyCommandKick = 8; %????
directKickCommand = 9;
indirectKickCommand = 10;
ballPlacementCommand = 11;

sd = getOurCommandSd(leftTeamIsBlue, ourCommandIsBlue);
os = 3-sd;
disp(gameState);
switch RefState
	case haltCommand
		if gameState == 0
			[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);			
		else
			gameState = 2;
			ruls(1, :) = haltCommandHandler(coms);
			ruls(2, :) = haltCommandHandler(coms);
		end
	case stopCommand
		if gameState == 0
			[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);
		else
			gameState = 2;
			ruls(1, :) = stopCommandHandler(1, coms, RP.Ball, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
			ruls(2, :) = stopCommandHandler(2, coms, RP.Ball, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
		end
	case forceStartCommand
		gameState = 2;
		ruls(1, :) = gameModel(1, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
		ruls(2, :) = gameModel(2, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
	case timeoutCommand
		ruls(1, :) = haltCommandHandler(coms);
		ruls(2, :) = haltCommandHandler(coms);
	case endGameCommand
		ruls(1, :) = haltCommandHandler(coms);
		ruls(2, :) = haltCommandHandler(coms);
	case kickoffCommand
		gameState = 1;
		kickOfTeam = getKickoffTeamSide(RefCommandForTeam, leftTeamIsBlue);
		[ruls(1, :), ruls(2, :)] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, RP.Ball, obstacles);
	case normalStartCommand
		if gameState == 1 || gameState == 0
			ruls(1, :) = kickoffCommandHandler(1, coms, obstacles, kickOfTeam, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY);
			ruls(2, :) = kickoffCommandHandler(2, coms, obstacles, kickOfTeam, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY);	
			if checkNormalStartCondition([0, 0], RP.Ball.z)
				gameState = 2;
			end
		elseif gameState == 2
			ruls(1, :) = gameModel(1, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
			ruls(2, :) = gameModel(2, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
		elseif gameState == 5
			ruls(1, :) = penaltyCommandHandler(1, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, false);
			ruls(2, :) = penaltyCommandHandler(2, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, false);
			if checkNormalStartCondition(kickPoint, RP.Ball.z)
				gameState = 2;
			end
		end
	case penaltyCommand
		gameState = 5;
		kickPoint = stableBallFiltering(BPosHX, BPosHY);
		kickOfTeam = getKickoffTeamSide(RefCommandForTeam, leftTeamIsBlue);
		ruls(1, :) = penaltyCommandHandler(1, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, true);
		ruls(2, :) = penaltyCommandHandler(2, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, true);
	case penaltyCommandKick
		if gameState == 5
			ruls(1, :) = penaltyCommandHandler(1, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, false);
			ruls(2, :) = penaltyCommandHandler(2, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes, false);		
			if checkNormalStartCondition(kickPoint, RP.Ball.z)
				gameState = 6;
			end
		elseif gameState == 6
			ruls(1, :) = haltCommandHandler(coms);
			ruls(2, :) = haltCommandHandler(coms);
		end
	case directKickCommand
		if gameState == 2 || gameState == 0
			kickPoint = stableBallFiltering(BPosHX, BPosHY);
			gameState = 3;
		elseif gameState == 3
			kickOfTeam = getKickoffTeamSide(RefCommandForTeam, leftTeamIsBlue);
			ruls(1, :) = directCommandHandler(1, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
			ruls(2, :) = directCommandHandler(2, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
			if checkNormalStartCondition(kickPoint, RP.Ball.z)
				gameState = 4;
			end
		elseif gameState == 4
			ruls(1, :) = gameModel(1, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
			ruls(2, :) = gameModel(2, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 					
		end
	case indirectKickCommand
		if gameState == 2 || gameState == 0
			kickPoint = stableBallFiltering(BPosHX, BPosHY);
			gameState = 3;
		elseif gameState == 3
			kickOfTeam = getKickoffTeamSide(RefCommandForTeam, leftTeamIsBlue);
			ruls(1, :) = directCommandHandler(1, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
			ruls(2, :) = directCommandHandler(2, kickOfTeam, coms, RP.Ball, BPosHX, BPosHY, BState, [G1; G2], [V1; V2], obstacles, goalSizes);
			if checkNormalStartCondition(kickPoint, RP.Ball.z)
				gameState = 4;
			end
		elseif gameState == 4
			ruls(1, :) = gameModel(1, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 
			ruls(2, :) = gameModel(2, coms, obstacles, RP.Ball, [G1; G2], [V1; V2], field, BState, BPosHX, BPosHY, 3); 					
		end
	case ballPlacementCommand
		gameState = 2;
		ruls(1, :) = haltCommandHandler(coms);
		ruls(2, :) = haltCommandHandler(coms);
end

copyRulsToRobotsRul(ruls(1, :), ruls(2, :), cId);
prevRefState = RefState;

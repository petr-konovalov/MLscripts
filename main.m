%% MAIN START HEADER

global Blues Yellows Balls Rules FieldInfo RefState RefCommandForTeam RefPartOfFieldLeft RP PAR Modul activeAlgorithm obstacles gameStatus

if isempty(RP)
    addpath tools RPtools MODUL
end
%

mainHeader();
%MAP();

if (RP.Pause) 
    return;
end

zMain_End=RP.zMain_End;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%PAR.HALF_FIELD=-1;
%PAR.MAP_X=4000;
%PAR.MAP_Y=3000;
%PAR.RobotSize=200;
%PAR.KICK_DIST=200;
%PAR.DELAY=0.15;
%PAR.WhellR=5;
%PAR.LGate.X=-2000;
%PAR.RGate.X=2000;
%PAR.BorotArm=225;



%% CONTRIL BLOCK

%{
robots = [8, 7, 1, 4, 3, 2];

R = 400;
obst = zeros(numel(robots), 3);
for k = 1: numel(robots)
    rid = robots(k);
    obst(k, 1) = RP.Blue(rid).x;
    obst(k, 2) = RP.Blue(rid).y;
    obst(k, 3) = R;
end

%RP.Blue(7).rul = Attacker(RP.Blue(7), RP.Ball, [-2000, 0]);

G1 = [-2270, 147];
G2 = [-283, -168];
RP.Blue(robots(1)).rul = MoveToAvoidance(RP.Blue(robots(1)), G1, obst(2:6, 1:3));
RP.Blue(robots(2)).rul = MoveToAvoidance(RP.Blue(robots(2)), G1, obst([1, 3:6], 1:3));

%RP.Blue(robots(1)).rul = MoveToLinear(RP.Blue(robots(1)), G, 2/750, 30, 50); 
%}


border1 = [-2000 -1500];
border2 = [2000 1500];
point1 = [-1.7683   -0.2785] * 1000;
point2 = [1500 800];

BlueIDs = 1:8;
YellowIDs = [];

commonSize = numel(BlueIDs) + numel(YellowIDs);
if isempty(obstacles) || size(obstacles, 1) ~= commonSize
    obstacles = zeros(commonSize, 3);
end
        
radius = 200;
eps = 10;

BCnt = numel(BlueIDs);
for k = 1: BCnt;
    atackerid = BlueIDs(k);
    if RP.Blue(atackerid).I ~= 0 && (r_dist_points(RP.Blue(atackerid).z, [obstacles(k, 1), obstacles(k, 2)]) > eps || abs(radius - obstacles(k, 3)) > eps)
        obstacles(k, 1) = RP.Blue(atackerid).x;
        obstacles(k, 2) = RP.Blue(atackerid).y;
        obstacles(k, 3) = radius;
    end
end

for k = 1: numel(YellowIDs)
    atackerid = YellowIDs(k);
    if RP.Yellow(atackerid).I ~= 0 && r_dist_points(RP.Yellow(atackerid).z, [obstacles(k + BCnt, 1), obstacles(k + BCnt, 2)]) > eps
        obstacles(k + BCnt, 1) = RP.Yellow(atackerid).x;
        obstacles(k + BCnt, 2) = RP.Yellow(atackerid).y;
        obstacles(k + BCnt, 3) = radius;
    end    
end

%RP.Blue(4).rul = kickBall(RP.Blue(4), RP.Ball, RP.Blue(7).z, kickBallPreparation());
%RP.Blue(4).rul = RotateToPID(RP.Blue(4), RP.Ball.z, 3, 10, 0.1, -30, 0.01);
%Speed1 = StabilizationXPID(RP.Blue(4), -2300, 10, 1/750, 0.000005, -0.8, 50);
%Speed2 = StabilizationYPID(RP.Blue(4), -187, 40, 4/750, 0, -1.5, 100);
%Speed = Speed1;
%RP.Blue(4).rul = Crul(Speed(1), Speed(2), 0, 0, 0);
% RP.Blue(4).rul = RotateToPID(RP.Blue(4), RP.Ball.z, 3, 30, 0, -50, 0.05, false);
%RP.Blue(4).rul = kickBall(RP.Blue(4), RP.Ball, RP.Blue(7).z, kickBallPreparation());
G1 = [-400, -1200];
G2 = [-2800, -1200];
cmd1 = [1, 2];
cmd2 = [4, 5];
V = [-1 0];
nV = [1 0];

% G1 = [-1800 0];
% G2 = [1800 0];
% V = [1 0];
% nV = [0 1];

%для отладки-----------------------------------------
global BPosHX; %history of ball coordinate X
global BPosHY; %history of ball coordinate Y
global ballFastMoving;
global ballSaveDir;
historyLength = 5;
if isempty(BPosHX) || isempty(BPosHY)
    BPosHX = zeros(1, historyLength);
    BPosHY = zeros(1, historyLength);
end

if isempty(ballFastMoving)
    ballFastMoving = false;
end

if isempty(ballSaveDir)
    ballSaveDir = true;
end


%----------------------------------------------------
dP = [0 400];
dAim = [6000 0];
Pnt1 = [-2.7833e+03 -1.6918e+03];
Pnt2 = Pnt1 + dP;
Pnt3 = Pnt2 + dP;
switch activeAlgorithm
    case -18 %old motion control algorithm
        RP.Blue(5).rul = MoveToLinear(RP.Blue(5), Pnt1 + dAim, 0, 80, 70);
        RP.Blue(3).rul = MoveToLinear(RP.Blue(3), Pnt2 + dAim, 0, 80, 70);
        RP.Blue(2).rul = MoveToLinear(RP.Blue(2), Pnt3 + dAim, 0, 80, 70);
    case -17 %trapetzoid motion reset
        RP.Blue(5).rul = MoveToLinear(RP.Blue(5), Pnt1, 0, 30, 30);
        RP.Blue(3).rul = MoveToLinear(RP.Blue(3), Pnt2, 0, 30, 30);
        RP.Blue(2).rul = MoveToLinear(RP.Blue(2), Pnt3, 0, 30, 30);
    case -16 %rotate to ball
        RP.Blue(5).rul = RotateToLinear(RP.Blue(5), Pnt1 + dAim, 5, 10, 0.05); 
        RP.Blue(3).rul = RotateToLinear(RP.Blue(3), Pnt2 + dAim, 5, 10, 0.05); 
        RP.Blue(2).rul = RotateToLinear(RP.Blue(2), Pnt3 + dAim, 5, 10, 0.05); 
    case -15 %trapetzoid motion start
        alp = 0.1;
        RP.Blue(5).rul = motionControl(RP.Blue(5), 'moving start', Pnt1 + dAim);
        RP.Blue(3).rul = motionControl(RP.Blue(3), 'moving start', Pnt2 + dAim);
        RP.Blue(2).rul = motionControl(RP.Blue(2), 'moving start', Pnt3 + dAim);
        activeAlgorithm = -14;
    case -14 %trapetzoid motion
        RP.Blue(5).rul = motionControl(RP.Blue(5), '');
        RP.Blue(3).rul = motionControl(RP.Blue(3), '');
        RP.Blue(2).rul = motionControl(RP.Blue(2), '');
    case -13 %obstacle avoidance moving
        aId = [2, 3, 4, 5, 6];
        P1 = [0, -200];
        dP = [0, -600];
        %P2 = P1([6, 5, 4, 3, 2, 1], :);
        for k = 1:5
            RP.Blue(aId(k)).rul = MoveToWithFastBuildPath(RP.Blue(aId(k)), P1 + (k - 1) * dP, 100, obstacles); 
        end
    case -12 %ball shooting
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        RP.Ball.z = BPEstim;
        atackerID = 2;
        if r_dist_points(RP.Blue(atackerID).z, RP.Ball.z) > 500
            RP.Blue(atackerID).rul = MoveToWithFBPPlusParam(RP.Blue(atackerID), RP.Ball.z, 300, obstacles);
        else
            RP.Blue(atackerID).rul = attack(RP.Blue(atackerID), RP.Ball, [4500, 0]);
        end
    case -11 %start acceleration moving
        accelerationMove();
        activeAlgorithm = -10;
        agentH = zeros(3, 3);
        T = 0;
    case -10 %acceleration moving process
        aId = 3;
        P = [-3000 -600];
        curT = cputime();
        if curT - T > 0.1
            agentH([2, 3], :) = agentH([1, 2], :);
            T = curT;
            agentH(1, 1) = T;
            agentH(1, 2) = RP.Blue(aId).x;
            agentH(1, 3) = RP.Blue(aId).y;
        end
        RP.Blue(aId).rul = accelerationMove(RP.Blue(aId), agentH, P, 0.1, 10);
    case -9 %speed estimation reset state
        sEstimState = 0;
        activeAlgorithm = -8;
    case -8 %speed estimation
        P1 = [-1000 -600];
        P2 = [-3000 -600];
        speed = 30;
        aId = 3;
        switch sEstimState
            case 0 
                T = cputime();
                pT1 = T;
                pT2 = T;
                pT3 = T;
                aPos = RP.Blue(aId).z;
                pPos1 = aPos;
                pPos2 = aPos;
                pPos3 = aPos;
                if r_dist_points(RP.Blue(aId).z, P1) > 300
                    P = P1;
                else
                    P = P2;
                end
                sEstimState = 1;
            case 1 %rotating to P
                RP.Blue(aId).rul = RotateToLinear(RP.Blue(aId), P, 5, 7, 0.1);
                if RP.Blue(aId).rul.SpeedR == 0
                    sEstimState = 2;
                    T = cputime();
                    aPos = RP.Blue(aId).z;
                end
            case 2 %moving to P
                RP.Blue(aId).rul = MoveToLinear(RP.Blue(aId), P, 0, speed, 0);
                curT = cputime();
                if curT - pT1 > 1
                    fprintf('Estimate speed (1): %f\n', norm(pPos1 - RP.Blue(aId).z) / (curT - pT1));
                    %disp(norm(pPos - RP.Blue(aId).z) / (curT - pT));
                    pPos1 = RP.Blue(aId).z;
                    pT1 = curT;
                end
                if curT - pT2 > 0.5
                    fprintf('Estimate speed (2): %f\n', norm(pPos2 - RP.Blue(aId).z) / (curT - pT2));
                    %disp(norm(pPos - RP.Blue(aId).z) / (curT - pT));
                    pPos2 = RP.Blue(aId).z;
                    pT2 = curT;
                end
                if curT - pT3 > 0.25
                    fprintf('Estimate speed (3): %f\n', norm(pPos3 - RP.Blue(aId).z) / (curT - pT3));
                    %disp(norm(pPos - RP.Blue(aId).z) / (curT - pT));
                    pPos3 = RP.Blue(aId).z;
                    pT3 = curT;
                end
                if r_dist_points(RP.Blue(aId).z, P) < 300
                    fprintf('Average speed: %f', (norm(aPos - RP.Blue(aId).z) / (curT - T)));
                    sEstimState = -1;
                end
        end
    case -7 %test robots
%        disp('hello');
         for k = 1:6
            RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);%RotateToLinear(RP.Blue(k), RP.Ball.z, 3, 10, 0.1);
         end
        % RP.Blue(3).rul = Crul(20, 0, 0, 0, 0);
    case -6 %test obstacle avoidance
        RP.Blue(3).rul = MoveToWithFastBuildPath(RP.Blue(3), RP.Ball.z, 300, obstacles(6, :));
    case -5 %test optDirGoalAttack
        atackerId = 1;
        keeperId = 2;
        G1 = [-700 -1189];
        G2 = [-734.4881 -870.6589];
        Left = -3750;
        Down = -2200;
        Right = -700;
        Up = -200;
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        if RP.Ball.I == 0
            BPEstim = clarifyBallPos(RP.Blue([1, 2]), BPEstim);
        end
        RP.Ball.z = BPEstim;
        RP.Ball.x = BPEstim(1);
        RP.Ball.y = BPEstim(2);
        if Left < RP.Ball.x && RP.Ball.x < Right && Down < RP.Ball.y && RP.Ball.y < Up
            if r_dist_points(RP.Blue(atackerId).z, RP.Ball.z) < 300
                RP.Blue(atackerId).rul = optDirGoalAttack(RP.Blue(atackerId), RP.Ball, RP.Blue([2, 3, 4, 5, 6, 8]), G1, [-1, 0]);
            else
                RP.Blue(atackerId).rul = MoveToWithFastBuildPath(RP.Blue(atackerId), RP.Ball.z, 200, obstacles, 50);
            end
        end
        RP.Blue(keeperId).rul = GoalKeeperOnLine(RP.Blue(keeperId), G1, [-1, 0], BPosHX, BPosHY, BState.BStand, BState.BSpeed, 800);
    case -4 %reset robot position
%         G1 = [-0.2924   -1.1207] * 1000;
%         G2 = [-3.1655   -1.1475] * 1000;
%         P2 = G2 + (G1 - G2) / 3;
%         P1 = G2 + (G1 - G2) * 2 / 3;
%         RP.Blue(1).rul = MoveToLinear(RP.Blue(1), P1, 0, 40, 50);
%         RP.Blue(2).rul = MoveToLinear(RP.Blue(2), P2, 0, 40, 50);
        S = [1, 3, 5, 7];
        F = [2, 4, 6, 8];
        fP = [-1500, -2000];
        dfP = [0, 400];
        sP = [-3000, -2000];
        dsP = [0, 400];
        for k = F
            RP.Blue(k).rul = MoveToWithFastBuildPath(RP.Blue(k), fP+dfP*(floor(k/2) - 1), 50, obstacles, 30);
        end
%         for k = S
%             RP.Blue(k).rul = MoveToWithFastBuildPath(RP.Blue(k), sP+dsP*(floor(k/2)), 50, obstacles, 30);
%         end
    case -3 %ball groop shooting
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        RP.Ball.z = BPEstim;
        attackId = 7;
        for k = [6, 8]
            if r_dist_points(RP.Blue(k).z, RP.Ball.z) < r_dist_points(RP.Blue(attackId).z, RP.Ball.z)
                attackId = k;
            end
        end
        %disp(attackId);
        if RP.Ball.y < 0
            aimP = [-2250 2500];
            vP = [0 -1];
        else
            aimP = [-2250 -2500];
            vP = [0 1];
        end
        %[RP.Blue(attackId).rul, isDetermined] = optDirGoalAttack(RP.Blue(attackId), RP.Ball, RP.Blue([1: attackId-1, attackId+1: 8]), aimP, vP);
        %if ~isDetermined
            RP.Blue(attackId).rul = attack(RP.Blue(attackId), RP.Ball, aimP, 2);
        %end
        %RP.Blue(5).rul.SpeedX = 1.5 * RP.Blue(5).rul.SpeedX;
        %RP.Blue(5).rul.SpeedY = 1.5 * RP.Blue(5).rul.SpeedY;
        %RP.Blue(5).rul.SpeedR = 1.5 * RP.Blue(5).rul.SpeedR;
    case -2 %Test ball moving manager on record
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        fprintf('BF:%3d    BS:%3d    SD:%3d    S:   [%d, %d]', BState.BFast, BState.BStand, BState.saveDir, BState.BSpeed(1), BState.BSpeed(2));
    case -1 %Test ball moving manager on real robots
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        fprintf('BF:%3d    BS:%3d    SD:%3d    S:   [%d, %d]', BState.BFast, BState.BStand, BState.saveDir, BState.BSpeed(1), BState.BSpeed(2));
        G1 = [-0.2924   -1.1207] * 1000;
        G2 = [-3.1655   -1.1475] * 1000;
        RP.Ball.z = BPEstim;
        if r_dist_points(G1, RP.Ball.z) < 1000
            RP.Blue(5).rul = attack(RP.Blue(5), RP.Ball, G1);
            %RP.Blue(5).rul.KickVoltage = 12;
        else
            RP.Blue(5).rul = MoveToLinear(RP.Blue(5), G1 + [-1000, 0], 0, 40, 100);
        end
        if r_dist_points(G2, RP.Ball.z) < 1000
            RP.Blue(1).rul = attack(RP.Blue(1), RP.Ball, G2);
            %RP.Blue(1).rul.KickVoltage = 15;
        else
            RP.Blue(1).rul = MoveToLinear(RP.Blue(1), G2 + [0, 1000], 0, 40, 100);
        end
    case 0 %gameModel test
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        RP.Ball.z = BPEstim;
        RP.Ball.x = BPEstim(1);
        RP.Ball.y = BPEstim(2);
        %disp(BPEstim);
        
        cId = [1, 2, 5, 3, 4, 6];
        coms = [RP.Blue(cId(1)), RP.Blue(cId(2)), RP.Blue(cId(3)); RP.Blue(cId(4)), RP.Blue(cId(5)),  RP.Blue(cId(6))];
        obsts = obstacles(cId, :);
        G1 = [623 1110];
        G2 = [3760 1073];
        P1 = [250 2150];
        P2 = [3980 175]; 
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
        
        RP.Blue(cId(1)).rul = ruls1(1);
        RP.Blue(cId(2)).rul = ruls1(2);
        RP.Blue(cId(3)).rul = ruls1(3);
        
        RP.Blue(cId(4)).rul = ruls2(1);
        RP.Blue(cId(5)).rul = ruls2(2);
        RP.Blue(cId(6)).rul = ruls2(3);
        
        if gameStatus == 0 %reset configuration
            Pnt = zeros(4, 2);
            Pnt(1, :) = G1 + V1 * 500 - [V1(2), -V1(1)] * width * 0.35;
            Pnt(2, :) = G1 + V1 * 500 + [V1(2), -V1(1)] * width * 0.35;
            Pnt(3, :) = G1 + V1 * 500;
            Pnt(4, :) = G2 + V2 * 500 - [V2(2), -V2(1)] * width * 0.35;
            Pnt(5, :) = G2 + V2 * 500 + [V2(2), -V2(1)] * width * 0.35;
            Pnt(6, :) = G2 + V2 * 500;
            for k = 1: 6
                RP.Blue(cId(k)).rul = MoveToWithFastBuildPath(RP.Blue(cId(k)), Pnt(k, :), 50, obstacles([1:cId(k)-1, cId(k)+1:size(obstacles, 1)], :));
            end
        end
        %RP.Blue(2).rul = Crul(0, 0, 0, 0, 0);
        %RP.Blue(3).rul = Crul(0, 0, 0, 0, 0);
    case 1 %Steal ball test
        %One camera field parameters
        LeftBottom = [-3.4867   -2.2538] * 1000;
        RightTop = [-125.6602  170.6299];
        LeftGoal = [-3.3474   -1.0248] * 1000;
        RightGoal = [-0.2614   -1.0371] * 1000;
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        if RP.Ball.I == 0
            BPEstim = clarifyBallPos(RP.Blue([1, 2]), BPEstim);
        end
        
        RP.Blue(1).rul = stealBall(RP.Blue(1), BPEstim, RP.Blue(2), obstacles(2, :));
        RP.Blue(2).rul = stealBall(RP.Blue(2), BPEstim, RP.Blue(1), obstacles(1, :));
    case 2
        %---------------HISTORY MANAGER-----------------
%         
%         if (isempty(BPosHX) || isempty(BPosHY))
%             BPosHX = zeros(1, historyLength);
%             BPosHY = zeros(1, historyLength);
%             for i = 1: historyLength
%                 BPosHX(i) = RP.Ball.x;
%                 BPosHY(i) = RP.Ball.y;
%             end
%         else
%             for i = 1: historyLength - 1
%                 BPosHX(i) = BPosHX(i + 1);
%                 BPosHY(i) = BPosHY(i + 1);
%             end
%             BPosHX(historyLength) = RP.Ball.x;
%             BPosHY(historyLength) = RP.Ball.y;
%         end
%         %-----------------------------------------------
%         ballMovement = RP.Ball.z - [BPosHX(1), BPosHY(1)];
        
       minX = -3200;
       maxX = 0;
       minY = -2200;
       maxY = -300;
       global oldBallPos;
       
%         minX = G1(1) - 500;
%         maxX = G1(1) + 500;
%         minY = min(G1(2), G2(2));
%         maxY = max(G1(2), G2(2));
        [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
        if ~RP.Ball.I
            RP.Ball.z = oldBallPos;
        end
        
        if minX <= RP.Ball.x && RP.Ball.x <= maxX && minY <= RP.Ball.y && RP.Ball.y <= maxY
            [RP.Blue(cmd1(1)).rul, RP.Blue(cmd1(2)).rul] = STPGame2by2FirstCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, ballStanding, ballSpeed, RP.Blue(cmd1), RP.Blue(cmd2), G1, G2, V, -V);
            [RP.Blue(cmd2(1)).rul, RP.Blue(cmd2(2)).rul] = STPGame2by2SecondCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, ballStanding, ballSpeed, RP.Blue(cmd2), RP.Blue(cmd1), G2, G1, -V, V);
        else
            RP.Blue(cmd1(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd1(2)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(2)).rul = Crul(0, 0, 0, 0, 0);
        end
        
        oldBallPos = RP.Ball.z;
    case 100001
        G2 = [-734.4881 -870.6589];
        V2 = [-1, 0];
        [BState, BPosHX, BPosHY, BPEstim] = ballMovingManager(RP.Ball);
        RP.Blue(3).rul = GoalKeeperOnLine(RP.Blue(3), G2, V2, BPosHX, BPosHY, BState.BStand, BState.BSpeed);
        if r_dist_points(RP.Ball.z, [-2.5860e+03 -932.6824]) < 1000
            [RP.Blue(1).rul, problem] = optDirGoalAttack(RP.Blue(1), RP.Ball, RP.Blue(3), G2, V2); 
            if ~problem
                disp('problem')
            end
        end
        %RP.Blue(1).rul = MoveToWithFBPPlusParam(RP.Blue(cmd1(1)), G1, vicinity, obstacles([1:cmd1(1)-1, cmd1(1)+1:6], :));
    case 102 
           
        
        [fastMoving, saveDir, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
        cmd1 = [2, 4, 6];
        cmd2 = [3, 5];
        minX = -3600;
        maxX = 0;
        minY = -2500;
        maxY = 0;
         RP.Blue(4).rul = Crul(0, 0, 0, 30, 0);
        if minX <= RP.Ball.x && RP.Ball.x <= maxX && minY <= RP.Ball.y && RP.Ball.y <= maxY
            [RP.Blue(cmd1(1)).rul, RP.Blue(cmd1(2)).rul, RP.Blue(cmd1(3)).rul] = STPGame3by2FirstCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, RP.Blue(cmd1), RP.Blue(cmd2), G1, G2, V, -V,RP.Blue(cmd1).isBallInside, obstacles);
            [RP.Blue(cmd2(1)).rul, RP.Blue(cmd2(2)).rul] = STPGame2by2SecondCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, RP.Blue(cmd2), RP.Blue(cmd1), G2, G1, -V, V, RP.Blue(cmd1).isBallInside, obstacles);
        else
            RP.Blue(cmd1(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd1(2)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd1(3)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(2)).rul = Crul(0, 0, 0, 0, 0);
        end
        
        
    case 103 
        [fastMoving, saveDir, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
        cmd1 = [1, 2, 3];
        cmd2 = [4, 5, 6];
         minX = -3600;
        maxX = 0;
        minY = -2500;
        maxY = 0;
        RP.Blue(4).rul = Crul(0, 0, 0, 30, 0);
        if minX <= RP.Ball.x && RP.Ball.x <= maxX && minY <= RP.Ball.y && RP.Ball.y <= maxY
            [RP.Blue(cmd1(1)).rul, RP.Blue(cmd1(2)).rul, RP.Blue(cmd1(3)).rul] = STPGame3by3FirstCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, RP.Blue(cmd1), RP.Blue(cmd2), G1, G2, V, -V, true, obstacles);
            [RP.Blue(cmd2(1)).rul, RP.Blue(cmd2(2)).rul, RP.Blue(cmd2(3)).rul] = STPGame3by3SecondCom(RP.Ball, BPosHX, BPosHY, fastMoving, saveDir, RP.Blue(cmd2), RP.Blue(cmd1), G2, G1, -V, V, true, obstacles);
        else
            RP.Blue(cmd1(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd1(2)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd1(3)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(1)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(2)).rul = Crul(0, 0, 0, 0, 0);
            RP.Blue(cmd2(3)).rul = Crul(0, 0, 0, 0, 0);
        end
        
        
    case 3
        atackerid = 3;
        agent = RP.Blue(atackerid);
        ball = RP.Ball;
        
        RP.Blue(atackerid).rul = GoalKeeperOnLine(agent, ball, G2, -V);
        
        oppCom = RP.Blue(2:6);
        if r_dist_points(G1, RP.Ball.z) < 1000
            %RP.Blue(id).rul = attack(RP.Blue(id), RP.Ball, RP.Blue(2).z);
            RP.Blue(1).rul = optDirGoalAttack(RP.Blue(1), RP.Ball, oppCom, G2, -V);
        end
        RP.Blue(1).rul.KickVoltage = 5;
    case 4
        
        %RP.Blue(8).rul = RotateToLinear(RP.Blue(8), RP.Ball.z, 2, 20, 0.05);
        %ballInside = ballInsideEmulation(RP.Blue(1:3), RP.Ball);
        %[RP.Blue(2).rul, RP.Blue(3).rul, RP.Blue(4).rul] = goalKeeperAgainstTwoAttakers(RP.Blue(1), RP.Blue(2), RP.Blue(3), RP.Ball, G1, V, ballInside);
        %agent = RP.Blue(id);
        vicinity = 80;
        RP.Blue(cmd1(1)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd1(1)), G1, vicinity, obstacles([1:cmd1(1)-1, cmd1(1)+1:6], :));
        RP.Blue(cmd1(2)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd1(2)), G1 + 400 * V, vicinity, obstacles([1:cmd1(2)-1, cmd1(2)+1:6], :));
        RP.Blue(cmd2(1)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd2(1)), G2, vicinity, obstacles([1:cmd2(1)-1, cmd2(1)+1:6], :));
        RP.Blue(cmd2(2)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd2(2)), G2 - 400 * V, vicinity, obstacles([1:cmd2(2)-1, cmd2(2)+1:6], :));
        
    case 5
        %RP.Blue(8).rul = goAroundPoint(RP.Blue(8), RP.Ball.z, 140, 1000, 5, 25);
        %RP.Blue(2).rul = goalAttack(RP.Blue(2), RP.Ball, RP.Blue(1).z, G1, V, ballInsideEmulation(RP.Blue(1:3), RP.Ball));
        %RP.Blue(2).rul = MoveToWithRotation(RP.Blue(2), RP.Ball.z, RP.Ball.z, 1/1000, 20, 0, 2, 20, 0, 0, 0.1, false);
        attackerid = 3;
        aim = RP.Blue(5).z;
        ball = RP.Ball;
        
        if (r_dist_points(G2, ball.z) < 1000 || ~ball.I)
            RP.Blue(attackerid).rul = attack(RP.Blue(attackerid), ball, aim);
        end
    case 6
        G = [-420, -1018];
        RP.Blue(1).rul = attack(RP.Blue(1), RP.Ball, G);
    case 7
        center = [-800 0];
        pnt1 = [100 800];
        pnt2 = [100 -800];
        global robotState;
        if isempty(robotState)
            robotState = false;
        end
        
        if robotState
            RP.Blue(2).rul = MoveToLinear(RP.Blue(2), pnt1, 0, 40, 100);
        else
            RP.Blue(2).rul = MoveToLinear(RP.Blue(2), pnt2, 0, 40, 100);
        end
        
        %if RP.Blue(2).rul.left == 0 && RP.Blue(2).rul.right == 0
        %    robotState = ~robotState;
        %end
        
        RP.Blue(8).rul = attack(RP.Blue(8), RP.Ball, RP.Blue(2).z, ballInside);
    case 8
        RP.Blue(8).rul = attack(RP.Blue(8), RP.Ball, RP.Blue(2).z, ballInside);
    case 9
        RP.Blue(8).rul = catchBall(RP.Blue(8), RP.Ball);
    case 10
        RP.Blue(8).rul = GoalKeeperOnLine(RP.Blue(8), RP.Ball, G + 150 * V, V);
        
    case 10001
        RP.Blue(8).rul = MoveToPD(RP.Blue(8), G + 150 * V, 15, 4/750, -1.5, 50);
    case 10002
        RP.Blue(2).rul = MoveToWithFastBuildPath(RP.Blue(2), [200 200], 150, obstacles([1, 3:6], :));
        %RP.Blue(4).rul = MoveToLinear(RP.Blue(4), [-1.6749e+03 1.1513e+03], 0, 40, 50);
    case 10003
        RP.Blue(7).rul = Crul(0, 0, 0, 20, 0);
    case 10004
        RP.Blue(4).rul = RotateToPID(RP.Blue(4), RP.Ball.z, 4, 15, 0, -30, 0.04, false);
    case 10005
        RP.Blue(4).rul = MoveToPID(RP.Blue(4), [-1.5e+03 0.7e+03], 35, 0.5/750, 0, 0, 40);
        RP.Blue(7).rul = MoveToPID(RP.Blue(7), [-0.9e+03 -0.7e+03], 35, 0.5/750, 0, 0, 40);   
    case 10006
        RP.Blue(6).rul = MoveToLinear(RP.Blue(6), RP.Ball.z, 0, 40, 300);
        %RP.Blue(7).rul = MoveToLinear(RP.Blue(7), [-600 986], 0, 40, 50);
    case 10007
%             RP.Blue(2).rul = MoveToLinear(RP.Blue(2), [-845.4487 0], 0, 25, 50);
%             RP.Blue(7).rul = MoveToLinear(RP.Blue(7), 1000 * [-1.6729 0.8112], 0, 25, 50);
%             RP.Blue(8).rul = MoveToLinear(RP.Blue(8), 1000 * [-1.1115 -1.1685], 0, 15, 20);
%             RP.Blue(8).rul = MoveToLinear(RP.Blue(8), [-1900 0], 0, 25, 50);
        [RP.Blue(8).rul, RP.Blue(5).rul, RP.Blue(3).rul] = goBaseStateForGoalKeeperAgainstTwoAttakers(RP.Blue(8), RP.Blue(5), RP.Blue(3), G, V);
    case 10008
        minSpeed = 30;
        P = 0;
        D = 0;
        vicinity = 300;
        RP.Blue(8).rul = MoveToPD(RP.Blue(8), RP.Ball.z, minSpeed, P, D, vicinity);
    otherwise
        RP.Blue(4).rul = Crul(0, 0, 0, 0, 0);
        RP.Blue(7).rul = Crul(0, 0, 0, 0, 0);
end

%for grSim------------
% axRot = 4;
% minSpeedRot = 0;
% maxSpeedRot = 100;
% 
% maxSpeed = 30;
% for k = 1: BCnt
%     SpeedABS = norm([RP.Blue(k).rul.SpeedX, RP.Blue(k).rul.SpeedY]);
%     if SpeedABS > 100
%         RP.Blue(k).rul.SpeedX = RP.Blue(k).rul.SpeedX / SpeedABS * 100;
%         RP.Blue(k).rul.SpeedY = RP.Blue(k).rul.SpeedY / SpeedABS * 100;
%     end
%     RP.Blue(k).rul.SpeedX =  RP.Blue(k).rul.SpeedX / 100 * maxSpeed;
%     RP.Blue(k).rul.SpeedY =  RP.Blue(k).rul.SpeedY / 100 * maxSpeed;
%     RP.Blue(k).rul.SpeedR = -sign(RP.Blue(k).rul.SpeedR) * minSpeedRot - RP.Blue(k).rul.SpeedR * axRot;
%     if abs(RP.Blue(k).rul.SpeedR) > maxSpeedRot
%        RP.Blue(k).rul.SpeedR = sign(RP.Blue(k).rul.SpeedR) * maxSpeedRot;
%     end
% end
%---------------------


%RP.Blue(4).rul = GoalKeeperOnLine(RP.Blue(4), RP.Ball, G, V);
%RP.Blue(4).rul = TakeAim(RP.Blue(4), RP.Ball.z, RP.Blue(7).z);
%RP.Blue(7).rul = goAroundPoint(RP.Blue(7), RP.Ball.z, 220, 1000, 5, 40);
%RP.Blue(7).rul = RotateToLinear(RP.Blue(7), RP.Ball.z, 5, 2, 0);
%RP.Blue(7).rul = MoveToLinear(RP.Blue(7), G, 0, 40, 50);

%% END CONTRIL BLOCK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAIN END

%Rules

zMain_End = mainEnd();
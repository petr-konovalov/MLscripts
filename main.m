%% MAIN START HEADER

global Blues Yellows Balls Rules FieldInfo RefState RefCommandForTeam RefPartOfFieldLeft RP PAR Modul activeAlgorithm obstacles

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

BlueIDs = 1:6;
YellowIDs = [];

commonSize = numel(BlueIDs) + numel(YellowIDs);
if isempty(obstacles) || size(obstacles, 1) ~= commonSize
    obstacles = zeros(commonSize, 3);
end
        
radius = 220;
eps = 30;

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

switch activeAlgorithm
    case 0
        for k = BlueIDs
            RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);
        end
    case 1
        %aId = 5;
        %RP.Blue(aId).rul = Crul(0, 0, 0, 20, 0);%RotateToPD(RP.Blue(aId), RP.Ball.z, 15, 0, 0, 0.1);
        for k = BlueIDs
            RP.Blue(k).rul = Crul(0, 0, 0, 10, 0);
        end
    case 2    
        minX = -3200;
        maxX = 0;
        minY = -2200;
        maxY = -300;
        global oldBallPos;
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
        [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
        RP.Blue(1).rul = GoalKeeperOnLine(RP.Blue(1), G2, -V, BPosHX, BPosHY, ballStanding, ballSpeed);
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
        aId = 5;
        RP.Blue(aId).rul = Crul(30, 0, 0, 0, 0);
    case 4
        vicinity = 80;
        RP.Blue(cmd1(1)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd1(1)), G1, vicinity, obstacles([1:cmd1(1)-1, cmd1(1)+1:6], :));
        RP.Blue(cmd1(2)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd1(2)), G1 + 400 * V, vicinity, obstacles([1:cmd1(2)-1, cmd1(2)+1:6], :));
        RP.Blue(cmd2(1)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd2(1)), G2, vicinity, obstacles([1:cmd2(1)-1, cmd2(1)+1:6], :));
        RP.Blue(cmd2(2)).rul = MoveToWithFBPPlusParam(RP.Blue(cmd2(2)), G2 - 400 * V, vicinity, obstacles([1:cmd2(2)-1, cmd2(2)+1:6], :));
        
    case 5
        attackerid = 3;
        aim = RP.Blue(5).z;
        ball = RP.Ball;
        
        if (r_dist_points(G2, ball.z) < 1000 || ~ball.I)
            RP.Blue(attackerid).rul = attack(RP.Blue(attackerid), ball, aim);
        end
    case 6
        RP.Blue(8).rul = goAroundPoint(RP.Blue(8), RP.Ball.z, 140, -1000, 5, 25);
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
        RP.Blue(2).rul = MoveToWithFastBuildPath(RP.Blue(2), [-1.6749e+03 1.1513e+03], 150, obstacles);
        %RP.Blue(4).rul = MoveToLinear(RP.Blue(4), [-1.6749e+03 1.1513e+03], 0, 40, 50);
    case 10003
        RP.Blue(7).rul = Crul(0, 0, 0, 20, 0);
    case 10004
        RP.Blue(4).rul = RotateToPID(RP.Blue(4), RP.Ball.z, 4, 15, 0, -30, 0.04, false);
    case 10005
        RP.Blue(4).rul = MoveToPID(RP.Blue(4), [-1.5e+03 0.7e+03], 35, 0.5/750, 0, 0, 40);
        RP.Blue(7).rul = MoveToPID(RP.Blue(7), [-0.9e+03 -0.7e+03], 35, 0.5/750, 0, 0, 40);   
    case 10006
        RP.Blue(4).rul = MoveToLinear(RP.Blue(4), [-600 -986], 0, 40, 50);
        RP.Blue(7).rul = MoveToLinear(RP.Blue(7), [-600 986], 0, 40, 50);
    case 10007
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

%% END CONTRIL BLOCK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAIN END

%Rules

zMain_End = mainEnd();
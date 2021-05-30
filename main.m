%% MAIN START HEADER

global Blues Yellows Balls Rules FieldInfo RefState RefCommandForTeam RefPartOfFieldLeft RP PAR Modul activeAlgorithm obstacles gameStatus simulator oldRules

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

if isempty(simulator)
    simulator = false;
end

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

global oldBallPos;

if isempty(oldBallPos)
	oldBallPos = [0, 0];
end

if isempty(RP.Ball.z)
	RP.Ball.z = oldBallPos;
	RP.Ball.x = oldBallPos(1);
	RP.Ball.y = oldBallPos(2);
end

oldBallPos = RP.Ball.z;

border1 = [-2000 -1500];
border2 = [2000 1500];
point1 = [-1.7683   -0.2785] * 1000;
point2 = [1500 800];

BlueIDs = 1:11;
YellowIDs = 1:11;

commonSize = numel(BlueIDs) + numel(YellowIDs);
if isempty(obstacles) || size(obstacles, 1) ~= commonSize
    obstacles = zeros(commonSize, 3);
end
        
radius = 220;
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

%��� �������-----------------------------------------
global BPosHX; %history of ball coordinate X
global BPosHY; %history of ball coordinate Y
global ballFastMoving;
global ballSaveDir;
global oldTime;
global curTime;
curTime = cputime();
%disp(curTime);

if isempty(oldTime)
	oldTime = curTime;
end

historyLength = 5;
if isempty(BPosHX) || isempty(BPosHY) || oldTime - curTime > 5
    BPosHX = zeros(1, historyLength);
    BPosHY = zeros(1, historyLength);
end

if isempty(ballFastMoving) || oldTime - curTime > 5
    ballFastMoving = false;
end

if isempty(ballSaveDir) || oldTime - curTime > 5
    ballSaveDir = true;
end


%----------------------------------------------------
dP = [0 400];
dAim = [6000 0];
Pnt1 = [-2.7833e+03 -1.6918e+03];
Pnt2 = Pnt1 + dP;
Pnt3 = Pnt2 + dP;

if simulator
    if isempty(RP.Ball.z)
        RP.Ball.z = [0, 0];
        RP.Ball.I = 0;
    end
    for k = 1: 6
        if isempty(RP.Blue(k).z)
            RP.Blue(k).z = [0, 0];
            RP.Blue(k).I = 0;
        end
    end
end

%global gameStatus;
%gameStatus = 0;
%game3by3Handler;

aim = [-5000, -3000];
RP.Blue(1).rul = MoveToConstAcc(RP.Blue(1), aim, 0, 100);
%rotRul = RotateToLinear(RP.Blue(1), aim, 0, 5, 0);
%RP.Blue(1).rul.SpeedR = rotRul.SpeedR;

%RP.Blue(11).rul = MoveToLinear(RP.Blue(11), [-1000, 2000], 0, 10, 50);
%RP.Blue(11).rul = RotateToLinear(RP.Blue(11), [0, 0], 0, 5, 0);
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

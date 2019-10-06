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

G1 = [-400, -1200];
G2 = [-2800, -1200];
cmd1 = [1, 2];
cmd2 = [4, 5];
V = [-1 0];
nV = [1 0];

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
%{
    Здесь всё пропало потомучто, это ветка new_moveToPoint
%}
w = 250;
switch activeAlgorithm
    case 0
        for k = BlueIDs
            RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);
        end
    case 1
        RP.Blue(4).rul = MoveToSM(RP.Blue(4), w, G2, 100, 100);
        %RP.Blue(4).rul = Crul(25, 0, 0, 0, 0);
    case 2
        RP.Blue(4).rul = MoveToSM(RP.Blue(4), w, G1, 100, 100);
end

%% END CONTRIL BLOCK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAIN END

%Rules

zMain_End = mainEnd();
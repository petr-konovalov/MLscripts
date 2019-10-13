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

id = 3;        %number of controlled robots
aimP = [0, 0]; %robot destination point
coef = 1/1000; %coefficient of P-controller
minV = 25;     %robot minimal travel speed
vicinity = 50; %neighborhood size of the target point at which the robot will stop

%RP.Blue(id) - robot information structure
%RP.Blue(id).rul - robot controll structure

%MoveToLinear calculate the velocity vector nessary for the robot to move
%from its current positoin to destination point, wherein the speed magnitude
%have linearly depends on the distance
RP.Blue(id).rul = MoveToLinear(RP.Blue(id), aimP, coef, minV, vicinity);

%% END CONTRIL BLOCK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAIN END

%Rules

zMain_End = mainEnd();
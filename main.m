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
        %{
        if (RP.Blue(7).x > border1(1) &&  RP.Blue(7).x < border2(1) && RP.Blue(7).y > border1(2) && RP.Blue(7).x < border2(2))
            RP.Blue(7).rul = catchBall(RP.Blue(7), RP.Ball);
        else 
            RP.Blue(7).rul = Crul(0, 0, 0, 0, 0);
        end
        if (RP.Blue(4).x > border1(1) &&  RP.Blue(4).x < border2(1) && RP.Blue(4).y > border1(2) && RP.Blue(4).x < border2(2))
            RP.Blue(4).rul = attack(RP.Blue(4), RP.Ball, RP.Blue(7).z, ballInside);
        else 
            RP.Blue(4).rul = Crul(0, 0, 0, 0, 0);
        end
        %}        
        %RP.Blue(7).rul = MoveToWithFastBuildPath(RP.Blue(7), RP.Ball.z, 250, obstacles);
        %{
        RP.Blue(4).rul = Crul(0, 0, 0, 0, 0);
        RP.Blue(7).rul = Crul(0, 0, 0, 0, 0);
        %}
        %G = [-1900, 0];
        %[RP.Blue(8).rul, RP.Blue(5).rul, RP.Blue(3).rul] = goBaseStateForGoalKeeperAgainstTwoAttakers(RP.Blue(8), RP.Blue(5), RP.Blue(3), G, V);
%         minSpeed = 15;
%         P = 1/2000;
%         D = 0;
%         vicinity = 100;
%    
%         for k = 1: 8
%             %RP.Blue(k).rul = Crul(0, 0, 0, 0, 0);
%         end
        %RP.Blue(4).rul.AutoKick = 1;
%         SpeedX = 0;
%         SpeedY = 0;
%         KickForward = 1;
%         SpeedR = 0;
%         KickUp = 0;
%         AutoKick = 1;
%         KickVoltage = 12;
%         EnableSpinner = 0;
%         SpinnerSpeed = 0;
%         KickerCharge = 1;
%         Beep = 0;

     %RP.Blue(2).rul.AutoKick = 1;    
     
%      RP.Blue(1).rul = Crul(0, 0, 0, 30, 0);
%     RP.Blue(2).rul = Crul(0, 0, 0, 30, 0);
%     RP.Blue(3).rul = Crul(0, 0, 0, 30, 0);
%     RP.Blue(4).rul = Crul(0, 0, 0, 30, 0);
%     RP.Blue(1).rul = Crul(0, 0, 0, 30, 0);
     %RP.Blue(6).rul = Crul(0, 0, 0, 30, 0);

       %RP.Blue(3).rul = MoveToPD(RP.Blue(2), [4000, 1000], 50, 0, 0, 100);
       %RP.Blue(4).rul = Crul(SpeedX, SpeedY, KickForward, SpeedR, KickUp, AutoKick, KickVoltage, EnableSpinner, SpinnerSpeed, KickerCharge, Beep);
%         RP.Blue(2).rul = Crul(SpeedX, SpeedY, KickForward, SpeedR, KickUp, AutoKick, KickVoltage, EnableSpinner, SpinnerSpeed, KickerCharge, Beep);
%         RP.Blue(3).rul = Crul(SpeedX, SpeedY, KickForward, SpeedR, KickUp, AutoKick, KickVoltage, EnableSpinner, SpinnerSpeed, KickerCharge, Beep);
%         RP.Blue(4).rul = Crul(SpeedX, SpeedY, KickForward, SpeedR, KickUp, AutoKick, KickVoltage, EnableSpinner, SpinnerSpeed, KickerCharge, Beep);
%         RP.Blue(5).rul = Crul(SpeedX, SpeedY, KickForward, SpeedR, KickUp, AutoKick, KickVoltage, EnableSpinner, SpinnerSpeed, KickerCharge, Beep);
        %RP.Blue(3).rul = Crul(20, 0,0,0,0);
        %RP.Blue(2).rul = MoveToPD(RP.Blue(2), G1 + 600 * V, minSpeed, P, D, vicinity);
		%RP.Blue(2).rul.SpeedX = -RP.Blue(2).rul.SpeedX;
        %RP.Blue(7).rul = MoveToPD(RP.Blue(7), G2 - 150 * V, minSpeed, P, D, vicinity);
        %RP.Blue(8).rul = MoveToPD(RP.Blue(8), G2 - 600 * V, minSpeed, P, D, vicinity);
        
       
%        minSpeed = 20;
%        P = 1/2000;
%        D = 0;
%        vicinity = 30;
%        
%        if (isempty(BPosHX) || isempty(BPosHY))
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
%        end
% 
%        id = 5;
%        
%        %RP.Blue(1).rul = MoveToLinear(RP.Blue(5), G1, 0, 20, 170);
%        %RP.Blue(2).rul = distAttack(RP.Blue(2), RP.Ball, G1, true);
%        %RP.Blue(1).rul = attack(RP.Blue(5), RP.Ball, G1, RP.Blue(1).isBallInside);
%        for i = [2, 5]
%            RP.Blue(i).rul = MoveToLinear(RP.Blue(i), RP.Blue(i).z + [500, 0], 0, 20, 0);
%        end
       %RP.Blue(1).rul = RotateToLinear(RP.Blue(5), G1, 5, 0, 0.1);
       
%        RP.Blue(1).rul = MoveToPD(RP.Blue(1), G1 , minSpeed, P, D, vicinity);
%        RP.Blue(2).rul = MoveToPD(RP.Blue(2), G1 + 600 * V, minSpeed, P, D, vicinity);
%        RP.Blue(3).rul = MoveToPD(RP.Blue(3), G2 , minSpeed, P, D, vicinity);
%        RP.Blue(4).rul = MoveToPD(RP.Blue(4), G2 - 600 * V, minSpeed, P, D, vicinity);
%         [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
%         %RP.Blue(3).rul = Crul(0, 0, 0, 0, 1);
%         if (r_dist_points(RP.Blue(5).z, RP.Ball.z) < 1000)
%             RP.Blue(5).rul = optDirGoalAttack(RP.Blue(5), RP.Ball, RP.Blue(6), G1, V);
%         end
%         RP.Blue(6).rul = GoalKeeperOnLine(RP.Blue(6), G1, V, BPosHX, BPosHY, ballStanding, ballSpeed);
    aimPoint = RP.Ball.z;
    aimVicinity = 300;
    agent = RP.Blue(5);
    RP.Blue(5).rul = MoveToWithFastBuildPath(agent, aimPoint, aimVicinity, obstacles([1: 4, 6], :));
        
%         atackerid = 5;
%         keeperid = 6;
%         
%         agent = RP.Blue(atackerid);
%         ball = RP.Ball;
%         oppCom = RP.Blue(keeperid);%[1: atackerid - 1, atackerid + 1: 6]);
% %                 
%         [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
%         %disp([fastMoving, ballStanding, saveDir]);
%         %disp(ballStanding);
%         if r_dist_points(G2, ball.z) < 1000
%             %RP.Blue(id).rul = attack(RP.Blue(id), RP.Ball, G2);
%             RP.Blue(atackerid).rul = optDirGoalAttack(agent, ball, oppCom, G1, V);
%         end
%         RP.Blue(atackerid).rul.KickVoltage = 9;
%         
%         RP.Blue(keeperid).rul = GoalKeeperOnLine(RP.Blue(keeperid), G1, V, BPosHX, BPosHY, ballStanding, ballSpeed);
        %RP.Blue(2).rul = optDirGoalAttack(agent, ball, oppCom, G2, -V);
            
       %RP.Blue(3).rul = Crul(20, 0, 0, 0, 0);
    case 1
        %[RP.Blue(8).rul, RP.Blue(5).rul, RP.Blue(3).rul] = goalKeeperAgainstTwoAttakers(RP.Blue(8), RP.Blue(5), RP.Blue(3), RP.Ball, G, V, ballInside);
        %RP.Blue(8).rul = GoalKeeperOnLine(RP.Blue(8), RP.Ball, G + 250 * V, V)
%         if (RP.Blue(8).I && RP.Ball.I)
%             RP.Blue(8).rul = attack(RP.Blue(8), RP.Ball, RP.Blue(2).z, ballInside);
%         end
        %if (RP.Blue(4).x > border1(1) &&  RP.Blue(4).x < border2(1) && RP.Blue(4).y > border1(2) && RP.Blue(4).x < border2(2))
            %RP.Blue(4).rul = MoveToWithFastBuildPath(RP.Blue(4), [-1.3212e+03 -110.5675], 150, obstacles);
        %else 
            %RP.Blue(4).rul = Crul(0, 0, 0, 0, 0);
        %end
%         cmd1 = [7 2];
%         cmd2 = [3 8];
%         [ballFastMoving, ballSaveDir, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
%         %RP.Blue(cmd1(2)).rul = receiveBall(RP.Blue(cmd1(2)), BPosHX, BPosHY);
%         [RP.Blue(cmd1(1)).rul, RP.Blue(cmd1(2)).rul] = STPGame2by2FirstCom(RP.Ball, BPosHX, BPosHY, ballFastMoving, ballSaveDir, RP.Blue(cmd1), RP.Blue(cmd2), G1, G2, V, -V, ballInside);
%         [RP.Blue(cmd2(1)).rul, RP.Blue(cmd2(2)).rul] = STPGame2by2SecondCom(RP.Ball, BPosHX, BPosHY, ballFastMoving, ballSaveDir, RP.Blue(cmd2), RP.Blue(cmd1), G2, G1, -V, V, ballInside);
        %k = 4;
        %RP.Blue(k).rul = MoveToWithFBPPlusParam(RP.Blue(k), [-5000, 0], 100, obstacles([1:k-1, k+1:BCnt], :));
        %RP.Blue(4).rul = distAttack(RP.Blue(4), RP.Ball, [-5000, 1000]);
        %RP.Blue(3).rul = MoveToLinear(RP.Blue(3), [0, 0], 1/2000, 10, 100);
        %RP.Blue(2).rul = Crul(0, -15, 0, 0, 0);
         
%         RP.Blue(2).rul = MoveToWithFBPPlusParam(RP.Blue(2), G1 + 600 * V, 100, obstacles([1, 3:8], :));
%         RP.Blue(3).rul = MoveToWithFBPPlusParam(RP.Blue(3), G2, 100, obstacles([1, 2, 4:8], :));
%         RP.Blue(4).rul = MoveToWithFBPPlusParam(RP.Blue(4), G2 - 600 * V, 100, obstacles([1:3, 5:8], :));
        atackerid = 4;
        agent = RP.Blue(atackerid);
        aimPoint = G2;
        coef = 0;
        minSpeed = 30;
        vicinity = 30;
        RP.Blue(atackerid).rul = MoveToWithFBPPlusParam(RP.Blue(atackerid), aimPoint, vicinity, obstacles([1:atackerid-1, atackerid+1:8], :));
    case 2

        %RP.Blue(8).rul = GoalKeeperOnLine(RP.Blue(8), RP.Ball, G + 150 * V, V);
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
        
   
%         id = 2;
%         agent = RP.Blue(id);
%         ball = RP.Ball;
%         aim = G2;
%         dst = 650;
%         Pnt1 = [-2141 -579];
%         Pnt2 = [-255 -1202];
%         nSpeed = 70;
%         
%         if r_dist_points(G1, RP.Blue(4).z) < dst
%             if r_dist_points(G1, ball.z) > dst * 0.5
%                 RP.Blue(4).rul = moveWithBall(RP.Blue(4), ball, G1); 
%             else
%                 RP.Blue(4).rul = MoveToLinear(RP.Blue(4), Pnt1, 0, nSpeed, 150);
%             end
%             RP.Blue(2).rul = MoveToLinear(RP.Blue(2), Pnt2, 0, nSpeed, 150);
%         elseif r_dist_points(G1, ball.z) < dst
%             RP.Blue(id).rul = attack(agent, ball, aim);
%             RP.Blue(4).rul = MoveToLinear(RP.Blue(4), Pnt1, 0, nSpeed, 150);
%         else
%             RP.Blue(4).rul = moveWithBall(RP.Blue(4), ball, G1); 
%             RP.Blue(2).rul = MoveToLinear(RP.Blue(2), Pnt2, 0, nSpeed, 150);
%         end
%         RP.Blue(2).rul.KickVoltage = 12;
%         [fastMoving, ballStanding, saveDir, ballSpeed, BPosHX, BPosHY] = ballMovingManager(RP.Ball);
%         %disp([fastMoving, ballStanding, saveDir]);
%         if (~fastMoving)
%             disp('fastMoving');
%         end
        
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
        
%         for i=1:6
%             RP.Blue(i).rul.KickVoltage = 3;
%         end



%         if (RP.Blue(7).x > border1(1) &&  RP.Blue(7).x < border2(1) && RP.Blue(7).y > border1(2) && RP.Blue(7).x < border2(2) && RP.Ball.x > border1(1) && RP.Ball.x < border2(1) && RP.Ball.y > G(2) && RP.Ball.y < border2(2))
%             RP.Blue(7).rul = attack(RP.Blue(7), RP.Ball, G, ballInside);
%         else 
%             RP.Blue(7).rul = Crul(0, 0, 0, 0, 0);
%         end

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
      
%         %RP.Blue(3).rul = MoveToLinearShort(RP.Blue(3), G2, 30, 60/750, 100);
%         minSpeed = 25;
%         %P = 4/750;
%         %D = -1.5;
%         vicinity = 50;
%             
%         RP.Blue(2).rul = MoveToPD(RP.Blue(2), RP.Ball.z, minSpeed, 0, 0, vicinity);

%         G = [-59.0979 874.5902];
%         RP.Blue(4).rul = MoveToLinear(RP.Blue(3), G, 0, 25, 100);
        %[RP.Blue(2).rul, RP.Blue(3).rul, RP.Blue(4).rul] = goBaseStateForGoalKeeperAgainstTwoAttakers(RP.Blue(1), RP.Blue(2), RP.Blue(3), G1, V);
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
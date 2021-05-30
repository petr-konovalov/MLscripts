%Функция завершающая основную "main" функцию.
%Обязательная для функционирования структуры RP .
function zMain_End = mainEnd()
global RP Rules oldRules oldTime curTime oldSpeeds;
RP.zMain_End=true;
RP.WorkTime=toc(RP.T_timerH);
if isfield(RP,'WorkTimeMax');
    RP.WorkTimeMax=max(RP.WorkTimeMax,RP.WorkTime);
else
    RP.WorkTimeMax=RP.WorkTime;
end
zMain_End=RP.zMain_End;

if isempty(oldSpeeds)
	oldSpeeds = zeros(32, 2);
end

%{
for i=1:12
    if isempty(find(Rules(:,2)==i,1))
        for j=1:12
            if (RP.Yellow(j).Nrul==i)
                Rule(RP.Yellow(j).Nrul,RP.Yellow(j));
            else
                if (RP.Blue(j).Nrul==i)
                    Rule(RP.Blue(j).Nrul,RP.Blue(j));                    
                end
            end
        end
    end
end
%}

for k = 1: 16
	curSpeed = oldSpeeds(k, :);
	goalSpeed = [RP.Blue(k).rul.SpeedX, RP.Blue(k).rul.SpeedY];
	newSpeed = changeSpeed(RP.Blue(k), oldTime, curTime, curSpeed, goalSpeed);
	RP.Blue(k).rul.SpeedX = newSpeed(1);
	RP.Blue(k).rul.SpeedY = newSpeed(2);
	oldSpeeds(k, :) = newSpeed;

	curSpeed = oldSpeeds(k+16, :);
	goalSpeed = [RP.Yellow(k).rul.SpeedX, RP.Yellow(k).rul.SpeedY];
	newSpeed = changeSpeed(RP.Yellow(k), oldTime, curTime, curSpeed, goalSpeed);
	RP.Yellow(k).rul.SpeedX = newSpeed(1);
	RP.Yellow(k).rul.SpeedY = newSpeed(2);
	oldSpeeds(k+16, :) = newSpeed;
end

for i = 1 : 16
    Rule(i, RP.Blue(i));
    Rule(i+16, RP.Yellow(i));
end
oldRules = Rules;
oldTime = curTime;

global Modul;
if (norm(Rules)==0 && isempty(Modul)) 
    fprintf('Rules is clear! Use ''pairStart()''.\n');
end
end

%PAUSE
%������ � �������� ����� 
%�� ����� ����� Rule �� ������� ������
global RP Rules outBuffer;

%% ���������� ����������� �������
%pcode main.m;
Rules=zeros(size(Rules));
%����� �����.
RP.Pause=1-RP.Pause;
if (RP.Pause)
    fprintf('Pause = ON\n');
else
    fprintf('Pause = OFF\n');
end

%% ������� "����" �� ���� �������.
if (RP.Pause==1)
    Rules(1,:)=[2,1,0,0,0,0,0];
    Rules(2,:)=[1,0,0,0,0,0,0];
    Rules(3,:)=[1,0,0,0,0,0,0];
    Rules(4,:)=[1,0,0,0,0,0,0];
%     pause(0.1);
%     Rules(1,:)=[2,1,0,0,0,0,0];
%     Rules(2,:)=[1,0,0,0,0,0,0];
%     Rules(3,:)=[1,0,0,0,0,0,0];
%     Rules(4,:)=[1,0,0,0,0,0,0];
else
    Rules(1,:)=[2,1,0,0,0,0,0];
    %---------------------------------------------------
    outBuffer = zeros(1, 16);
    %---------------------------------------------------
end
%% ������������� main
RP.zMain_End=true;
main();
%% 
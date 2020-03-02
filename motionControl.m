function rul = motionControl(agent, command, param)
    persistent state;
    persistent aimPoint;
    persistent startPoint;
    persistent oldX;
    persistent intU;
    persistent oldU;
    persistent coef;
    persistent oldT;
    persistent startT;
    persistent aimX;
    STOP = 0;
    MOVING = 1;
    
    if isempty(state)
        state = zeros(1, 12);
    end
    if isempty(aimPoint)
        aimPoint = zeros(12, 2);
    end
    if isempty(coef)
        coef = ones(1, 12) * 0.01;
    end
    if isempty(startPoint)
        startPoint = zeros(12, 2);
    end
    if isempty(oldX)
        oldX = zeros(1, 12);
    end
    if isempty(intU)
        intU = zeros(1, 12);
    end
    if isempty(oldU)
        oldU = zeros(1, 12);
    end
    if isempty(oldT)
        oldT = zeros(1, 12);
    end
    if isempty(aimX)
        aimX = zeros(1, 12);
    end
    
    if strcmp(command, '') == 0
        if strcmp(command, 'moving start')
            state(agent.id) = MOVING;
            aimPoint(agent.id, :) = param;
            startPoint(agent.id, :) = agent.z;
            oldX(agent.id) = 0;
            intU(agent.id) = 0;
            oldU(agent.id) = 10;
            oldT(agent.id) = cputime();
            startT(agent.id) = oldT(agent.id);
            aimX(agent.id) = r_dist_points(param, agent.z)*0.001;
            disp('moving start');
        elseif strcmp(command, 'moving stop')
            state(agent.id) = STOP;
        end
    end
    
    switch state(agent.id)
        case STOP
            rul = Crul(0, 0, 0, 0, 0);
        case MOVING
            MinT = 0.030;
            curT = cputime();
            if curT - oldT(agent.id) < MinT
                U = oldU(agent.id);
            else
                intU(agent.id) = intU(agent.id) + oldU(agent.id) * (curT - oldT(agent.id));
                forgCoef = 0.003;
                if agent.I ~= 0
                    curX = r_dist_points(agent.z, startPoint(agent.id))*0.001;
                    if intU(agent.id) ~= 0
                        coef(agent.id) = (1 - forgCoef) * coef(agent.id) + forgCoef * curX / intU(agent.id);
                    end
                else
                    curX = oldX(agent.id) + coef(agent.id) * oldU(agent.id) * (curT - oldT(agent.id));
                end
                maxV = 1;
                maxA = 3;
                cV = 3;
                T = curT - startT(agent.id);
                %disp(T);
                dXr = getTrapetzoidMotionVelocity(T, maxV, maxA, aimX(agent.id));
                Xr = getTrapetzoidMotionPoint(T, maxV, maxA, aimX(agent.id));
                U = min(max((dXr + (Xr-curX)*cV)/coef(agent.id), 0), 100);
                oldT(agent.id) = curT;
                oldX(agent.id) = curX;
                oldU(agent.id) = U;
            end
            
            disp(coef(agent.id));
            disp(U)
            v = aimPoint(agent.id, :) - agent.z;     %vector to aim
            v = v / norm(v);
            u = [cos(agent.ang), sin(agent.ang)];
            SpeedY = -v(2)*u(1)+v(1)*u(2);          %speed on axis X 
            SpeedX = +v(1)*u(1)+v(2)*u(2);
            if agent.I ~= 0
                rotRul = RotateToLinear(agent, aimPoint(agent.id, :), 5, 10, 0.1);
            else
                rotRul = Crul(0, 0, 0, 0, 0);
            end
            rul = Crul(U * SpeedX, U * SpeedY, 0, rotRul.SpeedR, 0);
    end
end
function [ruls1, ruls2] = goToGameStartingConfiguration(coms, G1, V1, G2, V2, width, ball, obstacles, normalSpeed)
	if nargin <= 8
		normalSpeed = 10;
	end
	ruls1 = getEmptyRuls(size(coms, 2));
	ruls2 = getEmptyRuls(size(coms, 2));
	Pnt = zeros(6, 2);
	Pnt(1, :) = -V1 * 1000 - [V1(2), -V1(1)] * width * 0.5 * 0.15;
	Pnt(2, :) = -V1 * 1000 + [V1(2), -V1(1)] * width * 0.5 * 0.15;
	Pnt(3, :) = -V1 * 2500;
	Pnt(4, :) = -V1 * 2000 - [V1(2), -V1(1)] * width * 0.5 * 0.35;
	Pnt(5, :) = -V1 * 2000 + [V1(2), -V1(1)] * width * 0.5 * 0.35;
	Pnt(6, :) = G1 + V1 * 500;
		
	Pnt(7, :) = -V2 * 1000 - [V2(2), -V2(1)] * width * 0.5 * 0.15;
	Pnt(8, :) = -V2 * 1000 + [V2(2), -V2(1)] * width * 0.5 * 0.15;
	Pnt(9, :) = -V2 * 2500;
	Pnt(10, :) = -V2 * 2000 - [V2(2), -V2(1)] * width * 0.5 * 0.35;
	Pnt(11, :) = -V2 * 2000 + [V2(2), -V2(1)] * width * 0.5 * 0.35;
	Pnt(12, :) = G2 + V2 * 500;
	for k = 1: 6
	    if r_dist_points(coms(1, k).z, ball.z) > 500
	    	ruls1(k)  = MoveToWithFastBuildPath(coms(1, k), Pnt(k, :), 90, obstacles, normalSpeed);
	    else
	    	vec = normir(coms(1, k).z - ball.z)*1000;
	    	ruls1(k)  = MoveToWithFastBuildPath(coms(1, k), coms(1, k).z + vec, 90, obstacles, normalSpeed);
	    end	
	    if r_dist_points(coms(2, k).z, ball.z) > 500
	    	ruls2(k)  = MoveToWithFastBuildPath(coms(2, k), Pnt(k+6, :), 90, obstacles, normalSpeed);
	    else
	    	vec = normir(coms(2, k).z - ball.z)*1000;
	    	ruls2(k)  = MoveToWithFastBuildPath(coms(2, k), coms(2, k).z + vec, 90, obstacles, normalSpeed);
	    end
	end
end

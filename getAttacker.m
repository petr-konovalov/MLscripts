function res = getAttacker(com, ball)
	res = 1;
	for k = 1: size(com, 2)
		if com(k).I ~= 0
			res = k;
			break;
		end
	end
	for k = 1: size(com, 2) - 1
		if (com(k).I ~= 0 && r_dist_points(com(res).z, ball.z) > r_dist_points(com(k).z, ball.z))
		    res = k;
		end
	end
end

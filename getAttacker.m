function res = getAttacker(com, ball)
	res = 1;
	for k = 2: size(com, 2) - 1
		if (r_dist_points(com(res).z, ball.z) > r_dist_points(com(k).z, ball.z))
		    res = k;
		end
	end
end

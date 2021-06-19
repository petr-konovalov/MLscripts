function res = getNearestAgentToPoint(com, pnt)
	res = 1;
	for k = 2: size(com, 2)
		if (r_dist_points(com(res).z, pnt) > r_dist_points(com(k).z, pnt))
		    res = k;
		end
	end
end

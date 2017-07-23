# list issues status
#
# Copyright (C) 2000, Gray Research LLC.  All rights reserved.
# The contents of this file are subject to the XSOC License Agreement;
# you may not use this file except in compliance with this Agreement.
# See the LICENSE file.
#
# usage: awk -f issues.awk <issues

/^Issue:/ {
	issue = $2;
	t="";
	for (i = 5; i <= NF; i++)
		t=t $i " ";
	type[issue] = $3;
	area[issue] = $4;
	title[issue] = t;
	if (maxissues < issue)
		maxissues = issue;
}
/^Opened:/ {
	date[issue] = $2;
	who[issue] = $3;
	opendate[issue] = $2;
	opener[issue] = $3;
	state[issue] = "open";
}
/^Owner:/ {
	date[issue] = $2;
	who[issue] = $3;
	owndate[issue] = $2;
	owner[issue] = $3;
	state[issue] = "assigned";
}
/^Resolv:/ {
	date[issue] = $2;
	who[issue] = $4;
	resdate[issue] = $2;
	resver[issue] = $3;
	resolver[issue] = $4;
	state[issue] = "resolved";
}
/^Closed:/ {
	date[issue] = $2;
	who[issue] = $3;
	closedate[issue] = $2;
	closer[issue] = $3;
	state[issue] = "closed";
}
END {
	split("open assigned resolved closed", states);
	for (is = 1; is <= 4; is++) {
		s = states[is];

		n = 0;
		for (i = 0; i <= maxissues; i++)
			if (state[i] == s)
				++n;
		print s " issues (" n "): ";

		for (i = 0; i <= maxissues; i++) {
			if (state[i] == s)
				printf("%3d %-8.8s %-8.8s %s\n", i, type[i], area[i], title[i]);
		}
		print "";
	}
}

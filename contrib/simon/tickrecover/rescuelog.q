/ rescue tickerplant logfile after crash 
/ for kdb+ 2.4 or later 
"kdb+rescuelog 0.3 2008.09.05"

validate:{-1<@[-11!;(-2;x);-1]}
goodtil:{I::0;
	upd::{[x;y]I+:1;};
	(@[-11!;x;{[x;y]I}x];x)}
rescue:{rfn::hsym` sv(`$1_string last x),`rescue;
	rfn 1:();hdel rfn;
	upd::{[x;y].[rfn;();,;enlist(`upd;x;y)]};
	(-11!x;rfn)}

\
to quickly check if a logfile is valid run:
validate`:logfilename.log
to count valid records from the beginning of a logfile run:
goodtil`:logfilename.log
to create a new logfile with name <logfilename>.rescue containing all the valid data:
rescue goodtil`:logfilename.log

duplicate the <upd> definitions with the names of other messages found in the logfile if need be:
upd2::{[x;y].[rfn;();,;enlist(`upd2;x;y)]}; / for rescue - note two occurences of <upd2>
or
upd2::{[x;y]I+:1;}; / for goodtil 

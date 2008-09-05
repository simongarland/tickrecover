/ rescue tickerplant logfile after crash 
"kdb+rescuelog 0.2 2006.01.03"
if[not any `walk`rescue`check in key o:.Q.opt .z.x;
	-2"usage:\n>q ",(string .z.f)," -check logfilename\nor\n>q ",(string .z.f)," -walk logfilename\n**crash**\nfollowed by:\n>q ",(string .z.f)," -rescue\n";
	exit 1]

LFI:`:lfi.tmp;LFN:`:lfn.tmp
UPDW:{[x;y]};UPDR:{[x;y].[rfn;();,;enlist(`upd;x;y)]}

walk:{[file]
	if[`~file;-2"? missing logfilename";exit 1];
	LFN 1: string file:hsym file;LFI 1:i:0;upd::UPDW;
	while[i=-11!(i;file);LFI 1: i;i+:1];
	-2"? logfile is not corrupt";}

check:{[file]
	if[`~file;-2"? missing logfilename";exit 1];
	file:hsym file;upd::UPDW;
	-11!file;
	-2"* logfile ok";} 

rescue:{lfi:256 sv reverse`int$read1 LFI;
	lfn:`$"c"$read1 LFN;rfn::hsym` sv(`$1_string lfn),`rescue;
	rfn 1:();hdel rfn;
	upd::UPDR;-11!(lfi;lfn);upd::UPDW;
	hdel LFI;hdel LFN;
	(lfi;rfn)}

if[`check in key o;
	check`$first o`check]
if[`walk in key o;
	walk`$first o`walk]
if[`rescue in key o;
	0N!rescue[]]
\\
to quickly check if a logfile is valid run:
q rescuelog.q -check corruptlogfile
to find valid records from the beginning of a logfile run:
q rescuelog.q -walk corruptlogfile
this walks through the logfile until bad data is hit. After crash run:
q rescuelog.q -rescue 
to create a new logfile with name <corruptlogfile>.rescue containing all the valid data

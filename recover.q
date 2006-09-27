/ recover from tickerplant crash
/ this script writes out a logfile to be replayed and a script to do the replay 
"kdb+recovertick 0.5 2006.09.27"
o:.Q.opt .z.x;if[2>count .Q.x;-2">q ",(string .z.f)," REMOTERDB LOCALRDB";exit 1]

rrdb:hopen hsym`$.Q.x[0];lrdb:hopen hsym`$.Q.x[1]
out:{x y;};output:out[-1]
output "recovering rdb server ",.Q.x[1]," from ",.Q.x[0]

/ only recover tables with a `time and `sym column
lt:lrdb({t where {all `time`sym in cols x}each t:tables`.};())
/ use the first table to find data-holes
lm:lrdb({exec distinct time.minute from value x};first lt)
rm:rrdb({exec distinct time.minute from value x};first lt)
missing:rm except lm
if[not count missing;-2"no data holes found";exit 1]
/ add slack
missing:asc distinct raze missing+/:-1 0 1 / -2 -1 0 1 2

/ recovery filenames
scriptfileh:hopen scriptfile:hsym`$"recover",(string`date$.z.z),".q"
if[hcount scriptfile;-2"recovery script not empty";exit 1]
script:out[neg scriptfileh]
logfile:hsym`$1_-2_string scriptfile
logfileh:hopen .[logfile;();:;()]
pwd:{$[.z.o in`w32`w64;p,0#p[where"\\"=p:value"\\cd"]:"/";value"\\cd"]}

output (string count missing)," minutes missing between ",(string first missing)," and ",string last missing
output "recovering tables: ",1_raze",",'string lt

/ fetch data by table, by minute and write to logfile between each retrieval
/ so as not to overload the rrdb, allowing other tasks to get a look in 
k)logdata:{[l;t;d]if[#d;l@,(`upd;t;.+d)];}
i:0
do[count lt;selectfn:{[x;y] select from (value x) where time.minute=y};j:0;
	do[count missing;
		logdata[logfileh;lt[i];rrdb(selectfn;lt[i];missing[j])];
		j+:1];i+:1]

script "/ execute:"
script "/ q)\\l ",fullscriptfile:pwd[],"/",1_string scriptfile
script "/ in crashed rdb to recover"
script "tmp:-1(string .z.Z),\" recovery started\""
script "if[not ",(string`date$.z.z ),"=`date$.z.z;'`invalid.date]"
script "if[not `",(string .z.h ),"=.z.h;'`invalid.host]"
script "tmp:-11!(-2;hsym`$\"",(fulllogfile:pwd[],"/",1_string logfile),"\") / check found"
script "missing:`s#",1_raze" ",'string missing
/ clear the group index on `sym columns
script {"tmp:update `#sym from `",string x}each lt
script {"tmp:delete from `",(string x)," where time.minute in missing"}each lt
script "tmp:-11!(-1;hsym`$\"",fulllogfile,"\")"
/ sort by time, as if it had come in normally
script {(string x),":`time xasc ",string x}each lt
/ restore `g# on `sym
script {"tmp:update `g#sym from `",string x}each lt
script "tmp:-1(string .z.Z),\" recovery complete\""

output "logfile: ",fulllogfile
output "recovery script: ",1_string scriptfile
output ""
output "execute:"
output "q)\\l ",fullscriptfile
output "in crashed rdb to recover"
\\
steps to recover from a server crash:
1) get the server fully back on the air, everything running fine - just some data missing
2) run this script on the server that crashed, ensure there is space for the recovery logfile
eg: c:\k4>q recover.q remoteserver:5011 localhost:5011
3) run the recovery script generated in #2 above in the rdb on the server that crashed
eg: q)\l ../../recover2005.02.07.q
4) delete the recovery script and logfile after dayend has run successfully
notes:
it's safe to rerun the recovery script
the main logfile is not touched, you need that AND the recovery logfile until after dayend

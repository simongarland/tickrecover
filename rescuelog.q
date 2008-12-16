/ rescue tickerplant logfile after crash 
/ for kdb+ 2.4 or later 
"kdb+rescuelog 0.4 2008.09.22"

lreplay:{-11!(-1;x)}
lgoodtil:{-11!(-2;x)}
lgooditems:{first lgoodtil x} 
lgoodcount:{last lgoodtil x}
lcount:hcount 
lvalid:{(lcount x)=lgoodcount x}
lreplaygood:{-11!(lgooditems x;x)}
dummyupd:{[x;y]}
/ upd:dummyupd


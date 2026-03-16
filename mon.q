/ Monitoring

.qi.import`cron

.mon.t:`sym xkey .schemas.t.Monitor
.mon.record:insert
.mon.getsize:{[p] $[.qi.exists p;hcount p;0]}

.mon.follow:{[p] `.mon.t upsert `time`sym`status`size!(.z.p;p;`following;.mon.getsize p);}
.mon.pause:{[p] update status:`paused from`.mon.t where sym=p;}

.mon.monitor:{
  if[not count a:select from .mon.t where status=`following;:()];
  a:update nsize:.mon.getsize each sym from a;
  $[count a:select from a where size<>nsize;now:.z.p;:()];
  `.mon.t upsert delete nsize from update time:now,size:nsize from a;
  a:update jump:.conf.MON_MAX_LOG_CHUNK&nsize-size from a;
  r:get flip ungroup select time:now,sym,lines:{read0(x;y;z)}'[sym;nsize-jump;jump]from a;
  .mon.record[`MonText;r];
  }

/ 
startstop:{[status;p]
  if[null(e:MonRegistry p)`status;'.qi.tostr[p]," not found in MonRegistry"];
  `MonRegistry[p]:@[e;`status;:;status];
  }

pausefollow:startstop`following
stop:startstop`stopped
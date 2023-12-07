#!/bin/bash

##############################
# 1. Prepare directory
##############################
mkdir -p /home/gpadmin/diag/diaglog
mkdir -p /home/gpadmin/diag/csv

##############################
# 2. Prepare hostfile
##############################
psql -Atc "select distinct(hostname) from gp_segment_configuration where content = -1 order by hostname;" >> /home/gpadmin/diag/hostfile_master
psql -Atc "select distinct(hostname) from gp_segment_configuration where content != -1 order by hostname;" >> /home/gpadmin/diag/hostfile_seg
psql -Atc "select distinct(hostname) from gp_segment_configuration order by hostname;" >> /home/gpadmin/diag/hostfile_all

##############################
# 3. Parameter assessment
##############################
sh /home/gpadmin/diag/diag_os.sh
sh /home/gpadmin/diag/diag_gpdb.sh

##############################
# 4. DB upgrade assessment
##############################
sh /home/gpadmin/diag/diag_gpupgrade.sh

##############################
# 5. System resource utilization assessment
##############################
sh /home/gpadmin/diag/chk_bloat_catalog.sh
sh /home/gpadmin/diag/chk_bloat_table.sh
sh /home/gpadmin/diag/chk_skew.sh
sh /home/gpadmin/diag/diag_perf_dbstatus.sh
sh /home/gpadmin/diag/diag_perf_resource.sh

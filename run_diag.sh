#!/bin/bash

echo "##############################"
echo "# 1. Prepare directory"
echo "##############################"
mkdir -p /home/gpadmin/diag/diaglog
mkdir -p /home/gpadmin/diag/csv

echo "##############################"
echo "# 2. Prepare hostfile"
echo "##############################"
psql -Atc "select hostname from gp_segment_configuration where content = -1 order by dbid;" > /home/gpadmin/diag/hostfile_master
psql -Atc "select distinct(hostname) from gp_segment_configuration where content != -1 order by hostname;" > /home/gpadmin/diag/hostfile_seg
psql -Atc "select distinct(hostname) from gp_segment_configuration order by hostname;" > /home/gpadmin/diag/hostfile_all

echo "##############################"
echo "# 3. Parameter assessment"
echo "##############################"
sudo sh /home/gpadmin/diag/1_diag_os.sh
sh /home/gpadmin/diag/2_diag_gpdb.sh

echo "##############################"
echo "# 4. DB upgrade assessment"
echo "##############################"
sh /home/gpadmin/diag/3_diag_gpupgrade.sh

echo "##############################"
echo "# 5. System resource utilization assessment"
echo "##############################"
sh /home/gpadmin/diag/4_chk_bloat_catalog.sh
sh /home/gpadmin/diag/5_chk_bloat_tables.sh
sh /home/gpadmin/diag/6_chk_skew.sh
sh /home/gpadmin/diag/7_diag_perf_dbstatus.sh
sh /home/gpadmin/diag/8_diag_perf_resource.sh

#!/bin/bash

##############################
# 0. Prepare hostfile
##############################

mkdir -p /home/gpadmin/diag
psql -Atc "select distinct(hostname) from gp_segment_configuration where content = -1 order by hostname;" >> /home/gpadmin/diag/hostfile_master
psql -Atc "select distinct(hostname) from gp_segment_configuration where content != -1 order by hostname;" >> /home/gpadmin/diag/hostfile_seg
psql -Atc "select distinct(hostname) from gp_segment_configuration order by hostname;" >> /home/gpadmin/diag/hostfile_all



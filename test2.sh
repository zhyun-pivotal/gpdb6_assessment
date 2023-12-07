#!/bin/bash

##############################
# 0. Prepare hostfile
##############################

mkdir -p /home/gpadmin/diag/diaglog
mkdir -p /home/gpadmin/diag/csv

psql -Atc "select distinct(hostname) from gp_segment_configuration where content = -1 order by hostname;" >> /home/gpadmin/diag/hostfile_master
psql -Atc "select distinct(hostname) from gp_segment_configuration where content != -1 order by hostname;" >> /home/gpadmin/diag/hostfile_seg
psql -Atc "select distinct(hostname) from gp_segment_configuration order by hostname;" >> /home/gpadmin/diag/hostfile_all

export LOGPATH=/home/gpadmin/diag/diaglog
export LOGFILE=$LOGPATH/perf_gpdb.$(date '+%Y%m%d_%H%M')
export HOSTFILESEG=/home/gpadmin/diag/hostfile_seg

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 1. GPDB DATABASE LIST & SIZE" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT * FROM gp_toolkit.gp_resgroup_status_per_segment;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 2. TABLE LIST " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT * FROM pg_catalog.pg_tables WHERE schemaname NOT IN ('gp_toolkit', 'information_schema', 'pg_catalog','pg_aoseg','pg_toast') order by 1,2;" >> ${LOGFILE}
psql -c "SELECT b.nspname , relname, c.relkind,c.relstorage FROM pg_class c,pg_namespace b WHERE c.relnamespace=b.oid and b.nspname NOT IN ('gp_toolkit', 'information_schema', 'pg_catalog','pg_aoseg','pg_toast') AND relname NOT LIKE '%_1_prt_%' ORDER BY b.nspname,c.relkind,c.relstorage;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 3. SCHEMA SIZE " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "select schemaname ,round(sum(pg_total_relation_size(schemaname||'.'||tablename))/1024/1024) "schema_size_MB" from pg_tables WHERE schemaname NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')  group by 1;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 4. SCHEMA SIZE " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT SCHEMA,table_name,relkind,relstorage,SIZE/1024/1024 AS size_mb FROM gpmetrics.gpcc_size_ext_table
WHERE SCHEMA NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')
ORDER BY 1,2,3,4,5 DESC;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 5. BUSY TABLE LIST " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT SCHEMA,table_name,relkind,relstorage,SIZE/1024/1024 AS size_mb FROM gpmetrics.gpcc_size_ext_table
WHERE SCHEMA NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')
ORDER BY 1,2,3,4,5 DESC;

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 6. DISK USAGE Percents by One Hour" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "
SELECT to_timestamp(floor((extract('epoch' from ctime) / 3600 )) * 3600) AT TIME ZONE 'Asia/Seoul' as interval_alias,
hostname,
filesystem,
round (MIN(bytes_used) / AVG(total_bytes) * 100 ,2) AS min_disk_usage_per,
round (AVG(bytes_used) / AVG(total_bytes) * 100 ,2) AS avg_disk_usage_per,
round (MAX(bytes_used) / AVG(total_bytes) * 100 ,2)  AS max_disk_usage_per
FROM  gpmetrics.gpcc_disk_history
GROUP BY interval_alias, hostname, filesystem
ORDER BY 1,2,3;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 7. ERROR MESSAGES " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SSELECT logmessage, count(*) FROM gpmetrics.gpcc_pg_log_history GROUP BY 1 ORDER BY 2 DESC LIMIT 30;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 8. Frequency SQL (Top 50)  " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT query_text,count(*) FROM gpmetrics.gpcc_queries_history WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
  AND ctime < CURRENT_DATE GROUP BY query_text ORDER BY 2 DESC LIMIT 50;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 9. Running Timed SQL (Top 100)  " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT db,username,query_text,avg (tfinish-tstart),max (tfinish-tstart) FROM gpmetrics.gpcc_queries_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
and db not in('gpperfmon','template1')
GROUP BY db,username,query_text ORDER BY 4 DESC LIMIT 100;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 10. Partitioned table List " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "select schemaname,tablename,partitiontype,count(partitiontablename) as total_no_of_partitions from pg_partitions group by tablename, schemaname,partitiontype ORDER BY 1,2;
" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 11. System Resource Usages Raw data to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(
SELECT *
FROM gpmetrics.gpcc_system_history
where ctime >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_all_15s.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 12. System Resource Usages each 1 Minute to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(
SELECT to_timestamp(floor((extract('epoch' from ctime) / 60 )) * 60) AT TIME ZONE 'Asia/Seoul' as interval_alias,
-- hostname,
round(avg(cpu_user)) AS max_cpu_user,
round(avg(cpu_sys)) AS max_cpu_sys,
round(avg(round(100 - cpu_idle))) AS avg_total_cpu_usage,
max(round(100 - cpu_idle)) AS max_total_cpu_usage,
round(avg(mem_used/1024/1024)) AS avg_mem_used_mb,
max(mem_used/1024/1024) AS max_mem_used_mb,
max(mem_total/1024/1024) AS mem_total_mb,
round(avg(swap_used/1024/1024)) AS avg_swap_used_mb,
max(swap_used/1024/1024) AS max_swap_used_mb,
max(swap_total/1024/1024) AS swap_total_mb,
round(avg(disk_rb_rate/1024/1024)) AS avg_disk_read_mb,
max(disk_rb_rate/1024/1024) AS max_disk_read_mb,
round(avg(disk_wb_rate/1024/1024)) AS avg_disk_write_mb,
max(disk_wb_rate/1024/1024) AS max_disk_write_mb,
round(avg(net_rb_rate/1024/1024)) AS avg_nw_read_mb,
max(net_rb_rate/1024/1024) AS max_nw_read_mb,
round(avg(net_wb_rate/1024/1024)) AS avg_nw_write_mb,
max(net_wb_rate/1024/1024) AS max_nw_write_mb
FROM gpmetrics.gpcc_system_history
WHERE hostname NOT IN ('mdw','smdw')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_1M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 13. System Resource Usages each 10 Minutes to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(
SELECT to_timestamp(floor((extract('epoch' from ctime) / 600 )) * 600) AT TIME ZONE 'Asia/Seoul' as interval_alias,
-- hostname,
round(avg(cpu_user)) AS max_cpu_user,
round(avg(cpu_sys)) AS max_cpu_sys,
round(avg(round(100 - cpu_idle))) AS avg_total_cpu_usage,
max(round(100 - cpu_idle)) AS max_total_cpu_usage,
round(avg(mem_used/1024/1024)) AS avg_mem_used_mb,
max(mem_used/1024/1024) AS max_mem_used_mb,
max(mem_total/1024/1024) AS mem_total_mb,
round(avg(swap_used/1024/1024)) AS avg_swap_used_mb,
max(swap_used/1024/1024) AS max_swap_used_mb,
max(swap_total/1024/1024) AS swap_total_mb,
round(avg(disk_rb_rate/1024/1024)) AS avg_disk_read_mb,
max(disk_rb_rate/1024/1024) AS max_disk_read_mb,
round(avg(disk_wb_rate/1024/1024)) AS avg_disk_write_mb,
max(disk_wb_rate/1024/1024) AS max_disk_write_mb,
round(avg(net_rb_rate/1024/1024)) AS avg_nw_read_mb,
max(net_rb_rate/1024/1024) AS max_nw_read_mb,
round(avg(net_wb_rate/1024/1024)) AS avg_nw_write_mb,
max(net_wb_rate/1024/1024) AS max_nw_write_mb
FROM gpmetrics.gpcc_system_history
WHERE hostname NOT IN ('mdw','smdw')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 14. System Resource Usages each 1 Hour to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(
SELECT to_timestamp(floor((extract('epoch' from ctime) / 3600 )) * 3600) AT TIME ZONE 'Asia/Seoul' as interval_alias,
-- hostname,
round(avg(cpu_user)) AS max_cpu_user,
round(avg(cpu_sys)) AS max_cpu_sys,
round(avg(round(100 - cpu_idle))) AS avg_total_cpu_usage,
max(round(100 - cpu_idle)) AS max_total_cpu_usage,
round(avg(mem_used/1024/1024)) AS avg_mem_used_mb,
max(mem_used/1024/1024) AS max_mem_used_mb,
max(mem_total/1024/1024) AS mem_total_mb,
round(avg(swap_used/1024/1024)) AS avg_swap_used_mb,
max(swap_used/1024/1024) AS max_swap_used_mb,
max(swap_total/1024/1024) AS swap_total_mb,
round(avg(disk_rb_rate/1024/1024)) AS avg_disk_read_mb,
max(disk_rb_rate/1024/1024) AS max_disk_read_mb,
round(avg(disk_wb_rate/1024/1024)) AS avg_disk_write_mb,
max(disk_wb_rate/1024/1024) AS max_disk_write_mb,
round(avg(net_rb_rate/1024/1024)) AS avg_nw_read_mb,
max(net_rb_rate/1024/1024) AS max_nw_read_mb,
round(avg(net_wb_rate/1024/1024)) AS avg_nw_write_mb,
max(net_wb_rate/1024/1024) AS max_nw_write_mb
FROM gpmetrics.gpcc_system_history
WHERE hostname NOT IN ('mdw','smdw')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 15. Resource Group & User Mappings " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT rolname, rsgname FROM pg_roles, pg_resgroup  WHERE pg_roles.rolresgroup=pg_resgroup.oid;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 16. Resource Group Usages Raw data to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(SELECT *
FROM gpmetrics.gpcc_resgroup_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY 1,2) TO '/home/gpadmin/diag/csv/rsg_all_15s.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 17. Resource Group Usages each 1 Minute to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "COPY(
SELECT to_timestamp(floor((extract('epoch' from ctime) / 60 )) * 60) AT TIME ZONE 'Asia/Seoul' as interval_alias,
rsgname,
avg(cpu_usage_percent) AS cpu_avg_per,
max(cpu_usage_percent) AS cpu_max_per,
max(concurrency_limit) AS concurrency_limit,
avg(num_queueing) AS avg_num_queue,
max(num_queueing) AS max_num_queue,
avg(mem_used_mb) AS avg_used_mb,
max(mem_used_mb) AS max_used_mb
FROM gpmetrics.gpcc_resgroup_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
and segid != '-1'
GROUP BY 1,2
ORDER BY 1,2 ) TO '/home/gpadmin/diag/rsg_seg_1M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 18. Resource Group Usages each 10 Minute to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT to_timestamp(floor((extract('epoch' from ctime) / 600 )) * 600) AT TIME ZONE 'Asia/Seoul' as interval_alias,
rsgname,
avg(cpu_usage_percent) AS cpu_avg_per,
max(cpu_usage_percent) AS cpu_max_per,
max(concurrency_limit) AS concurrency_limit,
avg(num_queueing) AS avg_num_queue,
max(num_queueing) AS max_num_queue,
avg(mem_used_mb) AS avg_used_mb,
max(mem_used_mb) AS max_used_mb
FROM gpmetrics.gpcc_resgroup_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
and segid != '-1'
GROUP BY 1,2
ORDER BY 1,2) TO '/home/gpadmin/diag/rsg_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 19. Need for Table Analyze " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT relname from pg_class where reltuples=0 and relpages=0 and relkind='r' and relname not like 't%' and relname not like 'err%';" >> ${LOGFILE}

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 20. Replicated Mirror Segments status " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT gp_segment_id,client_addr,client_port,backend_start,state,sync_state,sync_error FROM pg_catalog.gp_stat_replication ORDER BY 1;" >> ${LOGFILE}

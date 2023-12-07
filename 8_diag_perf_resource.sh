#!/bin/bash
#mkdir -p /home/gpadmin/diag/diaglog
source /usr/local/greenplum-db/greenplum_path.sh
export LOGFILE=/home/gpadmin/diag/diaglog/diag_perf_resource.$(date '+%Y%m%d_%H%M')
export MDWNM=`sed -n '1p' /home/gpadmin/diag/hostfile_master`
export SMDWNM=`sed -n '2p' /home/gpadmin/diag/hostfile_master`

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 11. System Resource Usages Raw data to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
SELECT *
FROM gpmetrics.gpcc_system_history
where ctime >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_all_15s.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 12. System Resource Usages each 1 Minute to CSV file - Segment" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
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
WHERE hostname NOT IN ('${MDWNM}','${SMDWNM}')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_1M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 13. System Resource Usages each 10 Minutes to CSV file - Segment" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
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
WHERE hostname NOT IN ('${MDWNM}','${SMDWNM}')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 14. System Resource Usages each 1 Minute to CSV file - Master" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
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
WHERE hostname IN ('${MDWNM}')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_mst_1M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 15. System Resource Usages each 10 Minutes to CSV file - Master" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
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
WHERE hostname IN ('${MDWNM}')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_mst_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 16. System Resource Usages each 1 Hour to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(
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
WHERE hostname NOT IN ('${MDWNM}','${SMDWNM}')
AND ctime >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1) TO '/home/gpadmin/diag/csv/sys_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 17. Resource Group & User Mappings " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT rolname, rsgname FROM pg_roles, pg_resgroup  WHERE pg_roles.rolresgroup=pg_resgroup.oid;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 18. Resource Group Usages Raw data to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "COPY(SELECT *
FROM gpmetrics.gpcc_resgroup_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY 1,2) TO '/home/gpadmin/diag/csv/rsg_all_15s.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 19. Resource Group Usages each 1 Minute to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "
COPY(SELECT to_timestamp(floor((extract('epoch' from ctime) / 60 )) * 60) AT TIME ZONE 'Asia/Seoul' as interval_alias,
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
ORDER BY 1,2) TO '/home/gpadmin/diag/csv/rsg_seg_1M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 20. Resource Group Usages each 10 Minute to CSV file" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "
COPY(SELECT to_timestamp(floor((extract('epoch' from ctime) / 600 )) * 600) AT TIME ZONE 'Asia/Seoul' as interval_alias,
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
ORDER BY 1,2) TO '/home/gpadmin/diag/csv/rsg_seg_10M.csv' WITH CSV HEADER ;" >> ${LOGFILE}

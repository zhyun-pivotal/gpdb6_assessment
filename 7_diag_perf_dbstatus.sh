#!/bin/bash
#mkdir -p /home/gpadmin/diag/diaglog
source /usr/local/greenplum-db/greenplum_path.sh
export LOGFILE=/home/gpadmin/diag/diaglog/diag_perf_dbstatus.$(date '+%Y%m%d_%H%M')

echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 1. GPDB DATABASE LIST & SIZE" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT * FROM gp_toolkit.gp_resgroup_status_per_segment;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 2. TABLE LIST " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT * FROM pg_catalog.pg_tables WHERE schemaname NOT IN ('gp_toolkit', 'information_schema', 'pg_catalog','pg_aoseg','pg_toast') order by 1,2;" >> ${LOGFILE}
echo "" >> ${LOGFILE}
psql -c "SELECT b.nspname , relname, c.relkind,c.relstorage FROM pg_class c,pg_namespace b WHERE c.relnamespace=b.oid and b.nspname NOT IN ('gp_toolkit', 'information_schema', 'pg_catalog','pg_aoseg','pg_toast') AND relname NOT LIKE '%_1_prt_%' ORDER BY b.nspname,c.relkind,c.relstorage;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 3. SIZE per SCHEMA " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "select schemaname ,round(sum(pg_total_relation_size(schemaname||'.'||tablename))/1024/1024) as schema_size_MB from pg_tables WHERE schemaname NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')  group by 1;" >> ${LOGFILE}

#echo "" >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#echo "### 4. SIZE per TABLE " >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#psql -d gpperfmon -c "SELECT SCHEMA,table_name,relkind,relstorage,SIZE/1024/1024 AS size_mb FROM gpmetrics.gpcc_size_ext_table
#WHERE SCHEMA NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')
#ORDER BY 1,2,3,4,5 DESC;" >> ${LOGFILE}

#echo "" >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#echo "### 5. BUSY TABLE LIST " >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#psql -d gpperfmon -c "SELECT SCHEMA,table_name,relkind,relstorage,SIZE/1024/1024 AS size_mb FROM gpmetrics.gpcc_size_ext_table
#WHERE SCHEMA NOT in('gp_toolkit','pg_catalog','gpmetrics','dba','information_schema','gpcc_schema','gpexpand')
#ORDER BY 1,2,3,4,5 DESC;" >> ${LOGFILE}

#echo "" >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#echo "### 6. ERROR MESSAGES " >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#psql -d gpperfmon -c "SSELECT logmessage, count(*) FROM gpmetrics.gpcc_pg_log_history GROUP BY 1 ORDER BY 2 DESC LIMIT 30;" >> ${LOGFILE}

#echo "" >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#echo "### 7. Partitioned table List " >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#psql -c "select schemaname,tablename,partitiontype,count(partitiontablename) as total_no_of_partitions from pg_partitions group by tablename, schemaname,partitiontype ORDER BY 1,2;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 8. DISK USAGE Percents by One Hour" >> ${LOGFILE}
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

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 9. Frequency SQL (Top 50)  " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT query_text,count(*) FROM gpmetrics.gpcc_queries_history WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
  AND ctime < CURRENT_DATE GROUP BY query_text ORDER BY 2 DESC LIMIT 50;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 10. Running Timed SQL (Top 100)  " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -d gpperfmon -c "SELECT db,username,query_text,avg (tfinish-tstart),max (tfinish-tstart) FROM gpmetrics.gpcc_queries_history
WHERE ctime >= CURRENT_DATE - INTERVAL '7 days'
and db not in('gpperfmon','template1')
GROUP BY db,username,query_text ORDER BY 4 DESC LIMIT 100;" >> ${LOGFILE}

echo "" >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 11. Need for Table Analyze " >> ${LOGFILE}
echo "####################" >> ${LOGFILE}
psql -c "SELECT relname FROM pg_class where reltuples=0 and relpages=0 and relkind='r' and relname not like 't%' and relname not like 'err%';" >> ${LOGFILE}

#echo "" >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#echo "### 12. Replicated Mirror Segments status " >> ${LOGFILE}
#echo "####################" >> ${LOGFILE}
#psql -c "SELECT gp_segment_id,client_addr,client_port,backend_start,state,sync_state,sync_error FROM pg_catalog.gp_stat_replication ORDER BY 1;" >> ${LOGFILE}

#!/bin/bash
#mkdir -p /home/gpadmin/diag/diaglog
export LOGFILE=/home/gpadmin/diag/diaglog/diag_perf_db_status.$(date '+%Y%m%d_%H%M')

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

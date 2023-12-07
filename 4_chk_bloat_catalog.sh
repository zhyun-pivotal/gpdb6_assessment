#!/bin/bash
#mkdir -p /home/gpadmin/diag/diaglog
source /usr/local/greenplum-db/greenplum_path.sh
export LOGFILE=/home/gpadmin/diag/diaglog/chk_bloat_catalog.$(date '+%Y%m%d_%H%M')

psql -c "
select a.*
from (
    select n.nspname as schemaname,
            c.relname as tablename,
            b.btdrelpages as actual_pages,
            b.btdexppages as expected_pages,
            round(pg_relation_size(n.nspname || '.' || c.relname)/1024/1024) as actual_size_mb,
            round(pg_relation_size(n.nspname || '.' || c.relname)/1024/1024 * b.btdexppages/b.btdrelpages) as expected_size_mb
    from gp_toolkit.gp_bloat_expected_pages b
    join pg_class as c
    on c.oid=b.btdrelid
    join pg_namespace as n
    on c.relnamespace=n.oid
    where b.btdrelpages > 1
    and n.nspname in ('pg_catalog') ) as a
--where actual_size_mb > 1
--and actual_size_mb / expected_size_mb > 1
order by 1,2 desc ;" >> ${LOGFILE}

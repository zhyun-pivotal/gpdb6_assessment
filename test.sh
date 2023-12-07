echo "" > ${LOGFILE}
echo "####################" >> ${LOGFILE}
echo "### 6. DISK USAGE Percents by One Hour " >> ${LOGFILE}
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

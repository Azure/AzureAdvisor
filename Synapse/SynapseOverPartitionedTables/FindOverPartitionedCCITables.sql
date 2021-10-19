SELECT 
       SCHEMA_NAME(t.schema_id) as SchemaName
       ,t.name as TableName
		,MAX(partition_number) as PartitionCount
       ,SUM(row_count) as [Row_Count]
FROM sys.[dm_pdw_nodes_db_partition_stats] nps
INNER JOIN sys.[pdw_nodes_tables] nt on nt.object_id = nps.object_Id and nt.distribution_id = nps.distribution_id
INNER JOIN sys.pdw_table_mappings tm on tm.physical_name = nt.name
INNER JOIN sys.tables t on tm.object_id = t.object_id
INNER JOIN sys.indexes i on i.object_id = t.object_id
WHERE i.index_id = 1 and i.type_desc = 'CLUSTERED COLUMNSTORE'
GROUP BY schema_name(t.schema_id), t.name--,nps.distribution_id, nps.partition_number
HAVING SUM(row_count)/MAX(partition_number) <60000000 -- include tables where there are at least 60m records per partition 
	and MAX(partition_number) > 1 -- filter out non-partitioned tables
	and SUM(row_count) > 0 -- filter out tables with 0 records

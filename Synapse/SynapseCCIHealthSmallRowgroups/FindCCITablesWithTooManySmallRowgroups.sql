-- Find CCI Tables where compressed rowgroups have fewer than 100k records for more than 10% of the total compressed rowgroups in the CCI
SELECT 
	AggTable.[Schema_Name]
	,AggTable.Logical_Table_Name
	,AggTable.[Total_Compressed_Rowgroup_Count]
	,COUNT(1) as [Small_Rowgroups]
FROM 
(
	select   
		sm.name as [Schema_Name]
	,	tb.[name]                    AS [logical_table_name]
	,	COUNT(1) AS [Total_Compressed_Rowgroup_Count]
	FROM    sys.[schemas] sm
	JOIN    sys.[tables] tb               ON  sm.[schema_id]          = tb.[schema_id]
	JOIN    sys.[pdw_table_mappings] mp   ON  tb.[object_id]          = mp.[object_id]
	JOIN    sys.[pdw_nodes_tables] nt     ON  nt.[name]               = mp.[physical_name]
	JOIN    sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats] rg      ON  rg.[object_id]     = nt.[object_id]
				AND rg.[pdw_node_id]   = nt.[pdw_node_id]
				AND rg.[distribution_id]    = nt.[distribution_id]
	WHERE 	rg.state_desc = 'COMPRESSED'
	GROUP BY 
		sm.name
		,tb.[name]
) AggTable
JOIN sys.[schemas] sm1 ON AggTable.[Schema_Name] = sm1.[Name]
JOIN    sys.[tables] tb1               ON  sm1.[schema_id]          = tb1.[schema_id] AND tb1.name = AggTable.Logical_Table_Name
JOIN    sys.[pdw_table_mappings] mp1   ON  tb1.[object_id]          = mp1.[object_id]
JOIN    sys.[pdw_nodes_tables] nt1     ON  nt1.[name]               = mp1.[physical_name]
JOIN    sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats] rg1      ON  rg1.[object_id]     = nt1.[object_id]
				AND rg1.[pdw_node_id]   = nt1.[pdw_node_id]
				AND rg1.[distribution_id]    = nt1.[distribution_id]
WHERE 
	rg1.total_rows < 100000
	and rg1.state_desc = 'COMPRESSED'
GROUP BY 
	AggTable.[Schema_Name]
	,AggTable.Logical_Table_Name
	,AggTable.[Total_Compressed_Rowgroup_Count]
HAVING COUNT(1) > AggTable.[Total_Compressed_Rowgroup_Count]*.10



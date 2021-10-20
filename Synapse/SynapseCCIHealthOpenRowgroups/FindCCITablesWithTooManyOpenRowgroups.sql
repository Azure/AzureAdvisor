select   
	sm.name as [Schema_Name]
,	tb.[name]                    AS [logical_table_name]
,	count(1) as Open_Rowgroup_Count
FROM    sys.[schemas] sm
JOIN    sys.[tables] tb               ON  sm.[schema_id]          = tb.[schema_id]
JOIN    sys.[pdw_table_mappings] mp   ON  tb.[object_id]          = mp.[object_id]
JOIN    sys.[pdw_nodes_tables] nt     ON  nt.[name]               = mp.[physical_name]
JOIN    sys.[dm_pdw_nodes_db_column_store_row_group_physical_stats] rg      ON  rg.[object_id]     = nt.[object_id]
			AND rg.[pdw_node_id]   = nt.[pdw_node_id]
            AND rg.[distribution_id]    = nt.[distribution_id]
WHERE state_desc = 'OPEN'
GROUP BY 
	 sm.name
	,tb.[name]
	,rg.object_ID
HAVING COUNT(1) > 90

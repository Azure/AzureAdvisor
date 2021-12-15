-- Breakdown of Tables by Distribution Type
SELECT COUNT(1),distribution_policy_desc
FROM sys.tables t
INNER JOIN sys.pdw_table_distribution_properties tdp on t.object_id = tdp.object_id
GROUP BY distribution_policy_desc

-- Find Round Robin Tables
SELECT SCHEMA_NAME(schema_id) as SchemaName, t.name as TableName
FROM sys.tables t
INNER JOIN sys.pdw_table_distribution_properties tdp on t.object_id = tdp.object_id
WHERE distribution_policy_desc = 'ROUND_ROBIN'

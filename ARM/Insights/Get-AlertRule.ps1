#上記で確認したリソース ID とメトリック名を使用
Add-AlertRule -RuleType Metric -Name "<アラート ルール名>" -ResourceGroup "<リソース グループ名>" -Operator GreaterThan -Threshold 70 -WindowSize 00:05:00 -ResourceId "<リソース ID>" -MetricName "\Processor(_Total)\% Processor Time" -TimeAggregationOperator Total
Get-AlertRule -ResourceGroup "<リソース グループ名>"
Remove-AlertRule -Name "<アラート ルール名>" -ResourceGroup "<リソース グループ名>"
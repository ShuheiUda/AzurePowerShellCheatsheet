#リソース ID は新ポータルで各リソースの [すべての設定] - [プロパティ] から確認
#メトリックが表示されない場合は、[診断] を有効化
#(例)
#/subscriptions/<サブスクリプション ID>/resourceGroups/<リソース グループ名>/providers/Microsoft.ClassicCompute/virtualMachines/<仮想マシン名>
#/subscriptions/<サブスクリプション ID>/resourceGroups/<リソース グループ名>/providers/Microsoft.Compute/virtualMachines/<仮想マシン名>
Get-MetricDefinitions -ResourceId "<リソース ID>"
$docker = Get-ChildItem -Recurse -Filter docker-compose.yml | Select-Object -ExpandProperty DirectoryName -Unique

foreach ($dir in $docker) {
	Push-Location $dir
	docker compose up -d --pull always --force-recreate
	Pop-Location
}
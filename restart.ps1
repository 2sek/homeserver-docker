$docker = Get-ChildItem -Recurse -Filter docker-compose.yml | Select-Object -ExpandProperty DirectoryName -Unique

foreach ($dir in $docker) {
	Push-Location $dir
	docker compose stop
	docker compose pull
	docker compose up -d --remove-orphans
	Pop-Location
}
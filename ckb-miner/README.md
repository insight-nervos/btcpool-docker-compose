For testing purposes only. 

Container to run local cpu miner. 

```
# From base of repo 
docker-compose -f docker-compose.yml -f docker-compose.override.prometheus-server.yml  -f docker-compose.override
.prometheus-exporters.yml -f docker-compose.override.ckb-miner.yml ps
```


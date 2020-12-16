For testing purposes only. 

Container to run local cpu miner. 

```
# From base of repo 
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml up -d 
```

Solutions 

- Build stratum new stratum miner by modifying go-miner 


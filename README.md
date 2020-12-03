# btcpool-docker-compose

This is a docker-compose stack to setup a Stratum V1 mining pool for Nervos Blockchain.  It sets up the required
infrastructure along with several utilities such as prometheus for operations. It can be deployed independently or via
ansible and / or terraform with it's associated roles. 

## Quick Start

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/). 

```bash
make start  # Bring up the pool
make ps     # List container status
make stop   # Bring down the pool 
```

To run alternative configurations, prefix with the stack. 

```bash
STACK=prometheus make start 
```

### Configurations 

The application can be deployed in several configurations with additional monitoring utilities depending on how the
node is being run. Each configuration involves running associated override files which are facilitated with the
Makefile. To deploy a stack, run `make start` and `make stop` to bring down the containers. For additional
configuration reference the table below. 

| Configuration | Deployment Command | Description | 
| :---- | :-------------------------- | :---- | 
| Base | `make start` | Minimal deployment | 
| Prometheus Server | `STACK=prometheus make start` | Deploy with prometheus, grafana, and exporters | 
| Prometheus Exporters | `STACK=exporters make start` | Deploy with prometheus exporters. To be used with external prometheus server. | 

### Miners

BTCPool requires users to name each individual mining unit. Create a JSON file with the path `./miner-list/config/miners.json` and add miner names here. Use these names to connect miners to BTCPool.
```
{
  "alice_miner": 0,
  "bob_miner": 1
}
```

### Containers

The following containers are run with this application. 

| Container | Stack | Description | 
| :--- | :--- | :--- | 
| btcpool | Base | Main btcpool node | 
| ckb-node | Base | Main Nervos runtime | 
| nodebridge | Base | Connects btcpool with Nervos | 
| kafka | Base | Required for running btcpool | 
| zookeeper | Base | For running kafka | 
| miner-list | Base | Service to provide miner authentication |
| mysql | Base | For btcpool management data | 
| redis | Base | For caching btcpool data | 
| prometheus | Prometheus | Prometheus server | 
| alertmanager | Prometheus | Send alerts from prometheus | 
| grafana | Prometheus | Visualize metrics from pool | 
| caddy | Prometheus | Reverse proxy for prometheus and grafana | 
| kafka-exporter | Exporters | Kafka exporter | 
| nodeexporter | Exporters | Node data exporter | 
| cadvisor | Exporters | Container data exporter | 


### Related Repositories 

| Repo | Description | 
| :--- | :--- |
| [ansible-role-btcpool](https://github.com/insight-stratum/ansible-role-btcpool) | Ansible role that wraps this repository | 
| [terraform-btcpool-aws-node](https://github.com/insight-stratum/terraform-btcpool-aws-node) | Terraform module that sets up node on AWS with Ansible role |
| [terraform-btcpool-alibaba-node](https://github.com/insight-stratum/terraform-btcpool-alibaba-node) | Terraform module that sets up node on Alibaba with Ansible role |
| [btcpool](https://github.com/btccom/btcpool) | Main btcpool repo |


### Environment Variables

Environment variables can be set or populated in the .env file. 

| Variables | Default | Description |
| :--- | :--- | :--- | 
| DOCKER_IMAGE_BTCPOOL | btccom/btcpool | The btcpool docker image to use. |
| TAG_BTCPOOL | 2019.09.26-17-support-ckb-mining_bch-0.18.5 | The docker tag to use for btcpool. |
| DOCKER_IMAGE_CKB_NODE | nervos/ckb | The image for ckb | 
| TAG_CKB_NODE | v0.38.1 | The image tag for ckb | 

# btcpool-docker-compose

This is a docker-compose stack to setup a Stratum V1 mining pool for Nervos Blockchain.  It sets up the required infrastructure along with several utilities such as prometheus for operations. It can be deployed independently or via ansible and / or terraform with it's associated roles. 

## Quick Start

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/). 

```shell script
STACK=prometheus make start 
```

Visit `localhost:3000`, log in with username / password (`admin`/`admin`), and open the `ckb-node-v1` dashboard.  Here you will see the pool and a CKB node syncing up. On the top right you will see jobs being submitted and when miners connect to the pool, shares being solved. To join miners to the pool, follow the guide below. 

### Setup 

To setup your own pool, you will need to do the following. 

1. Deploy a the pool onto a server on the cloud or bare metal 
1. SSH into the pool server 
1. Configure a [miner list](#miner-list) to connect miners or [proxies](https://github.com/btccom/btcagent) to the pool 
1. Setup a [wallet for the pool](#pool-wallet)
1. Pick a [network](#configure-the-network) to run on 
1. [Validate](#validate-that-the-pool-is-running) that the deployment is working 
 
#### Node Deployment 

To deploy the node onto the cloud, we have the following automated deployments. 

1. [AWS](https://github.com/insight-nervos/terraform-btcpool-aws-node)
1. [Alibaba](https://github.com/insight-nervos/terraform-btcpool-alibaba-node)  

Follow the readme to deploy the node.  You will API keys the associated cloud to deploy the stack which you can find instructions on how to get inside the associated readme. You will also need an SSH key so that you can login to the server. Before deploying, as noted in the readmes, create an SSH key and then ssh into the machine. 

```shell script
# create ssh key 
ssh-keygen -b 4096 
# run the terraform from the examples directory 
terraform apply 
# ssh into the machine 
ssh -i /path/to/your/ssh/key ubuntu@<the public ip that is shown after deployment>
```

From here, there will be a few steps to properly configure your node. 

#### Miner List

BTCPool requires users to name each individual mining unit or proxy if running a large . Create a JSON file with the path `./miner-list/config/miners.json` and add miner names here. Use these names to connect miners to BTCPool.

```
{
# "miner_name": "unique_id",
  "alice_miner": 0,
  "bob_miner": 1
}
```

The miner-list service is required by BTCpool to provide miner names and IDs. This little service simply responds with a json object with all the users (or requested IDs) on the '/miner-list' endpoint. See this [issue](https://github.com/btccom/btcpool/issues/16#issuecomment-278245381) for more information. 

#### Pool Wallet

BTCpool requires users to import pool's wallet address. The wallet address can be off an online wallet or a ledger (preferred).  To import your wallet, edit `./ckb-node/<network>/ckb.toml`, scroll to the `[block_assembler]` section, and change the `[args]` parameter to your pool's wallet address.

```
[block_assembler]
code_hash = "0x9bd7e06f3ecf4be0f2fcd2188b23f1b9fcc88e5d4b65a8637b17723bbda3cce8"
args = "0xYOUR_POOL_WALLET_HERE"   # test addr
hash_type = "type"
message = "0x"
```

##### Configure the network 

You can either run on mainnet (default) or testnet.  To run on testnet, modify the `.env` file in this repo to testnet. 

##### Validate that the pool is running 

The easiest way to validate that the pool is running is by checking the monitoring tools included with the stack.  Included is a grafana dashboard located at `<your node ip (localhost)>:3000` with a default username (admin) / password (admin) that you change on login. Navigate to the `ckb-pool-dashboard`.  The panels should start populating when you connect miners appropriately.  It will show the block height of the pool vs the ckb node which should be in sync for the pool to function appropriately. When jobs are submitted to the pool, you will see the jobs populate in the top middle right chart (CKB Jobs). Next to that when miners start doing work, you will see them the CKB Share Logs start increasing.  Last, when shares are solved, you will see the last chart populate on the right.  

##### Local Miner 

> WIP - This is crashing when left running over extended periods of time so only use this for testing purposes to verify the pool is working. 

For testing purposes, we have included a local cpu miner that joins the pool with the default credentials (username =`alice`).  To run this container:

```shell script
docker-compose -f docker-compose.yml -f docker-compose.override.ckb-miner.yml up -d
```

##### Node Bridge

The nodebridge service is required by BTCpool to retrieve mining jobs from ckb-node and send them to Kafka under the CkbRawGw topic. This replaces blkmaker and gwmaker required by btcpool for other blockchains. See this [issue](https://github.com/btccom/btcpool/issues/378) for more information.

### Basic commands 
Because there are multiple override docker-compose files, we've included some make helpers to deploy the stack. 

```bash
make start  # Bring up the pool
make ps     # List container status
make stop   # Bring down the pool 
```

Optionally, you can run the files manually (better for dev).

```shell script
docker-composer -f docker-compose.yml -f docker-compose.prometheus-exporters.yml -f docker-compose.prometheus-server.yml up -d 
```

### Configurations 

The application can be deployed in several configurations with additional monitoring utilities depending on how the node is being run. Each configuration involves running associated override files which are facilitated with the Makefile. To deploy a stack, run `make start` and `make stop` to bring down the containers. For additional configuration reference the table below. 

| Configuration | Deployment Command | Description | 
| :---- | :-------------------------- | :---- | 
| Base | `make start` | Minimal deployment | 
| Testnet Server | `STACK=testnet make start` | Deploy the base compose in ckb's testnet | 
| Prometheus Server | `STACK=prometheus make start` | Deploy with prometheus, grafana, and exporters | 
| Prometheus Exporters | `STACK=exporters make start` | Deploy with prometheus exporters. To be used with external prometheus server. | 
| Local Miner | `STACK=miner make start` | Deploy with a single local miner for testing | 


### Prometheus 

A full prometheus stack can be deployed alongside the pool including Grafana, Alertmanager, and the following exporters. 

| Exporter | Port | Description | 
| :--- | :--- | :--- | 
| btcpool | 9101 | Connection metrics and indicators of steady operation | 
| ckb-node | 8100 | Chain metrics | 
| kafkaexporter | 9308 | Kafka metrics such as number of topics | 
| nodeexporter | 9100 | Node metrics such as CPU/RAM | 
| cadvisor | 9080 | Container metrics | 

To verify prometheus is working, visit `pool-ip:9090/targets` to verify all the exporters came up properly. 

##### Grafana

To see metrics coming from the operation of the pool, you can visit `<your IP/localhost>:3000` to view grafana dashboards. Dashboards will initialize on node startup.  

##### Alertmanager 

To send alerts when adverse situations arise, you can configure receivers to forward alert messages to.  Alerts have two basic components, rules and receivers. To setup new rules, modify the `prometheus/alert_rules.yaml` [per examples](https://awesome-prometheus-alerts.grep.to/rules.html) and restart prometheus. To add new receivers for things like SMS messages and emails, modify the `alertmanager/config.yml` and consult [the docs](https://prometheus.io/docs/alerting/latest/configuration/#receiver) to configure these channels. For instance, to configure a slack alert, you will need to insert a webhook token as seen in [this guide](https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/).

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

### Application Ports

| Port | Description | External |
| :--- | :---------- | :------- |
| 1800 | Stratum Server | Yes   |
| 8114 | CKB Node RPC   | Yes   |
| 8115 | CKB Node Blockchain | Yes |
| 2181 | Zookeeper Client | No  |
| 9092 | Kafka Advertised | No  |
| 19092 | Kafka Internal  | No  |
| 8000 | Miner List       | No  |
| 3306 | Mariadb          | No  |
| 6379 | Redis            | No  |

*Prometheus ports not shown 

### Environment Variables

Environment variables can be set or populated in the .env file. 

| Variables | Default | Description |
| :--- | :--- | :--- | 
| DOCKER_IMAGE_BTCPOOL | btccom/btcpool | The btcpool docker image to use. |
| TAG_BTCPOOL | 2019.09.26-17-support-ckb-mining_bch-0.18.5 | The docker tag to use for btcpool. |
| DOCKER_IMAGE_CKB_NODE | nervos/ckb | The image for ckb | 
| TAG_CKB_NODE | v0.38.1 | The image tag for ckb | 

### Related Repositories 

| Repo | Description | 
| :--- | :--- |
| [ansible-role-btcpool](https://github.com/insight-stratum/ansible-role-btcpool) | Ansible role that wraps this repository | 
| [terraform-btcpool-aws-node](https://github.com/insight-stratum/terraform-btcpool-aws-node) | Terraform module that sets up node on AWS with Ansible role |
| [terraform-btcpool-alibaba-node](https://github.com/insight-stratum/terraform-btcpool-alibaba-node) | Terraform module that sets up node on Alibaba with Ansible role |
| [btcpool](https://github.com/btccom/btcpool) | Main btcpool repo |
| [ckb-node](https://github.com/nervosnetwork/ckb) | Main CKB repo |

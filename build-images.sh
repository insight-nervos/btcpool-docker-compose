# clone repo
git clone https://github.com/insight-stratum/btcpool.git

# build base image
sudo docker build -t btccom/btcpool_build:btc-0.16.3 -f ./btcpool/docker/btcpool/base-image/Dockerfile.btc --build-arg BUILD_JOBS=$(nproc) ./btcpool/docker/btcpool/base-image/

# build deploy image
sudo docker build -t btccom/btcpool-btc -f ./btcpool/docker/btcpool/deploy/Dockerfile --build-arg BASE_IMAGE=btccom/btcpool_build:btc-0.16.3 --build-arg BUILD_JOBS=$(nproc) --build-arg GIT_DESCRIBE=$(git describe --tag --long) ./btcpool/

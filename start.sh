# move configs
cp ./config/pool/* ./volumes/btcpool/
cp -R ./config/mysql/* ./volumes/mysql/

# start docker compose
sudo docker-compose up

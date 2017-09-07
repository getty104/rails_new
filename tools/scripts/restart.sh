docker volume rm $(docker volume ls -qf dangling=true)
docker-compose down
docker-compose build
docker-compose up -d

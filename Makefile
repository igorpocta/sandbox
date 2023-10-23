
# Development environment
################################################################################################
# > Build
dev-build:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build

# > Start
dev-start:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# > Stop
dev-stop:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down


# Production environment
################################################################################################
# > Build
build:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build

# > Start
start:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# > Stop
stop:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml down


# Maintenance
################################################################################################
cleartemp:
	docker exec sandbox rm -rf /var/www/html/temp/cache


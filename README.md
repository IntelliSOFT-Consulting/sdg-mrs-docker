# sdg-mrs-docker

Repository for the SDG MRS Docker files
Docker image for ethiopia MRS sdg.  
database directory contains resources to build a database image from sql file  
conf directory contains dhis2 database configuration details

# Developer instructions for local development

1. Install docker in your local machine.
2. clone this repo
3. cd database
4. Add your compressed sql file here with the name "dhis2-db.sql.gz"
5. RUN: docker build -t ethiopia-sdg:1.0 .
5. cd ../
7. Create .env file with the credentials below in the root directory  
    DB_USER= dhis  
    DB_NAME=dhis  
    PASSWORD= dhis
8. RUN: docker-compose -f docker-compose.prod.yml up
9. Go to your browser: http://0.0.0.0:8085/ to access dhis2


# Developer instruction for production deployment

1. Install docker in your local machine.
2. clone this repo
3. Create .env file in the root directory then add the following credentials  
    DB_USER=dhis  
    DB_NAME=dhis  
    PASSWORD=dhis
4. RUN: docker-compose -f docker-compose.prod.yml up -d
5. Go to your browse: http://yourIPaddress:8085/ to access dhis2

# NB: Change password after setup. 
docker exec -it containerName /bin/bash 
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
6. cd ../
7. Create .env file in the root directory then add the following   
        DB_USER= your username  
        DB_NAME=database name  
        PASSWORD= your password  
8. RUN: docker-compose -f docker-compose.prod.yml up
9. Go to your browser: http://0.0.0.0:8085/ to access dhis2


# Developer instruction for production deployment
1. Install docker in your local machine.
2. clone this repo
3. Create .env file in the root directory then add the following content  
        DB_USER= your username  
        DB_NAME=database name  
        PASSWORD= your password  
4. RUN: docker-compose -f docker-compose.prod.yml up -d

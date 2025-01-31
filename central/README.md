# sdg-mrs-docker
Repository for the SDG MRS Docker files
Docker image for Central MRS sdg.  
database directory contains resources to build a database image from sql file  
conf directory contains dhis2 database configuration details


# Developer instructions for local development
1. Install docker in your local machine.
2. clone this repo
3. cd the repo directory
4. Add your compressed sql backup file or DB dump file in .tar format to the backup directory
5. RUN: ./database/seed.sh
6. RUN: docker-compose up -d
7. Go to your browser: http://0.0.0.0:8085/ to access dhis2


# Developer instruction for production deployment
1. Install docker in your local machine.
2. clone this repo
3. Create .env file in the root directory then add the following content  
        DB_USER= your username  
        DB_NAME=database name  
        PASSWORD= your password  
4. RUN: docker-compose -f docker-compose.prod.yml up -d

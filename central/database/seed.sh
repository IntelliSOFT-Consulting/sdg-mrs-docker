#!/bin/bash
set -e

# Enable debug output
# set -x

# Configuration
WAIT_TIME=10
DB_CONTAINER="database"
DB_NAME="dhis"
DB_USER="dhis"
DB_PASS="dhis"

# Use docker-compose if available, fall back to docker compose
if command -v docker-compose &>/dev/null; then
    DOCKER_CMD="docker-compose"
else
    DOCKER_CMD="docker compose"
fi

echo "Using Docker command: $DOCKER_CMD"

# Check if input file was provided
if [ $# -eq 0 ]; then
    echo "USAGE: $0 <path/to/backup-file.[tar|sql]>" 1>&2
    exit 1
fi

# Validate input file
FILE="$1"
if [ ! -f "$FILE" ]; then
    echo "ERROR: The file '$FILE' does not exist." 1>&2
    exit 1
fi

# Check file extension
FILE_EXT="${FILE##*.}"
if [ "$FILE_EXT" != "sql" ] && [ "$FILE_EXT" != "tar" ]; then
    echo "ERROR: Unrecognized file extension, '.sql' or '.tar' expected." 1>&2
    exit 1
fi

# Function to check if container is running
check_container() {
    echo "Checking if container $DB_CONTAINER is running..."
    $DOCKER_CMD ps | grep -q "$DB_CONTAINER"
    local status=$?
    if [ $status -eq 0 ]; then
        echo "Container is running"
    else
        echo "Container is not running"
    fi
    return $status
}

# Function to start container if needed
ensure_container_running() {
    if ! check_container; then
        echo "Starting database container..."
        $DOCKER_CMD up -d "$DB_CONTAINER"

        echo "Waiting $WAIT_TIME seconds for postgres initialization..."
        sleep "$WAIT_TIME"

        if ! check_container; then
            echo "ERROR: Failed to start database container"
            exit 1
        fi
        return 0
    fi
    # return 1
}

# Main restore logic
echo "Starting restore process..."
container_started=0
ensure_container_running
container_started=$?

echo "Importing '$FILE'..."

if [ "$FILE_EXT" = "tar" ]; then
    # Copy the tar file into the container
    echo "Copying tar file to container..."
    $DOCKER_CMD cp "$FILE" "$DB_CONTAINER:/tmp/db-restore.tar"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to copy file to container"
        exit 1
    fi

    echo "Starting database restore..."
    # First check if pg_restore is available
    $DOCKER_CMD exec "$DB_CONTAINER" which pg_restore
    if [ $? -ne 0 ]; then
        echo "ERROR: pg_restore not found in container"
        exit 1
    fi

    # Use docker exec to run pg_restore inside the container
    $DOCKER_CMD exec "$DB_CONTAINER" bash -c "PGPASSWORD=$DB_PASS pg_restore \
        -h localhost \
        -U $DB_USER \
        -d $DB_NAME \
        --clean \
        --if-exists \
        -v \
        /tmp/db-restore.tar"

    restore_status=$?
    echo "pg_restore completed with status: $restore_status"

    # Clean up
    echo "Cleaning up temporary files..."
    $DOCKER_CMD exec "$DB_CONTAINER" rm /tmp/db-restore.tar

    if [ $restore_status -ne 0 ]; then
        echo "ERROR: Database restore failed"
        exit 1
    fi
else
    # For SQL files, pipe directly to psql
    echo "Restoring from SQL file..."
    PGPASSWORD="$DB_PASS" cat "$FILE" | $DOCKER_CMD exec -T "$DB_CONTAINER" \
        psql -h localhost \
        --dbname "$DB_NAME" \
        --username "$DB_USER" \
        -v ON_ERROR_STOP=1

    if [ $? -ne 0 ]; then
        echo "ERROR: Database restore failed"
        exit 1
    fi
fi

# Stop container
echo "Stopping database container..."
$DOCKER_CMD stop "$DB_CONTAINER"

echo "Database restore completed successfully"
exit 0

# expense-shell

Shell scripts that set up a 3-tier expense tracking app on a Linux server: MySQL database, Node.js backend and web frontend. Built while learning shell scripting and Linux service management.

## What each script does
- `mysql.sh`: installs and starts MySQL, then sets the root password if it isn't set yet
- `backend.sh`: installs Node.js, creates the app user, downloads the backend code, loads the database schema and starts the service
- `backend.service`: systemd unit file that runs the backend
- `frontend.sh`:- `frontend.sh`: installs and starts nginx, removes the default site, downloads and unpacks the frontend code, applies `expense.config` and restarts nginx
- `expense.config`: nginx config that forwards `/api/` requests to the backend and exposes a `/health` endpoint
- Application code (backend and frontend zips) is downloaded from S3, not stored in this repo

## How to run
Clone this repo to `/home/ec2-user/expense-shell` first. The scripts copy `backend.service` and `expense.config` from that path.
Run the scripts as root, in this order: `mysql.sh`, `backend.sh`, `frontend.sh`.

    export MYSQL_ROOT_PASSWORD='your-password'
    export MYSQL_HOST='your-mysql-host'
    sudo -E ./mysql.sh

Replace the placeholder hostnames (`mysql.example.com`, `backend.example.com`) in `backend.service` and `expense.config` with your own.

## Features
- Checks that the script is run as root
- Logs every step to `/var/log/expense`
- Stops with a clear message if any step fails
- Re-runnable: `mysql.sh` and `backend.sh` skip steps that are already done, and `frontend.sh` reinstalls the site cleanly
- No hardcoded passwords. They come from environment variables

## Tools
Bash, MySQL, Node.js, nginx, systemd

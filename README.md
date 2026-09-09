# OpenFlights dataset for MariaDB

A ready-to-import dataset of airports, airlines, routes, countries, and planes — sourced from [OpenFlights](https://github.com/jpatokal/openflights) and packaged for MariaDB.

There are three ways to load it, depending on what you already have installed:

- **[A local MariaDB](#quick-start-with-local-mariadb)** — if MariaDB is already on your machine, or you want it to stay there afterwards.
- **[Docker Compose](#quick-start-with-docker-compose)** — if you have Docker: one command, and nothing is installed on your machine.
- **[Docker without Compose](#quick-start-with-docker-without-compose)** — the same, one step at a time.

Whichever you pick, you end up with a `flightdb2` database holding the tables below. Each starts with `git clone`; if you do not have git, use GitHub's **Code → Download ZIP** button instead and unpack it.

## Tables

| Table | Description |
|-------|-------------|
| `airports` | ~7700 airports worldwide with IATA/ICAO codes, coordinates, timezone |
| `airlines` | ~6000 airlines with IATA/ICAO codes, country |
| `routes` | ~67000 routes between airports |
| `countries` | Country codes (ISO and DAFIF) |
| `planes` | Aircraft types with IATA/ICAO codes |
| `locales` | Supported locale codes and display names |

## Quick start with local MariaDB

```sh
git clone https://github.com/mariadb/openflights
cd openflights

sudo mariadb < sql/create.sql
sudo mariadb --local-infile=1 < sql/load-data.sql

# Open the MariaDB client with the flightdb2 database selected
sudo mariadb flightdb2
```

Package-manager installs (`apt`, `dnf`, Homebrew) normally tie the database `root` account to your computer's own login, which is why `sudo` is used here and why nothing asks you for a password. If you set a password for `root` instead, drop the `sudo` and use `mariadb -u root -p`.

## Quick start with Docker Compose

```sh
git clone https://github.com/mariadb/openflights
cd openflights

docker compose up --wait

# Open the MariaDB client with the flightdb2 database selected
docker compose exec mariadb mariadb -u root --password=flightpw flightdb2
```

`--wait` returns only once the container is healthy, which is after `sql/create.sql` and `sql/load-data.sql` have run inside it, so the client opens on a fully loaded `flightdb2`. Any Docker-compatible runtime works, Colima included.

Set `MARIADB_PORT=3307` if the default 3306 is taken, or `MARIADB_VERSION=11.4` to run a version other than the default, MariaDB's current long-term support release.

## Quick start with Docker (without Compose)

```sh
git clone https://github.com/mariadb/openflights
cd openflights

# Start MariaDB
docker run -d \
  --name openflights-mariadb \
  -e MARIADB_ROOT_PASSWORD=flightpw \
  -p 3306:3306 \
  -v $(pwd):/openflights \
  mariadb:lts

# Create database and tables
docker exec -i openflights-mariadb \
  mariadb -u root --password=flightpw < sql/create.sql

# Load the data (run this from the repo folder: load-data.sql
# refers to data/ using a relative path)
docker exec -i openflights-mariadb \
  bash -c "cd /openflights && mariadb --local-infile=1 -u root --password=flightpw < sql/load-data.sql"

# Open the MariaDB client with the flightdb2 database selected
docker exec -it openflights-mariadb mariadb -u root --password=flightpw flightdb2
```

If you already run MariaDB or MySQL on port 3306, change `-p 3306:3306` to `-p 3307:3306`. Nothing will complain if you do not: the container starts, but connections from your machine to port 3306 may reach your existing server instead of this one.

## Connecting to the MariaDB server

Anything on your machine that connects over the network rather than through a local socket needs these — a graphical client such as DBeaver or TablePlus, or a driver in Python, Java or another language:

| Setting | Value |
|---------|-------|
| Host | `127.0.0.1` |
| Port | `3306`, unless you changed it when starting the server |
| Database | `flightdb2` |
| User / password | `root` / `flightpw` |

A local install is the exception. Its `root` account is tied to your computer login, which works for `sudo mariadb` but is refused over the network, so create an ordinary user for those clients to use:

```sql
CREATE USER 'flights'@'localhost' IDENTIFIED BY 'flightpw';
GRANT ALL ON flightdb2.* TO 'flights'@'localhost';
```

## Example queries

```sql
USE flightdb2;

-- List the tables
SHOW TABLES;

-- Columns of a single table
DESCRIBE airports;

-- Airports in Finland
SELECT name, city, iata, icao FROM airports WHERE country = 'Finland';

-- Airlines flying from a given country
SELECT name, iata, icao, active FROM airlines WHERE country = 'Finland';

-- All routes out of Helsinki (HEL)
SELECT r.airline, a.name AS destination, r.dst_ap
FROM routes r
JOIN airports a ON a.apid = r.dst_apid
WHERE r.src_ap = 'HEL'
ORDER BY a.name;

-- Airlines with the most routes
SELECT a.name AS airline, a.iata, COUNT(*) AS routes
FROM routes r
JOIN airlines a ON a.alid = r.alid
GROUP BY r.alid
ORDER BY routes DESC
LIMIT 10;

-- Top 10 airports by number of departing routes
SELECT a.name, a.iata, COUNT(*) AS departures
FROM routes r
JOIN airports a ON a.apid = r.src_apid
GROUP BY r.src_apid
ORDER BY departures DESC
LIMIT 10;

-- Countries with the most airports
SELECT country, COUNT(*) AS cnt
FROM airports
GROUP BY country
ORDER BY cnt DESC
LIMIT 10;

-- Longest routes out of Helsinki, by great-circle distance in km
SELECT DISTINCT r.dst_ap, d.name AS destination,
       ROUND(ST_Distance_Sphere(POINT(s.x, s.y), POINT(d.x, d.y)) / 1000) AS km
FROM routes r
JOIN airports s ON s.apid = r.src_apid
JOIN airports d ON d.apid = r.dst_apid
WHERE r.src_ap = 'HEL'
ORDER BY km DESC
LIMIT 10;
```

## Cleanup

**Local MariaDB** — drop the database:

```sql
DROP DATABASE flightdb2;
```

**Docker Compose** — stop the container and remove its data:

```sh
docker compose down -v
```

**Docker without Compose** — stop and remove the container:

```sh
docker rm -f openflights-mariadb
```

## Troubleshooting

**`ERROR 2 (HY000): File 'data/airlines.dat' not found`**

Run the commands from the repository folder. `sql/load-data.sql` refers to
`data/` using a relative path, so it only works from there.

**`ERROR 2002 (HY000): Can't connect to local server through socket`**

The MariaDB server is not running. Start it with `brew services start mariadb`
on macOS, or `sudo systemctl start mariadb` on Linux. Having the `mariadb`
command available is not the same as having the server running.

**`Cannot connect to the Docker daemon`**, or **`failed to connect to the docker API`**

Docker itself is installed but not started. Launch Docker Desktop, or run
`colima start` if you use Colima.

## Data files

Raw CSV data is in `data/`. The files have no header row.

| File | Columns (in order) |
|------|--------------------|
| `airlines.dat` | alid, name, alias, iata, icao, callsign, country, active |
| `airports.dat` | apid, name, city, country, iata, icao, lat, lon, elevation, timezone, dst, tz_id, type, source |
| `routes.dat` | airline, alid, src_ap, src_apid, dst_ap, dst_apid, codeshare, stops, equipment |
| `countries.dat` | name, iso_code, dafif_code |
| `planes.dat` | name, iata, icao |
| `locales.dat` | locale, name |

See the [OpenFlights data documentation](https://openflights.org/data.php) for full field descriptions.

## License

Data is made available under the [Open Database License](https://opendatacommons.org/licenses/odbl/1-0/). See [LICENSE](LICENSE).

COPY family FROM '/docker-entrypoint-initdb.d/Familles.csv' DELIMITER ';' CSV HEADER encoding 'windows-1251';
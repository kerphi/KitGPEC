COPY agents FROM '/docker-entrypoint-initdb.d/Agents.csv' DELIMITER ';' CSV HEADER encoding 'windows-1251';
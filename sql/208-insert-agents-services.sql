COPY agents_services FROM '/docker-entrypoint-initdb.d/Agents_Services.csv' DELIMITER ';' CSV HEADER encoding 'windows-1251';
create user 'pandara'@'%' identified by 'pandara';

create database archive;
create database auth;
create database characters;
create database fusion;
create database world;

grant all privileges on archive.* to 'pandara'@'%';
grant all privileges on auth.* to 'pandara'@'%';
grant all privileges on characters.* to 'pandara'@'%';
grant all privileges on fusion.* to 'pandara'@'%';
grant all privileges on world.* to 'pandara'@'%';

flush privileges;


 
-- create databases
create database IF NOT EXISTS campground;
create database IF NOT EXISTS demo_campground;
create database IF NOT EXISTS open_campground_test;
-- create root user and grant rights
create user IF NOT EXISTS 'test'@'%' identified by 'secret';
grant all privileges on campground.* to 'test'@'%';
grant all privileges on demo_campground.* to 'test'@'%';
grant all privileges on open_campground_test.* to 'test'@'%';
-- Script d'initialisation MariaDB pour tp-vagrant-web-db
CREATE DATABASE IF NOT EXISTS `tp_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS 'tp_user'@'%' IDENTIFIED BY 'tp_password';
GRANT ALL PRIVILEGES ON `tp_db`.* TO 'tp_user'@'%';
FLUSH PRIVILEGES;

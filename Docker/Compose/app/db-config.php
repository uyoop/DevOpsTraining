<?php
const DB_DSN = 'mysql:host=mysql_c;dbname=test';
const DB_USER = "test";
const DB_PASS = "test";

$options = array(
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8",
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_EMULATE_PREPARES => false
);

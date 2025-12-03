<?php
// db.php : connexion PDO à la base

$host = 'localhost';
$db   = 'covoit';
$user = 'covoit_user';
$pass = 'motdepasse';

$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    die('Erreur de connexion à la base : ' . htmlspecialchars($e->getMessage()));
}
<?php
// Minimal PDO SQLite connection helper

declare(strict_types=1);

function db_connect(): PDO {
    $dbPath = __DIR__ . '/../data/uyoop.db';
    $dbDir = dirname($dbPath);
    
    // Create data directory if it doesn't exist
    if (!is_dir($dbDir)) {
        mkdir($dbDir, 0755, true);
    }
    
    $dsn = "sqlite:{$dbPath}";
    $pdo = new PDO($dsn, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    return $pdo;
}

<?php
// Save form payload to SQLite

declare(strict_types=1);
header('Content-Type: application/json');

require __DIR__ . '/db.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

$raw = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON']);
    exit;
}

try {
    $pdo = db_connect();
    $pdo->exec('CREATE TABLE IF NOT EXISTS specs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        org_name TEXT,
        contact_name TEXT,
        contact_email TEXT,
        project_type TEXT,
        budget REAL,
        timeline TEXT,
        goals TEXT,
        payload TEXT
    );');

    $stmt = $pdo->prepare('INSERT INTO specs (org_name, contact_name, contact_email, project_type, budget, timeline, goals, payload)
                           VALUES (:org, :cname, :cemail, :ptype, :budget, :timeline, :goals, :payload)');
    $stmt->execute([
        ':org' => $data['org_name'] ?? null,
        ':cname' => $data['contact_name'] ?? null,
        ':cemail' => $data['contact_email'] ?? null,
        ':ptype' => $data['project_type'] ?? null,
        ':budget' => $data['budget'] ?? null,
        ':timeline' => $data['timeline'] ?? null,
        ':goals' => $data['goals'] ?? null,
        ':payload' => json_encode($data),
    ]);
    $id = $pdo->lastInsertId();
    echo json_encode(['id' => $id, 'success' => true, 'message' => 'Enregistrement réussi']);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB error', 'detail' => $e->getMessage()]);
}

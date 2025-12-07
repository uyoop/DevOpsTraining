<?php
// Generate simple HTML cahier des charges from DB or default

declare(strict_types=1);

require __DIR__ . '/db.php';

$id = isset($_GET['id']) ? (int)$_GET['id'] : null;
$payload = null;

if ($id) {
    try {
        $pdo = db_connect();
        $stmt = $pdo->prepare('SELECT payload FROM specs WHERE id = :id');
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch();
        if ($row && isset($row['payload'])) {
            $payload = json_decode($row['payload'], true);
        }
    } catch (Throwable $e) {
        // Fallback to no payload
    }
}

// If not found, render a minimal page
$data = is_array($payload) ? $payload : [
    'org_name' => 'Projet',
    'project_type' => 'N/A',
];

function e(string $s): string { return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }

?><!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Cahier des charges — <?php echo e($data['org_name'] ?? 'Projet'); ?></title>
  <link rel="icon" type="image/png" href="/assets/uyoop-logo.png" />
  <link rel="stylesheet" href="/assets/style.css" />
  <style>
    body { background:#fff; color:#111; }
    .doc { max-width:900px; margin:40px auto; padding:0 16px; }
    .doc h1 { font-size:2rem; }
    .doc h2 { margin-top:24px; }
    .doc section { margin:16px 0; }
    .doc ul { line-height:1.7; }
    .badge { display:inline-block; padding:4px 8px; background:#eef; border:1px solid #ccd; border-radius:999px; font-size:0.85rem; }
    .muted { color:#666; }
  </style>
</head>
<body>
<div class="doc">
  <h1>Cahier des charges — <?php echo e($data['org_name'] ?? 'Projet'); ?></h1>
  <p class="muted">Généré par Uyoop</p>

  <section>
    <h2>Informations générales</h2>
    <ul>
      <li><strong>Type de projet:</strong> <?php echo e($data['project_type'] ?? ''); ?></li>
      <li><strong>Contact:</strong> <?php echo e(($data['contact_name'] ?? '') . ' (' . ($data['contact_email'] ?? '') . ')'); ?></li>
      <li><strong>Budget:</strong> <?php echo e($data['budget'] ?? 'N/A'); ?> €</li>
      <li><strong>Délais:</strong> <?php echo e($data['timeline'] ?? 'N/A'); ?></li>
      <li><strong>Objectifs:</strong> <?php echo e($data['goals'] ?? ''); ?></li>
    </ul>
  </section>

  <?php if (($data['project_type'] ?? '') === 'audit'): ?>
  <section>
    <h2>Audit</h2>
    <ul>
      <li><strong>Périmètre:</strong> <?php echo e($data['audit_scope'] ?? ''); ?></li>
      <li><strong>Maturité:</strong> <?php echo e($data['digital_maturity'] ?? ''); ?></li>
      <li><strong>Risques:</strong> <?php echo e($data['risks'] ?? ''); ?></li>
    </ul>
  </section>
  <?php endif; ?>

  <?php if (($data['project_type'] ?? '') === 'website'): ?>
  <section>
    <h2>Site web</h2>
    <ul>
      <li><strong>Type:</strong> <?php echo e($data['site_type'] ?? ''); ?></li>
      <li><strong>Pages clés:</strong> <?php echo e($data['key_pages'] ?? ''); ?></li>
      <li><strong>CMS:</strong> <?php echo e($data['cms'] ?? ''); ?></li>
      <li><strong>Fonctionnalités:</strong> <?php echo e($data['features'] ?? ''); ?></li>
    </ul>
  </section>
  <?php endif; ?>

  <?php if (($data['project_type'] ?? '') === 'app'): ?>
  <section>
    <h2>Application</h2>
    <ul>
      <li><strong>Plateforme:</strong> <?php echo e($data['platform'] ?? ''); ?></li>
      <li><strong>Modules:</strong> <?php echo e($data['modules'] ?? ''); ?></li>
      <li><strong>Intégrations:</strong> <?php echo e($data['integrations'] ?? ''); ?></li>
    </ul>
  </section>
  <?php endif; ?>

  <?php if (($data['project_type'] ?? '') === 'devops'): ?>
  <section>
    <h2>DEVOPS / Infra</h2>
    <ul>
      <li><strong>Environnement:</strong> <?php echo e($data['env'] ?? ''); ?></li>
      <li><strong>CI/CD:</strong> <?php echo e($data['cicd'] ?? ''); ?></li>
      <li><strong>Sécurité:</strong> <?php echo e($data['security'] ?? ''); ?></li>
    </ul>
  </section>
  <?php endif; ?>

  <section>
    <span class="badge">Version brouillon</span>
  </section>
</div>
</body>
</html>

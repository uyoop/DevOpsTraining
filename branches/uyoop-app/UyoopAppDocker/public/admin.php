<?php
// Admin page to list all saved specs
declare(strict_types=1);

require __DIR__ . '/../src/db.php';

try {
    $pdo = db_connect();
    $stmt = $pdo->query('SELECT id, created_at, org_name, contact_name, contact_email, project_type, budget, timeline 
                         FROM specs 
                         ORDER BY created_at DESC');
    $specs = $stmt->fetchAll();
} catch (Throwable $e) {
    $specs = [];
    $error = $e->getMessage();
}

function e(string $s): string { 
    return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); 
}

?><!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Admin - Formulaires complétés | Uyoop</title>
  <link rel="icon" type="image/png" href="/assets/uyoop-logo.png" />
  <link rel="stylesheet" href="/assets/style.css" />
  <style>
    .admin-container { max-width: 1200px; margin: 40px auto; padding: 0 16px; }
    .admin-header { margin-bottom: 32px; }
    .admin-header h1 { margin: 0 0 8px 0; }
    .admin-header .actions { margin-top: 16px; }
    .admin-header .actions a { 
      display: inline-block; 
      padding: 8px 16px; 
      background: #0066cc; 
      color: white; 
      text-decoration: none; 
      border-radius: 4px; 
    }
    .admin-header .actions a:hover { background: #0052a3; }
    
    .stats { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
    .stat-card { 
      flex: 1; 
      min-width: 200px; 
      padding: 20px; 
      background: #f5f5f5; 
      border-radius: 8px; 
      border-left: 4px solid #0066cc;
    }
    .stat-card h3 { margin: 0 0 8px 0; font-size: 14px; color: #666; }
    .stat-card .value { font-size: 32px; font-weight: bold; color: #111; }
    
    .specs-table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
    .specs-table th { 
      background: #f9fafb; 
      padding: 12px 16px; 
      text-align: left; 
      font-weight: 600; 
      border-bottom: 2px solid #e5e7eb;
      font-size: 14px;
      color: #111;
    }
    .specs-table td { 
      padding: 12px 16px; 
      border-bottom: 1px solid #e5e7eb;
      color: #111;
      font-size: 14px;
    }
    .specs-table tr:hover { background: #f9fafb; }
    .specs-table a { color: #0066cc; text-decoration: none; }
    .specs-table a:hover { text-decoration: underline; }
    .badge { 
      display: inline-block; 
      padding: 4px 8px; 
      background: #e0e7ff; 
      color: #3730a3; 
      border-radius: 4px; 
      font-size: 12px; 
      font-weight: 500;
    }
    .empty-state { 
      text-align: center; 
      padding: 60px 20px; 
      background: white; 
      border-radius: 8px; 
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    .empty-state h2 { color: #666; margin-bottom: 16px; }
    .error-message { 
      padding: 16px; 
      background: #fee; 
      border-left: 4px solid #c00; 
      margin-bottom: 24px; 
      border-radius: 4px;
    }
  </style>
</head>
<body>
  <div class="admin-container">
    <div class="admin-header">
      <h1>📋 Formulaires complétés</h1>
      <p>Consultez et gérez tous les cahiers des charges générés</p>
      <div class="actions">
        <a href="/">← Retour au formulaire</a>
      </div>
    </div>

    <?php if (isset($error)): ?>
      <div class="error-message">
        <strong>Erreur de connexion à la base de données:</strong> <?php echo e($error); ?>
      </div>
    <?php endif; ?>

    <div class="stats">
      <div class="stat-card">
        <h3>Total des formulaires</h3>
        <div class="value"><?php echo count($specs); ?></div>
      </div>
      <div class="stat-card">
        <h3>Dernier ajout</h3>
        <div class="value" style="font-size: 18px;">
          <?php 
          if (count($specs) > 0) {
            $date = new DateTime($specs[0]['created_at']);
            echo e($date->format('d/m/Y H:i'));
          } else {
            echo 'Aucun';
          }
          ?>
        </div>
      </div>
    </div>

    <?php if (count($specs) === 0): ?>
      <div class="empty-state">
        <h2>Aucun formulaire enregistré</h2>
        <p>Les formulaires complétés apparaîtront ici.</p>
      </div>
    <?php else: ?>
      <table class="specs-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Date</th>
            <th>Organisation</th>
            <th>Contact</th>
            <th>Type de projet</th>
            <th>Budget</th>
            <th>Délais</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($specs as $spec): ?>
            <tr>
              <td><strong>#<?php echo e((string)$spec['id']); ?></strong></td>
              <td>
                <?php 
                $date = new DateTime($spec['created_at']);
                echo e($date->format('d/m/Y H:i'));
                ?>
              </td>
              <td><?php echo e($spec['org_name'] ?? '—'); ?></td>
              <td>
                <?php echo e($spec['contact_name'] ?? '—'); ?>
                <?php if ($spec['contact_email']): ?>
                  <br><small style="color: #666;"><?php echo e($spec['contact_email']); ?></small>
                <?php endif; ?>
              </td>
              <td>
                <span class="badge"><?php echo e($spec['project_type'] ?? 'N/A'); ?></span>
              </td>
              <td><?php echo e($spec['budget'] ? number_format((float)$spec['budget'], 0, ',', ' ') . ' €' : '—'); ?></td>
              <td><?php echo e($spec['timeline'] ?? '—'); ?></td>
              <td>
                <a href="/generate?id=<?php echo e((string)$spec['id']); ?>" target="_blank">Voir le cahier →</a>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    <?php endif; ?>
  </div>
</body>
</html>

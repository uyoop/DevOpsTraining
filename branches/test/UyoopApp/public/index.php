<?php
// UyoopApp minimal index.php
declare(strict_types=1);

// Basic routing for one-file app
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($path === '/generate') {
    require __DIR__ . '/../src/generate.php';
    exit;
}

if ($path === '/api/save') {
    require __DIR__ . '/../src/api_save.php';
    exit;
}

?><!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Uyoop – Recueil besoins & Cahier des charges</title>
  <link rel="icon" type="image/png" href="/assets/uyoop-logo.png" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/assets/style.css" />
</head>
<body>
  <header class="site-header">
    <div class="container">
      <div class="brand">
        <img src="/assets/uyoop-logo.png" alt="Uyoop logo" onerror="this.style.display='none'" />
        <div>
          <h1>uyoop</h1>
          <p>Formulaire intelligent pour générer un cahier des charges professionnel.</p>
        </div>
      </div>
    </div>
  </header>

  <main class="container">
    <section class="card">
      <form id="need-form" autocomplete="on">
        <h2>Votre projet</h2>
        <div class="grid">
          <label class="field">
            <span>Type de projet</span>
            <select name="project_type" id="project_type" required>
              <option value="">Sélectionner…</option>
              <option value="audit">Audit / Numérique</option>
              <option value="website">Création site web</option>
              <option value="app">Application web/mobile</option>
              <option value="devops">DEVOPS / Infra</option>
            </select>
          </label>

          <label class="field">
            <span>Nom de l'organisation</span>
            <input type="text" name="org_name" placeholder="Ex: Acme SAS" required />
          </label>

          <label class="field">
            <span>Contact principal</span>
            <input type="text" name="contact_name" placeholder="Nom Prénom" required />
          </label>

          <label class="field">
            <span>Email</span>
            <input type="email" name="contact_email" placeholder="email@domaine.fr" required />
          </label>
        </div>

        <div id="conditional-sections"></div>

        <h2>Contraintes & objectifs</h2>
        <div class="grid">
          <label class="field">
            <span>Budget cible (€)</span>
            <input type="number" name="budget" min="0" step="100" />
          </label>
          <label class="field">
            <span>Délais souhaités</span>
            <input type="text" name="timeline" placeholder="Ex: 8-12 semaines" />
          </label>
          <label class="field">
            <span>Objectifs clés</span>
            <textarea name="goals" rows="3" placeholder="Ex: générer des leads, optimiser parcours client…"></textarea>
          </label>
        </div>

        <div class="actions">
          <button type="button" id="preview-btn">Prévisualiser le cahier des charges</button>
          <button type="submit">Enregistrer & Générer</button>
        </div>
      </form>
    </section>

    <section class="card" id="preview" hidden>
      <h2>Aperçu du cahier des charges</h2>
      <div id="preview-content"></div>
      <div class="actions">
        <a class="button" href="/generate" id="download-link">Télécharger (HTML)</a>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <small>© 2025 uyoop</small>
  </footer>

  <script src="/assets/app.js"></script>
</body>
</html>

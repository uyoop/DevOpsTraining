<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'db-config.php';

function getArticles(PDO $PDO)
{
  $sql = "SELECT * FROM articles ORDER BY id DESC";
  $result = $PDO->query($sql);

  $articles = $result->fetchAll(PDO::FETCH_ASSOC);

  $result->closeCursor();

  return $articles;
}
?>

<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Ma propre image Docker !</title>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
  <link href="../../dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="navbar-top-fixed.css" rel="stylesheet">
</head>
<body>
  <nav class="navbar navbar-expand-md navbar-dark bg-dark mb-4">
    <a class="navbar-brand" href="#">Ma propre image Docker</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarCollapse">
      <ul class="navbar-nav mr-auto">
        <li class="nav-item">
          <a class="nav-link" href="#">Accueil</a>
        </li>
        <li class="nav-item active">
          <a class="nav-link" href="#">Articles <span class="sr-only">(current)</span></a>
        </li>
      </ul>
    </div>
  </nav>
  <main role="main" class="container">
    <h1 class="mt-5">Articles</h1>
    <hr>
    <h2 class="mt-5 mb-3">Nouveau article</h2>
    <form action="validation.php" method="post">
      <div class="form-group">
        <label for="title">Titre <span style="color: red; font-weight: bold;">*</span></label>
        <input type="text" class="form-control" id="title" name="title" placeholder="titre de votre article" required="required">
      </div>
      <div class="form-group">
        <label for="author">Nom de l'auteur <span style="color: red; font-weight: bold;">*</span></label>
        <input type="text" class="form-control" id="author" name="author" placeholder="Nom de l'auteur" required="required">
      </div>
      <div class="form-group">
        <label for="content">Contenu <span style="color: red; font-weight: bold;">*</span></label>
        <textarea class="form-control" id="content" name="content" rows="3" required="required"></textarea>
      </div>
      <button type="submit" class="btn btn-primary">Envoyer</button>
    </form>
    <hr>
    <h2 class="mt-5 mb-5">Liste d'articles</h2>
    <?php
    try {
      $PDO = new PDO(DB_DSN, DB_USER, DB_PASS, $options);
      $articles = getArticles($PDO);
      foreach ($articles as $article) {
        echo '<div class="card mb-3">';
        echo '<div class="card-body">';
        echo '<h5 class="card-title">' . htmlspecialchars($article['title']) . '</h5>';
        echo '<h6 class="card-subtitle mb-2 text-muted">' . htmlspecialchars($article['author']) . ' - ' . $article['date'] . '</h6>';
        echo '<p class="card-text">' . nl2br(htmlspecialchars($article['content'])) . '</p>';
        echo '</div>';
        echo '</div>';
      }
    } catch (PDOException $e) {
      echo '<div class="alert alert-danger">Erreur de connexion à la base de données : ' . $e->getMessage() . '</div>';
    }
    ?>
  </main>
</body>
</html>

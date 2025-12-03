<?php
require 'db-config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = $_POST['title'] ?? '';
    $author = $_POST['author'] ?? '';
    $content = $_POST['content'] ?? '';

    if ($title && $author && $content) {
        try {
            $PDO = new PDO(DB_DSN, DB_USER, DB_PASS, $options);
            $stmt = $PDO->prepare('INSERT INTO articles (title, author, content) VALUES (?, ?, ?)');
            $stmt->execute([$title, $author, $content]);
            header('Location: index.php');
            exit;
        } catch (PDOException $e) {
            echo 'Erreur : ' . $e->getMessage();
        }
    } else {
        echo 'Tous les champs sont obligatoires.';
    }
} else {
    header('Location: index.php');
    exit;
}

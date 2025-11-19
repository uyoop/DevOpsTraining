<?php
$mysqli = @new mysqli('192.168.56.11', 'tp_user', 'tp_password', 'tp_db');
if ($mysqli->connect_errno) {
    echo "<h1>Erreur de connexion à la base de données</h1>\n";
    echo "<p>Erreur: " . htmlspecialchars($mysqli->connect_error) . "</p>\n";
    exit;
}
echo "<h1>Connexion à la base de données réussie&nbsp;!</h1>\n";
$mysqli->close();
?>

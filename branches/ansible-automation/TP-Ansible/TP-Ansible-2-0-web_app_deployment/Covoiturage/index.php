<?php
// index.php
require 'db.php';

$message = '';

// Traitement des formulaires
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    if ($action === 'add_trip') {
        // Récupération des champs
        $driver_name   = trim($_POST['driver_name'] ?? '');
        $driver_email  = trim($_POST['driver_email'] ?? '');
        $driver_idafpa = trim($_POST['driver_idafpa'] ?? '');
        $from_city     = trim($_POST['from_city'] ?? '');
        $to_city       = trim($_POST['to_city'] ?? '');
        $trip_date     = $_POST['trip_date'] ?? '';
        $trip_time     = $_POST['trip_time'] ?? '';
        $seats_total   = (int)($_POST['seats_total'] ?? 0);

        if ($driver_name && $driver_email && $driver_idafpa && $from_city && $to_city && $trip_date && $trip_time && $seats_total > 0) {
            $stmt = $pdo->prepare("
                INSERT INTO trips 
                (driver_name, driver_email, driver_idafpa, from_city, to_city, trip_date, trip_time, seats_total) 
                VALUES 
                (:driver_name, :driver_email, :driver_idafpa, :from_city, :to_city, :trip_date, :trip_time, :seats_total)
            ");
            $stmt->execute([
                ':driver_name'   => $driver_name,
                ':driver_email'  => $driver_email,
                ':driver_idafpa' => $driver_idafpa,
                ':from_city'     => $from_city,
                ':to_city'       => $to_city,
                ':trip_date'     => $trip_date,
                ':trip_time'     => $trip_time,
                ':seats_total'   => $seats_total,
            ]);
            $message = "Trajet ajouté avec succès.";
        } else {
            $message = "Merci de remplir tous les champs du trajet.";
        }
    }

    if ($action === 'reserve') {
        $trip_id          = (int)($_POST['trip_id'] ?? 0);
        $passenger_name   = trim($_POST['passenger_name'] ?? '');
        $passenger_email  = trim($_POST['passenger_email'] ?? '');
        $passenger_idafpa = trim($_POST['passenger_idafpa'] ?? '');
        $seats_requested  = (int)($_POST['seats'] ?? 0);

        if ($trip_id > 0 && $passenger_name && $passenger_email && $passenger_idafpa && $seats_requested > 0) {

            // Récupérer le trajet pour connaître les places dispo
            $stmt = $pdo->prepare("SELECT * FROM trips WHERE id = :id");
            $stmt->execute([':id' => $trip_id]);
            $trip = $stmt->fetch();

            if ($trip) {
                $available = $trip['seats_total'] - $trip['seats_taken'];

                if ($seats_requested <= $available) {
                    // 1) Insérer la réservation
                    $pdo->beginTransaction();

                    try {
                        $stmt = $pdo->prepare("
                            INSERT INTO reservations (trip_id, passenger_name, passenger_email, passenger_idafpa, seats)
                            VALUES (:trip_id, :passenger_name, :passenger_email, :passenger_idafpa, :seats)
                        ");
                        $stmt->execute([
                            ':trip_id'          => $trip_id,
                            ':passenger_name'   => $passenger_name,
                            ':passenger_email'  => $passenger_email,
                            ':passenger_idafpa' => $passenger_idafpa,
                            ':seats'            => $seats_requested,
                        ]);

                        // 2) Mettre à jour le nombre de places prises
                        $stmt = $pdo->prepare("
                            UPDATE trips 
                            SET seats_taken = seats_taken + :seats 
                            WHERE id = :id
                        ");
                        $stmt->execute([
                            ':seats' => $seats_requested,
                            ':id'    => $trip_id,
                        ]);

                        $pdo->commit();
                        $message = "Réservation enregistrée.";
                    } catch (Exception $e) {
                        $pdo->rollBack();
                        $message = "Erreur lors de la réservation : " . htmlspecialchars($e->getMessage());
                    }

                } else {
                    $message = "Pas assez de places disponibles pour ce trajet.";
                }
            } else {
                $message = "Trajet introuvable.";
            }
        } else {
            $message = "Merci de remplir tous les champs de réservation.";
        }
    }
}

// Récupération des trajets à afficher (ex : à partir d'aujourd'hui)
$stmt = $pdo->query("
    SELECT * 
    FROM trips 
    ORDER BY trip_date ASC, trip_time ASC
");
$trips = $stmt->fetchAll();

?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Mini covoiturage AFPA</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<h1>Mini covoiturage AFPA</h1>

<?php if ($message): ?>
    <div class="message">
        <?= htmlspecialchars($message) ?>
    </div>
<?php endif; ?>

<section class="card">
    <h2>Proposer un trajet</h2>
    <form method="post">
        <input type="hidden" name="action" value="add_trip">

        <h3>Vos infos</h3>
        <label>Nom d'affichage :
            <input type="text" name="driver_name" required>
        </label>
        <label>Email :
            <input type="email" name="driver_email" required>
        </label>
        <label>ID AFPA :
            <input type="text" name="driver_idafpa" required>
        </label>

        <h3>Trajet</h3>
        <label>Ville de départ :
            <input type="text" name="from_city" required>
        </label>
        <label>Ville d'arrivée :
            <input type="text" name="to_city" required>
        </label>
        <label>Date :
            <input type="date" name="trip_date" required>
        </label>
        <label>Heure :
            <input type="time" name="trip_time" required>
        </label>
        <label>Nombre de places :
            <input type="number" name="seats_total" min="1" required>
        </label>

        <button type="submit">Publier le trajet</button>
    </form>
</section>

<section class="card">
    <h2>Trajets disponibles</h2>

    <?php if (empty($trips)): ?>
        <p>Aucun trajet pour le moment.</p>
    <?php else: ?>
        <?php foreach ($trips as $trip): 
            $available = $trip['seats_total'] - $trip['seats_taken'];
        ?>
            <div class="trip">
                <div class="trip-info">
                    <strong><?= htmlspecialchars($trip['from_city']) ?> → <?= htmlspecialchars($trip['to_city']) ?></strong><br>
                    Le <?= htmlspecialchars($trip['trip_date']) ?> à <?= htmlspecialchars(substr($trip['trip_time'], 0, 5)) ?><br>
                    Conducteur : <?= htmlspecialchars($trip['driver_name']) ?> (<?= htmlspecialchars($trip['driver_email']) ?>)<br>
                    Places : <?= (int)$trip['seats_total'] ?> au total, 
                    <?= (int)$available ?> restantes
                </div>

                <?php if ($available > 0): ?>
                    <form method="post" class="reserve-form">
                        <input type="hidden" name="action" value="reserve">
                        <input type="hidden" name="trip_id" value="<?= (int)$trip['id'] ?>">

                        <h4>Réserver</h4>
                        <label>Nom d'affichage :
                            <input type="text" name="passenger_name" required>
                        </label>
                        <label>Email :
                            <input type="email" name="passenger_email" required>
                        </label>
                        <label>ID AFPA :
                            <input type="text" name="passenger_idafpa" required>
                        </label>
                        <label>Places à réserver :
                            <input type="number" name="seats" min="1" max="<?= (int)$available ?>" required>
                        </label>
                        <button type="submit">Réserver</button>
                    </form>
                <?php else: ?>
                    <p class="full">Complet</p>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</section>

</body>
</html>
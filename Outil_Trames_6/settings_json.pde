/**
 * Persistance des réglages : {@code data/reglages.json} (convention Processing).
 *
 * <p><b>Schéma reglages.json</b> (tous les nombres sont des flottants sauf mention) :
 * <ul>
 *   <li>{@code version} — entier, voir {@link #SETTINGS_VERSION} (évolution du schéma).</li>
 *   <li>{@code nombreDangles} — int, 1–12, nombre de calques de trame.</li>
 *   <li>{@code sensibiliteMinimum}, {@code sensibiliteMaximum} — 0.001–0.999, seuils.</li>
 *   <li>{@code minPas}, {@code maxPas} — 3–100, écart entre traits.</li>
 *   <li>{@code angleDepartDeg} — 0–180, angle de départ en degrés.</li>
 *   <li>{@code tonImagePreview} — −1 à +2.5, ton clair/sombre + contraste (aperçu).</li>
 *   <li>{@code tramagePhotoEnNoirEtBlanc} — booléen, tramage sur image en N&amp;B (défaut true).</li>
 *   <li>{@code optimLignesPontPx} — 0–15, fusion de traits sur le même rayon (px document).</li>
 *   <li>{@code optimLignesMinLongueurPx} — 0–12, longueur minimale des segments (px document).</li>
 * </ul>
 * Clé obsolète {@code contrasteImage} : encore lue pour dériver {@code tonImagePreview}
 * si {@code tonImagePreview} est absent ; plus réécrite à la sauvegarde.
 */

final String FICHIER_REGLAGES_JSON = "reglages.json";

/** Inscrit dans reglages.json ; incrémenter si le schéma des champs change. */
final int SETTINGS_VERSION = 6;
static final int SETTINGS_SAVE_MIN_INTERVAL_MS = 300;
/** Évite d'écrire le disque à chaque pas de slider (controlEvent très fréquent). */
int _settingsSauvegardeDernierMillis = -SETTINGS_SAVE_MIN_INTERVAL_MS;


String cheminReglagesJson() {
  return dataPath(FICHIER_REGLAGES_JSON);
}


void appliquerReglagesDepuisJSONObject(JSONObject j) {
  if (j == null) return;

  if (j.hasKey("nombreDangles")) {
    nombreDangles = constrain(j.getInt("nombreDangles"), 1, 12);
  }
  if (j.hasKey("sensibiliteMinimum")) {
    sensibiliteMinimum = constrain(j.getFloat("sensibiliteMinimum"), 0.001f, 0.999f);
  }
  if (j.hasKey("sensibiliteMaximum")) {
    sensibiliteMaximum = constrain(j.getFloat("sensibiliteMaximum"), 0.001f, 0.999f);
  }
  if (j.hasKey("minPas")) {
    minPas = constrain(j.getFloat("minPas"), 3, 100);
  }
  if (j.hasKey("maxPas")) {
    maxPas = constrain(j.getFloat("maxPas"), 3, 100);
  }
  if (j.hasKey("angleDepartDeg")) {
    angleDepartDeg = constrain(j.getFloat("angleDepartDeg"), 0, 180);
  }
  if (j.hasKey("tramagePhotoEnNoirEtBlanc")) {
    tramagePhotoEnNoirEtBlanc = j.getBoolean("tramagePhotoEnNoirEtBlanc");
  }
  if (j.hasKey("optimLignesPontPx")) {
    optimLignesPontPx = constrain(j.getFloat("optimLignesPontPx"), 0, 15);
  }
  if (j.hasKey("optimLignesMinLongueurPx")) {
    optimLignesMinLongueurPx = constrain(j.getFloat("optimLignesMinLongueurPx"), 0, 12);
  }
  if (j.hasKey("tonImagePreview")) {
    tonImagePreview = constrain(j.getFloat("tonImagePreview"), -1, 2.5f);
  } else if (j.hasKey("contrasteImage")) {
    float c = j.getFloat("contrasteImage");
    tonImagePreview = constrain((c - 1.0f) / 0.95f, -1, 2.5f);
  }
  angleDepart = radians(angleDepartDeg);
}


void chargerSettingsDepuisFichier() {
  String chemin = cheminReglagesJson();
  if (!new java.io.File(chemin).exists()) {
    return;
  }
  try {
    JSONObject j = loadJSONObject(chemin);
    appliquerReglagesDepuisJSONObject(j);
  } catch (Exception e) {
    println("Lecture réglages impossible : " + e.getMessage());
  }
}


/** Sauvegarde avec garde anti-spam (sliders). À la fermeture, voir sauvegarderSettingsVersFichierMaintenant + exit(). */
void sauvegarderSettingsVersFichier() {
  int now = millis();
  if (now - _settingsSauvegardeDernierMillis < SETTINGS_SAVE_MIN_INTERVAL_MS) {
    return;
  }
  _settingsSauvegardeDernierMillis = now;
  sauvegarderSettingsVersFichierMaintenant();
}


void sauvegarderSettingsVersFichierMaintenant() {
  try {
    JSONObject j = new JSONObject();
    j.setInt("version", SETTINGS_VERSION);
    j.setInt("nombreDangles", nombreDangles);
    j.setFloat("sensibiliteMinimum", sensibiliteMinimum);
    j.setFloat("sensibiliteMaximum", sensibiliteMaximum);
    j.setFloat("minPas", minPas);
    j.setFloat("maxPas", maxPas);
    j.setFloat("angleDepartDeg", angleDepartDeg);
    j.setBoolean("tramagePhotoEnNoirEtBlanc", tramagePhotoEnNoirEtBlanc);
    j.setFloat("optimLignesPontPx", optimLignesPontPx);
    j.setFloat("optimLignesMinLongueurPx", optimLignesMinLongueurPx);
    j.setFloat("tonImagePreview", tonImagePreview);
    String chemin = cheminReglagesJson();
    java.io.File parent = new java.io.File(chemin).getParentFile();
    if (parent != null && !parent.exists()) {
      parent.mkdirs();
    }
    saveJSONObject(j, chemin);
    println("Réglages enregistrés : data/" + FICHIER_REGLAGES_JSON);
  } catch (Exception e) {
    println("Écriture " + FICHIER_REGLAGES_JSON + " impossible : " + e.getMessage());
  }
}


/** L’IDE n’appelle pas toujours {@code dispose()} à la fermeture ; {@code exit()} est plus fiable. */
void exit() {
  sauvegarderSettingsVersFichierMaintenant();
  super.exit();
}


void dispose() {
  sauvegarderSettingsVersFichierMaintenant();
  super.dispose();
}

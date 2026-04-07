import drop.*;

/** Géré ici avec le dialogue fichier : une seule entrée « charger image ». */
SDrop drop;

void initialiserGlisserDeposer() {
  drop = new SDrop(this);
}

void dropEvent(DropEvent e) {
  if (!e.isFile()) return;
  File f = e.file();
  if (f == null || !f.isFile()) return;
  chargeImageDepuisChemin(f.getAbsolutePath());
}


String prefixe(String s) {
  // pour obtenir le nom du ficher sans le chemin et sans extension
  String filename = s.substring(s.lastIndexOf('/') + 1);
  String[][] s2 = matchAll(filename.toLowerCase(), "(.*)\\.(png|jpg|jpeg|gif)$");
  if (s2 != null) {
    s = s2[0][1];
  }
  return s;
}

void choisisFichier() {
  selectInput("Sélectionnez le fichier à traiter :", "fileSelected");
}

/** Ouvre une image si l’extension est acceptée (glisser-déposer ou dialogue fichier). */
void chargeImageDepuisChemin(String cheminAbsolu) {
  if (cheminAbsolu == null) return;
  String[][] s2 = matchAll(cheminAbsolu, "\\A((.*)\\.(png|jpg|jpeg|gif|PNG|JPG|JPEG|GIF))$");
  if (s2 == null) {
    println("Formats acceptés : png, jpg, gif — " + cheminAbsolu);
    return;
  }
  println("Chargement : " + cheminAbsolu);
  background(255);
  traitementDuneImage t = new traitementDuneImage(cheminAbsolu);
  enCours = t.imageChargeeOk() ? t : null;
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Aucun fichier choisi");
    return;
  }
  chargeImageDepuisChemin(selection.getAbsolutePath());
}


PImage _bufferTonNiveaux;

/**
 * Copie en niveaux de gris : chaque pixel devient R=G=B= {@code brightness(pixel)} (Processing),
 * même modèle que {@code getLignes} (tramage_lignes.pde) pour l’échantillonnage. Alpha conservé.
 */
PImage copierImageNiveauxGris(PImage src) {
  if (src == null) {
    return null;
  }
  PImage out = createImage(src.width, src.height, ARGB);
  src.loadPixels();
  out.loadPixels();
  for (int i = 0; i < src.pixels.length; i++) {
    int p = src.pixels[i];
    float g = brightness(p);
    int a = (p >> 24) & 0xFF;
    int ig = constrain(round(g), 0, 255);
    out.pixels[i] = (a << 24) | (ig << 16) | (ig << 8) | ig;
  }
  out.updatePixels();
  return out;
}

/**
 * Un seul paramètre {@code ton} dans [-1, 2.5] : contraste (étirement autour du gris médian)
 * et luminosité additive couplés — gauche = plus sombre / plus plat, droite = plus clair / plus punchy.
 * Sur une image déjà en N&amp;B, le réglage agit sur la luminance (R=G=B).
 */
PImage imageAvecTonNiveaux(PImage src, float ton) {
  if (src == null) {
    return null;
  }
  ton = constrain(ton, -1, 2.5);
  float contraste = constrain(1.0 + ton * 0.95, 0.35, 4.2);
  float lumi = ton * 0.22;
  if (_bufferTonNiveaux == null
      || _bufferTonNiveaux.width != src.width
      || _bufferTonNiveaux.height != src.height) {
    _bufferTonNiveaux = createImage(src.width, src.height, ARGB);
  }
  _bufferTonNiveaux.copy(src, 0, 0, src.width, src.height, 0, 0, src.width, src.height);
  _bufferTonNiveaux.loadPixels();
  for (int i = 0; i < _bufferTonNiveaux.pixels.length; i++) {
    int p = _bufferTonNiveaux.pixels[i];
    int a = (p >> 24) & 0xFF;
    if (a == 0) {
      continue;
    }
    float rr = ((p >> 16) & 0xFF) / 255.0;
    float gg = ((p >> 8) & 0xFF) / 255.0;
    float bb = (p & 0xFF) / 255.0;
    rr = constrain((rr - 0.5) * contraste + 0.5 + lumi, 0, 1);
    gg = constrain((gg - 0.5) * contraste + 0.5 + lumi, 0, 1);
    bb = constrain((bb - 0.5) * contraste + 0.5 + lumi, 0, 1);
    _bufferTonNiveaux.pixels[i] = (a << 24)
      | ((int) (rr * 255) << 16)
      | ((int) (gg * 255) << 8)
      | (int) (bb * 255);
  }
  _bufferTonNiveaux.updatePixels();
  return _bufferTonNiveaux;
}

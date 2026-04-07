/** Zone du slider ton [x, y, w, h] pour savoir si le clic démarre une manip « ton » uniquement. */
float[] rectHitSliderTonPhoto = new float[] { 0, 0, 0, 0 };
/** Calque photo : actif seulement entre un clic sur le slider ton et le relâchement souris. */
boolean apercuTonPhotoEnCours = false;


void creeInterface() {
  int pad = 14;
  int barW = UI_PANEL_W - 2 * pad;
  float x = width - UI_PANEL_W + pad;
  float y = 26;
  cp5 = new ControlP5(this);

  if (fonteUI != null) {
    cp5.setFont(new ControlFont(fonteUI, 8));
  }

  styleControleP5(cp5);

  cp5.addTextlabel("tl_ton")
    .setText("ton — clair / sombre + contraste (luminance)")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  rectHitSliderTonPhoto[0] = x - 6;
  rectHitSliderTonPhoto[1] = y - 12;
  rectHitSliderTonPhoto[2] = barW + 12;
  rectHitSliderTonPhoto[3] = 18 + 24;
  cp5.addSlider("tonImagePreview")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(-1, 2.5)
    .setValue(tonImagePreview)
    .setDecimalPrecision(2)
    .setLabel("");
  attacherCallbacksSliderTonPhoto();
  y += 18 + 16;

  cp5.addTextlabel("tl_nb")
    .setText("tramage sur photo N&B (défaut)")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addToggle("tog_nb_tramage")
    .setPosition(x, y)
    .setSize(44, 18)
    .setMode(ControlP5.SWITCH)
    .setState(tramagePhotoEnNoirEtBlanc)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_nd")
    .setText("nombre de calques")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("ndCalques")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(1, 12)
    .setValue(nombreDangles)
    .setNumberOfTickMarks(11)
    .setDecimalPrecision(0)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_smin")
    .setText("seuil mini")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("sensibiliteMinimum")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(0.001, 0.999)
    .setValue(sensibiliteMinimum)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_smax")
    .setText("seuil maxi")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("sensibiliteMaximum")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(0.001, 0.999)
    .setValue(sensibiliteMaximum)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_pmin")
    .setText("écart mini")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("minPas")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(3, 100)
    .setValue(minPas)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_pmax")
    .setText("écart maxi")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("maxPas")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(3, 100)
    .setValue(maxPas)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_ang")
    .setText("angle départ (°)")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("angleDepartDeg")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(0, 180)
    .setValue(angleDepartDeg)
    .setDecimalPrecision(0)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_pont")
    .setText("fusion traits (px doc.)")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("optimLignesPontPx")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(0, 15)
    .setValue(optimLignesPontPx)
    .setDecimalPrecision(1)
    .setLabel("");
  y += 18 + 12;

  cp5.addTextlabel("tl_minlen")
    .setText("longueur mini segment (px)")
    .setPosition(x, y)
    .setColorValue(color(0));
  y += 12;
  cp5.addSlider("optimLignesMinLongueurPx")
    .setPosition(x, y)
    .setSize(barW, 18)
    .setRange(0, 12)
    .setValue(optimLignesMinLongueurPx)
    .setDecimalPrecision(1)
    .setLabel("");
  y += 18 + 12;

  cp5.addButton("exportSvgFichiersSepares")
    .setPosition(x, y)
    .setSize(barW, 28)
    .setLabel("SVG fichiers séparés (S)");
  y += 36;

  cp5.addButton("exportSvgCalquesBantam")
    .setPosition(x, y)
    .setSize(barW, 28)
    .setLabel("SVG calques (1 fichier)");
}


/**
 * Après chargerSettingsDepuisFichier() (settings_json.pde), aligne les curseurs ControlP5
 * sur les globales, y compris {@code tonImagePreview} lu dans data/reglages.json.
 */
void synchroniserSlidersControlP5DepuisVariables() {
  if (cp5 == null) {
    return;
  }
  reglerSliderSansBroadcast("ndCalques", nombreDangles);
  reglerSliderSansBroadcast("sensibiliteMinimum", sensibiliteMinimum);
  reglerSliderSansBroadcast("sensibiliteMaximum", sensibiliteMaximum);
  reglerSliderSansBroadcast("minPas", minPas);
  reglerSliderSansBroadcast("maxPas", maxPas);
  reglerSliderSansBroadcast("angleDepartDeg", angleDepartDeg);
  reglerSliderSansBroadcast("tonImagePreview", tonImagePreview);
  reglerSliderSansBroadcast("optimLignesPontPx", optimLignesPontPx);
  reglerSliderSansBroadcast("optimLignesMinLongueurPx", optimLignesMinLongueurPx);
  Controller tnb = cp5.getController("tog_nb_tramage");
  if (tnb instanceof Toggle) {
    Toggle tg = (Toggle) tnb;
    boolean br = tg.isBroadcast();
    tg.setBroadcast(false);
    tg.setState(tramagePhotoEnNoirEtBlanc);
    tg.setBroadcast(br);
  }
}


void reglerSliderSansBroadcast(String nom, float valeur) {
  Controller c = cp5.getController(nom);
  if (!(c instanceof Slider)) {
    return;
  }
  Slider sl = (Slider) c;
  boolean br = sl.isBroadcast();
  sl.setBroadcast(false);
  sl.setValue(valeur);
  sl.setBroadcast(br);
}


/** Thème bleu par défaut de ControlP5 ; valeurs numériques en blanc sur le curseur. */
void styleControleP5(ControlP5 p) {
  p.setColorCaptionLabel(color(255));
  p.setColorValueLabel(color(255));
}


/**
 * ControlP5 n’envoie pas toujours {@code mouseReleased} au sketch quand le curseur est sur un
 * contrôle : ce callback garantit la disparition du calque sur ACTION_RELEASE / RELEASE_OUTSIDE.
 */
void attacherCallbacksSliderTonPhoto() {
  Controller tonCtrl = cp5.getController("tonImagePreview");
  if (tonCtrl == null) {
    return;
  }
  tonCtrl.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent ev) {
      int a = ev.getAction();
      if (a == ControlP5.ACTION_PRESS || a == ControlP5.ACTION_DRAG || a == ControlP5.ACTION_START_DRAG) {
        if (enCours != null) {
          apercuTonPhotoEnCours = true;
        }
      }
      if (a == ControlP5.ACTION_RELEASE || a == ControlP5.ACTION_RELEASE_OUTSIDE) {
        apercuTonPhotoEnCours = false;
      }
    }
  });
}


boolean sourisSurSliderTonPhoto() {
  return mouseX >= rectHitSliderTonPhoto[0]
    && mouseX <= rectHitSliderTonPhoto[0] + rectHitSliderTonPhoto[2]
    && mouseY >= rectHitSliderTonPhoto[1]
    && mouseY <= rectHitSliderTonPhoto[1] + rectHitSliderTonPhoto[3];
}


void mousePressed() {
  if (enCours == null) {
    return;
  }
  if (!sourisSurSliderTonPhoto()) {
    apercuTonPhotoEnCours = false;
  }
}


void mouseReleased() {
  apercuTonPhotoEnCours = false;
}


void controlEvent(ControlEvent e) {
  if (!e.isController()) return;
  Controller c = e.getController();
  if (c instanceof Slider && !"tonImagePreview".equals(c.getName())) {
    apercuTonPhotoEnCours = false;
  }
  if (c instanceof Button) {
    apercuTonPhotoEnCours = false;
    return;
  }
  if (c.getName().equals("tog_nb_tramage") && c instanceof Toggle) {
    tramagePhotoEnNoirEtBlanc = ((Toggle) c).getState();
    if (enCours != null) {
      enCours.reconstruireSourceEtPreview();
    }
    ilYaEuUneMiseAjour = true;
    sauvegarderSettingsVersFichier();
    return;
  }
  if (c.getName().equals("tonImagePreview")) {
    sauvegarderSettingsVersFichier();
    return;
  }
  if (c.getName().equals("ndCalques")) {
    nombreDangles = constrain(round(c.getValue()), 1, 12);
    Slider sl = (Slider) c;
    boolean br = sl.isBroadcast();
    sl.setBroadcast(false);
    sl.setValue(nombreDangles);
    sl.setBroadcast(br);
  }
  angleDepart = radians(angleDepartDeg);
  ilYaEuUneMiseAjour = true;
  sauvegarderSettingsVersFichier();
}


/**
 * Calque photo : affiché pendant la manip du slider ton (callback ControlP5 press/drag) ;
 * masqué au relâchement (callback release + mouseReleased secours), ou dès qu’un autre slider / bouton est utilisé.
 */
boolean apercuReglageTonPhotoActif() {
  return enCours != null && apercuTonPhotoEnCours;
}


/** Superpose la preview avec {@code tonImagePreview} (contraste + lumière couplés). */
void dessineCalqueTonPhotoSurApercu() {
  if (enCours == null || enCours.preview == null) {
    return;
  }
  float[] r = new float[4];
  calculerCadreApercuTrame(enCours.source.width, enCours.source.height, r);
  PImage mod = imageAvecTonNiveaux(enCours.preview, tonImagePreview);
  if (mod != null) {
    image(mod, r[0], r[1], r[2], r[3]);
  }
}


void afficheInterface() {
  float zw = width - UI_PANEL_W;

  if (enCours == null) {
    fill(255);
    noStroke();
    rect(0, 0, zw, height);
    dessineInviteCentreeHelvetica(zw);
  }

  fill(255);
  noStroke();
  rect(zw, 0, UI_PANEL_W, height);

  dessineInfosBasZoneImage(zw);
}


/** Interligne 120 % du corps 12 → 14,4 pt, texte centré dans la zone image. */
void dessineInviteCentreeHelvetica(float zw) {
  if (fonteInviteInfos == null) return;
  pushStyle();
  textFont(fonteInviteInfos);
  textLeading(UI_TEXTE_INTERLIGNE);
  textAlign(CENTER, BASELINE);
  fill(52, 52, 58);
  float cx = zw * 0.5;
  float cy = (height - UI_BANDEAU_ZONE_IMAGE) * 0.5;
  float lh = UI_TEXTE_INTERLIGNE;
  String[] lignes = {
    "Glissez-déposez une image",
    "Formats : png · jpg · gif",
    "Touche O pour ouvrir le sélecteur de fichiers"
  };
  float blocH = (lignes.length - 1) * lh + 11;
  float y0 = cy - blocH * 0.5;
  for (int i = 0; i < lignes.length; i++) {
    text(lignes[i], cx, y0 + i * lh);
  }
  popStyle();
}


/** Raccourcis en bas de la zone image, alignés à gauche, lisibles sur l’aperçu. */
void dessineInfosBasZoneImage(float zw) {
  if (fonteInviteInfos == null) return;
  pushStyle();
  float lh = UI_TEXTE_INTERLIGNE;
  float padX = 18;
  float padB = 16;
  float bandH = UI_BANDEAU_ZONE_IMAGE;
  fill(255, 246);
  noStroke();
  rect(0, height - bandH, zw, bandH);
  textFont(fonteInviteInfos);
  textLeading(lh);
  textAlign(LEFT, BASELINE);
  fill(38, 38, 44);
  float y = height - padB;
  text("Autre bouton : export 1 SVG multi-calques", padX, y);
  text("s — même effet que « SVG fichiers séparés »", padX, y - lh);
  if (enCours != null && statsLignesAvantOptim > 0) {
    float gainPct = 100f * (1f - statsLignesApresOptim / (float) statsLignesAvantOptim);
    String st = "Segments (tous calques) : " + statsLignesAvantOptim + " → " + statsLignesApresOptim
      + "  (−" + nf(gainPct, 0, 1) + " %)";
    text(st, padX, y - 2 * lh);
  }
  popStyle();
}


void exportSvgFichiersSepares() {
  if (enCours == null) {
    println("Charger une image d'abord (glisser-déposer ou touche o).");
    return;
  }
  enCours.endView();
}


void exportSvgCalquesBantam() {
  if (enCours == null) {
    println("Charger une image d'abord (glisser-déposer ou touche o).");
    return;
  }
  enCours.endViewSvgCalquesInkscape();
}


void keyReleased() {
  switch (key) {
  case 's':
    exportSvgFichiersSepares();
    break;
  case 'o':
    choisisFichier();
    break;
  }
}

void keyPressed() {
  if (key == ESC) {
    // key = 0;
  }
}

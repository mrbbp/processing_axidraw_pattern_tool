/**
 * Pipeline de tramage d’une image source : construction d’une prévisualisation
 * redimensionnée ({@link #preview}), calcul des segments de ligne par calque
 * ({@link #make}), affichage PNG à l’écran ({@link #preView}), puis export
 * vectoriel pleine résolution ({@link #endView}, {@link #endViewSvgCalquesInkscape}).
 *
 * <p><b>Cycle d’usage typique</b> : instanciation avec le chemin absolu d’une image
 * (constructeur ci-dessous, depuis {@code chargeImageDepuisChemin} dans utilitaires.pde) ;
 * chaque frame, {@code draw()} appelle {@link #affiche()} tant que la variable
 * globale {@code enCours} référence cette instance. Les paramètres globaux
 * ({@code nombreDangles}, {@code sensibiliteMinimum}, {@code angleDepart}, …)
 * sont lus dans {@link #make} ; lever {@code ilYaEuUneMiseAjour} (sliders) pour
 * forcer un recalcul au prochain {@link #affiche}.
 *
 * <p><b>Coordonnées</b> : {@link #cadrePreview} et {@link #cadreEndView} délimitent
 * la zone de tramage dans l’espace de {@link #preview} et {@link #source}
 * respectivement ; {@link #reduction} est le facteur preview/source pour l’épaisseur
 * de trait à l’aperçu.
 *
 * <p><b>Correction {@link #make} (nombre de calques au maximum)</b> : l’ancienne boucle
 * {@code for (float i = 0; i < 1; i += 1f/nombreDangles)} pouvait, à cause des erreurs
 * d’arrondi flottant, exécuter <em>une itération de plus</em> que prévu (ex. 12 calques
 * → 13 passages → {@code allCalques[12]} alors que la longueur est 12). D’où
 * {@code ArrayIndexOutOfBoundsException}. La boucle a été remplacée par un compteur
 * entier {@code cl} de {@code 0} à {@code nombreDangles - 1} avec
 * {@code i = cl / (float) nombreDangles} pour conserver la même interpolation.
 */
class traitementDuneImage {
  /** Image telle que chargée depuis le fichier (couleur) ; base pour N&amp;B ou copie couleur. */
  PImage sourceFichier;
  /** Image effective du tramage (N&amp;B ou couleur selon {@code tramagePhotoEnNoirEtBlanc}). */
  PImage source, preview;
  int w, h;
  float ratio;
  float reduction;
  PVector[] cadrePreview={};
  PVector[] cadreEndView={};
  float[][] allLignes={};
  float[][][] allCalques={};

  /**
   * Charge l’image, calcule une taille d’aperçu (plafonnée à ~90 % de l’écran),
   * remplit {@link #preview}, {@link #cadrePreview}, {@link #cadreEndView} et
   * positionne la globale {@code prefixeImage} pour les noms d’export.
   *
   * @param imageATraiter chemin absolu du fichier image (png, jpg, gif)
   */
  traitementDuneImage(String imageATraiter) {
    sourceFichier = loadImage(imageATraiter);
    if (sourceFichier == null) {
      println("Image introuvable ou illisible : " + imageATraiter);
      return;
    }
    prefixeImage = prefixe(imageATraiter);
    reconstruireSourceEtPreview();
    image(source, 0, 0);
    ilYaEuUneMiseAjour=true;
    preView();
  }

  /** {@code false} si le fichier n’a pas pu être chargé. */
  boolean imageChargeeOk() {
    return sourceFichier != null;
  }

  /**
   * Recalcule {@link #source}, {@link #preview}, cadres et {@link #reduction} à partir de
   * {@link #sourceFichier} et du drapeau global {@code tramagePhotoEnNoirEtBlanc}.
   * À appeler après chargement ou changement du mode N&amp;B / couleur.
   */
  void reconstruireSourceEtPreview() {
    if (sourceFichier == null) {
      return;
    }
    int fw = sourceFichier.width;
    int fh = sourceFichier.height;
    ratio = (fw * 1.0) / fh;
    w = fw;
    h = fh;
    if (w > displayWidth * 0.9) {
      w = int(displayWidth * 0.9);
      h = int(w / ratio);
    }
    if (h > displayHeight * 0.9) {
      h = int(displayHeight * 0.9);
      w = int(h * ratio);
    }
    if (tramagePhotoEnNoirEtBlanc) {
      source = copierImageNiveauxGris(sourceFichier);
    } else {
      source = sourceFichier.copy();
    }
    preview = source.copy();
    preview.resize(w, h);
    reduction = preview.width / (float) source.width;
    cadrePreview = creeCadre(preview, marge * reduction);
    cadreEndView = creeCadre(source, marge);
  }

  /**
   * À appeler chaque frame depuis {@code draw} : si {@code ilYaEuUneMiseAjour},
   * régénère la prévisualisation puis repasse le drapeau à faux.
   */
  void affiche() {
    if (ilYaEuUneMiseAjour) {
      preView();
      ilYaEuUneMiseAjour=false; 
    }
  }

  /**
   * Calcule les segments pour tous les calques : pour chaque niveau entre
   * {@code sensibiliteMinimum} et {@code sensibiliteMaximum}, angle et pas interpolés.
   * Résultat dans {@link #allLignes} (mode non séparé) ou {@link #allCalques}
   * (un tableau de segments par calque si {@code separer}).
   * <p>Boucle sur {@code cl} entier (voir en-tête de la classe) : pas de pas flottant cumulatif sur {@code i}.
   *
   * @param wichIm image à analyser ({@link #preview} ou {@link #source})
   * @param cadre  quadrilatère de tramage (souvent {@link #cadrePreview} ou {@link #cadreEndView})
   * @param r      facteur d’échelle du pas (ex. {@link #reduction} pour l’aperçu, {@code 1f} pour l’export)
   * <p>Réinitialise {@code statsLignesAvantOptim} / {@code statsLignesApresOptim} puis, pour
   * chaque appel à {@code getLignes} (tramage_lignes.pde), passe les seuils d’optimisation
   * en coordonnées {@code wichIm} : {@code optimLignesPontPx} et {@code optimLignesMinLongueurPx}
   * (définis en px document) × {@code wichIm.width / source.width}.
   */
  void make(PImage wichIm, PVector[] cadre, float r) {
    allLignes=new float[0][4];
    allCalques=new float[nombreDangles][0][4];
    statsLignesAvantOptim = 0;
    statsLignesApresOptim = 0;
    float scaleOptim = wichIm.width / (float) source.width;
    float pontPx = optimLignesPontPx * scaleOptim;
    float minLenPx = optimLignesMinLongueurPx * scaleOptim;
    for (int cl = 0; cl < nombreDangles; cl++) {
      float i = nombreDangles <= 1 ? 0 : (float) cl / (float) nombreDangles;
      float[][] currentLignes=new float[0][4];
      float sensibilite=lerp(sensibiliteMaximum, sensibiliteMinimum, i);
      int p=int(lerp(maxPas, minPas, i));
      float angle=angleDepart+lerp(0, PI, i);
      currentLignes=getLignes(wichIm, cadre, angle, sensibilite, p*r, pontPx, minLenPx);
      if (separer) {
        allCalques[cl]=currentLignes;
      } else {
        allLignes = (float[][]) concat(allLignes, currentLignes);
      }
    }
  }

  /**
   * Recalcule le tramage sur {@link #preview} et affiche un PNG à l’écran via
   * {@code creePng} (creation_images.pde) avec dimensions document = largeur/hauteur {@link #source}
   * pour aligner le cadre avec le futur SVG.
   */
  void preView() {
    background(255);
    make(preview, cadrePreview, reduction);
    if (separer) {
  background(255);
      creePng(allCalques, preview.width, preview.height, source.width, source.height, epaisseurTrait * reduction);
    } else {
      creePng(allLignes, preview.width, preview.height, source.width, source.height, epaisseurTrait * reduction);
    }
  }

  /**
   * Export pleine résolution : écrit un ou plusieurs SVG sous {@code exports/}
   * ({@code creeSvg}) selon {@code separer}. Chaque nom inclut un suffixe horodaté
   * (voir {@code suffixeHorodatageExport} dans creation_images.pde) pour conserver les versions.
   * Affiche le dernier fichier via {@code afficheSvgApresExport}.
   */
  void endView() {
    make(source, cadreEndView, 1);
    if (separer) {
      creeSvg(allCalques, source.width, source.height);
    } else {
      creeSvg(allLignes, source.width, source.height);
    }
  }

  /**
   * Export en un seul fichier SVG : groupes {@code inkscape:layer} par calque ;
   * nom {@code prefixe_horodatage_bantam_calques.svg} sous {@code exports/} (horodatage
   * comme les autres exports). Outils type AxiDraw / Bantam / Inkscape.
   */
  void endViewSvgCalquesInkscape() {
    make(source, cadreEndView, 1);
    if (separer) {
      creeSvgInkscapeLayers(allCalques, source.width, source.height);
    } else {
      float[][][] unCalque = new float[1][][];
      unCalque[0] = allLignes;
      creeSvgInkscapeLayers(unCalque, source.width, source.height);
    }
  }
}

/**
 * Rectangle intérieur (quatre sommets) pour le tramage, avec marge uniforme par rapport aux bords de l’image.
 *
 * @param im    image dont on prend {@code width} / {@code height}
 * @param marge écart aux bords (pixels dans l’espace de {@code im})
 * @return      [haut-gauche, haut-droite, bas-droite, bas-gauche]
 */
PVector[] creeCadre(PImage im, float marge) {
  PVector[] c={};
  c=(PVector[]) append(c, new PVector(marge, marge));
  c=(PVector[]) append(c, new PVector(im.width-marge, marge));
  c=(PVector[]) append(c, new PVector(im.width-marge, im.height-marge));
  c=(PVector[]) append(c, new PVector(marge, im.height-marge));
  return c;
}

/*
 * Outil_Trames_6 — sketch version 6 (dossier + fichier .pde principal ; requis par Processing).
 *
 * Apport assistant (Cursorai + @ecb.dnmade.graphisme.rennes) — en complément du code initié par Jean-Noël Lafargue
 * ------------------------------------------------------------------
 *
 * - Interface : panneau de contrôle refait avec ControlP5 (interface.pde) — sliders,
 *   libellés, boutons d’export, controlEvent pour lier les variables globales et
 *   ilYaEuUneMiseAjour ; à la place d’une UI curseurs « maison » (mousePressed, etc.).
 *
 * - Texte français avec accents : police vectorielle Helvetica 12 pt lissée
 *   (fonteInviteInfos, createFont(..., true)) pour l’invitation centrée, le bandeau
 *   d’infos sous la zone image et les chaînes où les diacritiques comptent ; police
 *   bitmap Silkscreen .vlw dans data/ pour les contrôles ControlP5 (taille fixe 8 px).
 *
 * - Chargement d’image : glisser-déposer de fichiers sur la fenêtre (bibliothèque Drop,
 *   sojamo — utilitaires.pde, SDrop + dropEvent) en plus du dialogue fichier
 *   (selectInput / fileSelected) ; les deux chemins aboutissent à chargeImageDepuisChemin().
 *
 * - Persistance des réglages UI : onglet settings_json.pde, fichier data/reglages.json
 *   (schéma documenté en tête de settings_json.pde). Chargement dans setup() avant
 *   creeInterface(), puis synchroniserSlidersControlP5DepuisVariables() pour aligner
 *   ControlP5 sur les valeurs lues. Sauvegarde : exit() / dispose(), et sauvegarde
 *   espacée (throttle) depuis controlEvent (interface.pde).
 *
 * - Slider « ton » (tonImagePreview, −1 … +2.5) : contraste + luminosité sur l’aperçu
 *   (sur luminance : image N&amp;B si drapeau actif, sinon canaux RVB). Drapeau
 *   {@code tramagePhotoEnNoirEtBlanc} (défaut vrai) : tramage sur photo convertie en
 *   niveaux de gris (même {@code brightness} que getLignes) ; désactivé = couleur d’origine
 *   (préparation future séparation chromatique / crayons). Calque ton : callback ControlP5
 *   sur le slider ; imageAvecTonNiveaux dans utilitaires.pde. Migration contrasteImage si
 *   tonImagePreview absent.
 *
 * - Emplacement des réglages : reglages.json vit dans data/, comme les autres
 *   ressources Processing (police, etc.), sans second dossier parallèle.
 *
 * - Recadrage à l’écran avant / après enregistrement export :
 *   même logique de placement pour (1) la prévisualisation tramage (PNG généré
 *   par creePng) et (2) l’aperçu du SVG une fois le fichier écrit et rechargé
 *   (afficheSvgApresExport + loadShape). calculerCadreApercuTrame() tient compte
 *   du panneau droit, des marges UI_MARGE_CADRE_APERCU et du bandeau bas
 *   UI_BANDEAU_ZONE_IMAGE ; creePng reçoit les dimensions du document source
 *   (largeur/hauteur image) pour que le rectangle affiché corresponde au viewBox
 *   du SVG exporté, pas seulement à la taille du buffer preview.
 *
 * - Nombres décimaux dans le SVG « Inkscape / calques » (écriture manuelle,
 *   creeSvgInkscapeLayers) : avec la locale système fr_FR, String.format ou
 *   l’équivalent produit des virgules (ex. 12,5). Le format SVG et loadShape
 *   attendent le point décimal anglo-saxon ; Inkscape peut aussi mal interpréter.
 *   D’où fmtSvgUs() (Locale.US, creation_images.pde) pour forcer des points dans
 *   les attributs x1, y1, stroke-width, etc.
 *
 * - Exports SVG dans exports/ : chaque enregistrement inclut un horodatage dans le nom
 *   (suffixeHorodatageExport(), creation_images.pde — format yyyyMMdd_HHmmss_XXXXX) pour
 *   ne pas écraser les versions précédentes. Fichiers séparés : prefixe_horodatage_i.svg ;
 *   fusion : prefixe_horodatage_bantam_calques.svg ; un seul calque : prefixe_horodatage.svg.
 *
 * - Export SVG multi-calques Inkscape : structure compatible (groupes layer), AxiDraw /
 *   Bantam ; creeSvgInkscapeLayers(). Même suffixe horodaté que les autres exports.
 *
 * - Tramage / nombre de calques (classe_traitement.pde, méthode make) : correction d’un
 *   plantage à 12 calques (ArrayIndexOutOfBoundsException) — l’ancienne boucle flottante
 *   {@code i += 1f/n} pouvait enchaîner une itération de trop ; boucle entière {@code cl}
 *   et {@code i = cl/n} documentée en tête de traitementDuneImage.
 *
 * - v6 — optimisation segments (tramage_lignes.pde, interface.pde) : après extraction
 *   des runs sombres le long de chaque rayon, fusion des paires de segments si l’écart
 *   entre fin et début ≤ {@code optimLignesPontPx} (px sur l’image source exportée ;
 *   mis à l’échelle en prévisualisation dans {@code make}) ; suppression des segments
 *   plus courts que {@code optimLignesMinLongueurPx}. Sliders ControlP5 homonymes ;
 *   persistance {@code reglages.json} (schéma ≥5, voir settings_json.pde ; v6 = N&amp;B).
 *   Compteurs {@code statsLignesAvantOptim} / {@code statsLignesApresOptim} et affichage
 *   du gain en % dans le bandeau bas (tous calques, dernier recalcul).
 *
 * - Documentation : ce bloc d’en-tête ; Javadoc dans settings_json.pde (schéma JSON),
 *   classe_traitement.pde ({@code traitementDuneImage}, {@code creeCadre}), en-tête de
 *   tramage_lignes.pde ({@code getLignes}, {@code optimiserSegmentsStrip}).
 *
 * Le cœur algorithmique (traitementDuneImage, getLignes, logique de tramage et
 * d’export SVG classique) reste le code de Jean-Noël Lafargue ; ajouts : interface ControlP5,
 * glisser-déposer + fichier, polices et français, persistance des réglages, recadrage
 * prépa/export, export SVG multi-calques Inkscape, noms horodatés, robustesse fermeture IDE,
 * fmtSvgUs (locale FR), et en v6 réduction du nombre de lignes SVG / plotter par rayon.
 */

import processing.svg.*;
import controlP5.*;
import java.util.Locale;

/** Version majeure du sketch (Outil_Trames_6 : optimisation segments SVG / traceur). */
final int SKETCH_VERSION = 6;

ControlP5 cp5;

/** Police bitmap (data/Silkscreen-Regular-8.vlw), taille fixe 8 px — ControlP5 uniquement. */
PFont fonteUI;

/** Helvetica 12 pt lissée : invitation centrée + bandeau d’infos en bas (zone image). */
PFont fonteInviteInfos;

/** Largeur du panneau droit (sliders) ; réserve de la place pour les libellés ControlP5. */
int UI_PANEL_W = 320;

/** Même interligne / hauteur de bandeau que l’interface (zone image). */
final float UI_TEXTE_INTERLIGNE = 14.4;
/** 3 lignes d’aide + 1 ligne stats segments. */
final float UI_BANDEAU_ZONE_IMAGE = 3 * UI_TEXTE_INTERLIGNE + 22;
final float UI_MARGE_CADRE_APERCU = 0.05;

PImage source;
PGraphics im;
float minPas =10; // distance entre les traits les plus sombres
float maxPas= 10; // distance entre les traits les plus clairs
int nombreDangles=2;
float sensibiliteMinimum=.05; // valeur (0-1 la plus sombre)
float sensibiliteMaximum=.85;
boolean separer=true; // un fichier svg par direction
boolean ilYaEuUneMiseAjour=false;
PVector[] cadre={};
int marge=10;
float angleDepart = PI * 0.25;
/** Affichage UI (sliders) ; le tramage utilise `angleDepart` en radians. */
float angleDepartDeg = degrees(angleDepart);
float epaisseurTrait = 1.2;
/** Ton de la preview : −1 … +2.5 (0 = neutre), sur luminance si image N&amp;B. Calque seulement pendant clic sur le slider (interface.pde). */
float tonImagePreview = 0;
/** Si vrai (défaut) : tramage et export sur image en niveaux de gris (luminance Processing). Si faux : image couleur d’origine. */
boolean tramagePhotoEnNoirEtBlanc = true;
/** Pont max. (px sur l’image source exportée) pour fusionner deux traits sur le même rayon ; 0 = désactivé. */
float optimLignesPontPx = 0;
/** Longueur minimale (px source) d’un segment conservé après fusion ; 0 = désactivé. */
float optimLignesMinLongueurPx = 0;
/** Remplis par {@code make} / {@code getLignes} pour l’affichage du gain (tous calques, dernier calcul). */
int statsLignesAvantOptim = 0;
int statsLignesApresOptim = 0;
String prefixeImage="";
traitementDuneImage enCours;
float[] valeurs={};
//Slider s1;

/** Taille + densité 1 obligatoires ici : avec pixelDensity(2) sur Retina, le SVG exporté par
 *  createGraphics(..., SVG) a souvent des dimensions / viewBox incohérentes avec les coordonnées
 *  des tracés (aperçu « un quart » du dessin dans Inkscape). */
void settings() {
  size(1000, 1070);
  pixelDensity(1);
}

void setup() {
  // fullScreen();  // si tu l'actives, déplace aussi size/fullScreen dans settings()
  fonteUI = loadFont("Silkscreen-Regular-8.vlw");
  if (fonteUI == null) {
    println("Place Silkscreen-Regular-8.vlw dans le dossier data/ du sketch.");
  } else {
    textFont(fonteUI);
  }
  fonteInviteInfos = createFont("Helvetica", 12, true);
  initialiserGlisserDeposer();
  chargerSettingsDepuisFichier();
  creeInterface();
  synchroniserSlidersControlP5DepuisVariables();
}


void draw() {
  if (enCours != null) {
    enCours.affiche();
  }
  if (apercuReglageTonPhotoActif()) {
    dessineCalqueTonPhotoSurApercu();
  }
  afficheInterface();
}

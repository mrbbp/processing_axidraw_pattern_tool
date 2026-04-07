# Outil Processing de conversion en trame de traits
A fork of a project by JN Lafargue (for his students at ÉSADHAR) for plotting bitmap images using Axidraw. #bantamtools #axidraw #processinf #linestrip

Sketch **Processing 4** pour générer une **trame vectorielle** (lignes) à partir d’une image, avec prévisualisation et **export SVG** adaptés à la gravure / au traceur (Inkscape, AxiDraw, Bantamtools, découpe laser etc.).

## Version courante

| Indicateur | Valeur |
|------------|--------|
| **Version sketch** (`SKETCH_VERSION`) | **6** |
| **Schéma réglages JSON** (`SETTINGS_VERSION` dans `data/reglages.json`) | **6** |

## Crédits — code d’origine

Le **cœur algorithmique** du projet repose sur le travail de **Jean-Noël Lafargue** : pipeline `traitementDuneImage`, fonction `getLignes`, logique de tramage par calques (seuils de luminosité, pas et angles) et export SVG « classique ». Les évolutions listées ci-dessous s’ajoutent à cette base sans la remplacer.

## Ce que fait l’outil

1. **Charger** une image PNG, JPG ou GIF pas simple DragNDrop (par sélecteur de fichiers ou **glisser-déposer** avec la bibliothèque [Drop](https://sojamo.de/libraries/drop/) — sojamo).
2. **Tramer** l’image : plusieurs **calques** correspondent à des niveaux de gris (seuils interpolés) et à des directions de hachure ; les segments sont calculés le long de rayons de balayage (`getLignes` dans `tramage_lignes.pde`).
3. **Régler** les paramètres via **ControlP5** : nombre de calques, seuils mini/maxi, écart entre traits, angle de départ, ton de l’aperçu, option **photo en noir et blanc** pour le tramage (défaut activé), optimisation du nombre de segments (fusion / longueur minimale).
4. **Exporter** des SVG horodatés dans le dossier `exports/` : un fichier par calque, un seul fichier multi-calques compatible **Inkscape** (`inkscape:layer`), ou un SVG monocouche selon le mode.

Les réglages des sliders sont **enregistrés** dans `data/reglages.json` (voir l’en-tête de `settings_json.pde` pour le détail des clés).

## Fonctionnalités ajoutées (par rapport au noyau d’origine - promptées par @mrbbp et codées par @cursorai/composer2.0)

- Interface **ControlP5** (sliders, boutons, événements).
- **Ton** sur l’aperçu (contraste + luminosité) ; calque photo temporaire pendant la manipulation du curseur.
- **Tramage sur photo N&B** (défaut) : conversion en niveaux de gris alignée sur `brightness()` Processing, comme l’échantillonnage du tramage ; possibilité de désactiver pour travailler sur l’image couleur (préparation d’évolutions type séparation chromatique).
- **Optimisation des segments** (v6) : réduction du nombre de lignes SVG / temps de plot, avec affichage du **gain en %** dans le bandeau bas.
- **Noms de fichiers horodatés** pour les exports (`yyyyMMdd_HHmmss_XXXXX`).
- **Décimales au point** dans les SVG manuels (`fmtSvgUs`, locale US) pour éviter les problèmes avec une locale française.
- Correction du dénombrement des calques (boucle entière sur les calques, plus de dépassement à 12 calques).

## Prérequis

- **[Processing 4](https://processing.org/)**
- Bibliothèques à installer via le gestionnaire de contributions :
  - **ControlP5** — [sojamo](https://www.sojamo.de/libraries/controlP5/)
  - **Drop** — [sojamo](https://sojamo.de/libraries/drop/)
- Ressource dans `data/` :
  - police **Silkscreen-Regular-8.vlw** (interface ControlP5) ; proposée en license adéquat par Google Fonts. Est utilisée pour les textes avec accents dans l'interface ControlP5 (me fatiguent ces anglosaxons :/).
  - deux images fournies par l'auteur du code original

## Structure des onglets (.pde)

| Fichier | Rôle principal |
|---------|----------------|
| `Outil_Trames_6.pde` | Point d’entrée, constantes globales, `setup` / `draw` |
| `classe_traitement.pde` | Classe `traitementDuneImage`, cadre, `make` / prévisualisation / export |
| `tramage_lignes.pde` | `getLignes`, optimisation des segments par rayon |
| `creation_images.pde` | PNG d’aperçu, SVG (Processing + Inkscape layers), horodatage |
| `interface.pde` | ControlP5, raccourcis clavier, bandeau |
| `settings_json.pde` | Lecture / écriture `reglages.json` |
| `utilitaires.pde` | Drop, chargement fichier, ton / N&B |

## Raccourcis (indicatifs)

- **O** — ouvrir une image  
- **S** — export SVG « fichiers séparés » (équivalent au bouton du panneau)

Les boutons du panneau couvrent aussi l’export **multi-calques** en un seul fichier SVG (compatible avec les "calques" d'Inkscape)

## Licence et réutilisation

Respecter les conditions d’usage du code de **Jean-Noël Lafargue** pour la partie algorithmique d’origine. Pour les ajouts et modifications postérieures, se référer aux commentaires dans les fichiers sources et aux auteurs mentionnés dans l’en-tête de `Outil_Trames_6.pde`.


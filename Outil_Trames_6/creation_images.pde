/**
 * Export tramage → fichiers SVG dans {@code exports/} ; aperçu PNG écran ; noms de fichier
 * incluent {@code suffixeHorodatageExport()} pour conserver chaque version exportée.
 */

/** Nombres pour SVG : toujours point décimal (sinon Inkscape / loadShape cassent avec locale FR). */
String fmtSvgUs(float v, int decimals) {
  return String.format(Locale.US, "%." + decimals + "f", v);
}


/**
 * Suffixe pour noms de fichiers dans {@code exports/} : date/heure locale + disambiguation ms
 * (évite d’écraser un export fait la même seconde). Format {@code yyyyMMdd_HHmmss_XXXXX}.
 */
String suffixeHorodatageExport() {
  int tail = (int) (System.currentTimeMillis() % 100000);
  return nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_"
    + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + "_" + nf(tail, 5);
}


/** Cadre commun : prévisualisation tramage et aperçu SVG (marges + bandeau d’aide en bas). */
void calculerCadreApercuTrame(float docW, float docH, float[] oxoywh) {
  float zw = width - UI_PANEL_W;
  float pad = min(displayWidth, displayHeight) * UI_MARGE_CADRE_APERCU;
  float maxW = zw - 2 * pad;
  float maxH = height - UI_BANDEAU_ZONE_IMAGE - 2 * pad;
  if (maxW < 20) {
    maxW = zw * 0.96f;
    pad = (zw - maxW) * 0.5f;
  }
  if (maxH < 20) {
    maxH = (height - UI_BANDEAU_ZONE_IMAGE) * 0.96f;
  }
  float sc = min(maxW / docW, maxH / docH);
  float dw = docW * sc;
  float dh = docH * sc;
  oxoywh[0] = pad + (maxW - dw) * 0.5f;
  oxoywh[1] = pad + (maxH - dh) * 0.5f;
  oxoywh[2] = dw;
  oxoywh[3] = dh;
}


/** Aperçu SVG : même cadre que la prévisualisation pendant la préparation. */
void afficheSvgApresExport(PShape s, int docW, int docH) {
  if (s == null) {
    println("loadShape a échoué (fichier SVG invalide ?)");
    return;
  }
  float[] r = new float[4];
  calculerCadreApercuTrame(docW, docH, r);
  shape(s, r[0], r[1], r[2], r[3]);
}


void creeSvg(float[][] allLignes, int w, int h) {
  String nomFichier = prefixeImage + "_" + suffixeHorodatageExport() + ".svg";
  im=createGraphics(w, h, SVG, "exports/"+nomFichier);

  im.beginDraw();
  //im.background(255);
  im.strokeWeight(epaisseurTrait);
  for (float[] l : allLignes) {
    im.line(l[0], l[1], l[2], l[3]);
  }
  im.endDraw();
  im.dispose();
  background(255);
  PShape s = loadShape("exports/" + nomFichier);
  afficheSvgApresExport(s, w, h);
}

void creeSvg(float[][][] allCalques, int w, int h) {
  int coul=0;
  String stamp = suffixeHorodatageExport();
  background(255);
  for (float[][] allLignes : allCalques) {
    String nomFichier = prefixeImage + "_" + stamp + "_" + coul + ".svg";
    im=createGraphics(w, h, SVG, "exports/"+nomFichier );
    coul++;

    im.beginDraw();
    //im.background(255);
    im.strokeWeight(epaisseurTrait);
    for (float[] l : allLignes) {
      im.line(l[0], l[1], l[2], l[3]);
    }
    im.endDraw();
    im.dispose();
    PShape s = loadShape("exports/" + nomFichier);
    afficheSvgApresExport(s, w, h);
  }
}

/** SVG unique : un groupe par calque (convention Inkscape / sélection calque AxiDraw). */
void creeSvgInkscapeLayers(float[][][] allCalques, int w, int h) {
  String nomFichier = prefixeImage + "_" + suffixeHorodatageExport() + "_bantam_calques.svg";
  String chemin = "exports/" + nomFichier;
  PrintWriter out = createWriter(chemin);
  out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
  out.println("<svg xmlns=\"http://www.w3.org/2000/svg\"");
  out.println("     xmlns:inkscape=\"http://www.inkscape.org/namespaces/inkscape\"");
  out.println("     width=\"" + w + "\" height=\"" + h + "\" viewBox=\"0 0 " + w + " " + h + "\">");
  String sw = fmtSvgUs(epaisseurTrait, 2);
  for (int i = 0; i < allCalques.length; i++) {
    String label = i + " calque";
    out.println("  <g inkscape:groupmode=\"layer\" inkscape:label=\"" + label + "\">");
    for (float[] l : allCalques[i]) {
      out.println("    <line x1=\"" + fmtSvgUs(l[0], 3) + "\" y1=\"" + fmtSvgUs(l[1], 3)
        + "\" x2=\"" + fmtSvgUs(l[2], 3) + "\" y2=\"" + fmtSvgUs(l[3], 3)
        + "\" stroke=\"#000000\" stroke-width=\"" + sw + "\" fill=\"none\"/>");
    }
    out.println("  </g>");
  }
  out.println("</svg>");
  out.flush();
  out.close();
  background(255);
  PShape s = loadShape(chemin);
  afficheSvgApresExport(s, w, h);
  println("Écrit : " + chemin);
}


/** texW/H = taille du buffer trame ; cadreDocW/H = dimensions source pour le même rectangle à l’écran que le SVG. */
void creePng(float[][] allLignes, int texW, int texH, int cadreDocW, int cadreDocH, float weight) {
  im = createGraphics(texW, texH);

  im.beginDraw();
  im.background(255);
  im.strokeWeight(weight);
  for (float[] l : allLignes) {
    im.line(l[0], l[1], l[2], l[3]);
  }
  im.endDraw();
  float[] r = new float[4];
  calculerCadreApercuTrame(cadreDocW, cadreDocH, r);
  image(im, r[0], r[1], r[2], r[3]);
}

void creePng(float[][][] allCalques, int texW, int texH, int cadreDocW, int cadreDocH, float weight) {
  im = createGraphics(texW, texH);
  im.beginDraw();
  im.background(255);
  for (float[][] allLignes : allCalques) {
    im.strokeWeight(weight);
    for (float[] l : allLignes) {
      im.line(l[0], l[1], l[2], l[3]);
    }
  }
  im.endDraw();
  float[] r = new float[4];
  calculerCadreApercuTrame(cadreDocW, cadreDocH, r);
  image(im, r[0], r[1], r[2], r[3]);
}

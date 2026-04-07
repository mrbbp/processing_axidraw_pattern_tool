/**
 * Extraction des segments le long des rayons de balayage ; optimisation par rayon
 * (fusion des trous ≤ {@code pontGapPx}, suppression des traits &lt; {@code minLongueurPx}).
 * Les compteurs globaux {@code statsLignesAvantOptim} / {@code statsLignesApresOptim}
 * sont incrémentés par rayon (cumul sur tout l’appel à {@code getLignes}).
 */

/** Fusionne des segments consécutifs sur un même rayon si l’écart entre fin et début ≤ pontMax. */
float[][] optimiserSegmentsStrip(float[][] segs, float pontMax, float minLongueur) {
  if (segs == null || segs.length == 0) {
    return segs;
  }
  if (pontMax <= 0 && minLongueur <= 0) {
    return segs;
  }
  float[][] out = new float[0][4];
  int i = 0;
  while (i < segs.length) {
    float x1 = segs[i][0];
    float y1 = segs[i][1];
    float x2 = segs[i][2];
    float y2 = segs[i][3];
    i++;
    while (pontMax > 0 && i < segs.length) {
      float ax = segs[i][0];
      float ay = segs[i][1];
      float bx = segs[i][2];
      float by = segs[i][3];
      if (dist(x2, y2, ax, ay) <= pontMax) {
        x2 = bx;
        y2 = by;
        i++;
        continue;
      }
      if (dist(x2, y2, bx, by) <= pontMax) {
        x2 = ax;
        y2 = ay;
        i++;
        continue;
      }
      break;
    }
    if (minLongueur <= 0 || dist(x1, y1, x2, y2) >= minLongueur) {
      out = (float[][]) append(out, new float[] { x1, y1, x2, y2 });
    }
  }
  return out;
}


float[][] getLignes(PImage i, PVector[] cadre, float angle, float sensibilite, float pas, float pontGapPx, float minLongueurPx) {
  float[][] lignes=new float[0][4];
  float r=dist(0, 0, i.width/2, i.height/2)*2.1;
  float h=r;
  float x1=i.width/2+cos(angle)*h, y1=i.height/2+sin(angle)*h;
  float x2=i.width/2+cos(HALF_PI+angle)*h, y2=i.height/2+sin(HALF_PI+angle)*h;
  float x3=i.width/2+cos(PI+angle)*h, y3=i.height/2+sin(PI+angle)*h;
  float x4=i.width/2+cos(PI*1.5+angle)*h, y4=i.height/2+sin(PI*1.5+angle)*h;

  float d=dist(x1, y1, x2, y2);
  float ecart=1.0/(int(d/pas));
  boolean aller=true;
  for (float a=0; a<1+ecart; a+=ecart) {
    float xhaut=lerp(x1, x2, a);
    float yhaut=lerp(y1, y2, a);
    float xbas=lerp(x4, x3, a);
    float ybas=lerp(y4, y3, a);
    if (aller) {
      float xh=xbas, yh=ybas;
      xbas=xhaut;
      ybas=yhaut;
      xhaut=xh;
      yhaut=yh;
    }
    aller=!aller;
    float ecart2=1.0/(dist(xhaut, yhaut, xbas, ybas));
    float debx=-1, deby=-1;
    int etape=0;
    float[][] stripLignes = new float[0][4];
    for (float u=0; u<1+ecart2; u+=ecart2) {
      float movx=lerp(xhaut, xbas, u);
      float movy=lerp(yhaut, ybas, u);
      boolean isin=(movx>cadre[0].x&&movy>cadre[0].y&&movx<cadre[2].x&&movy<cadre[2].y);
      if (!isin&&etape==0) {
        continue;
      }
      if (isin&&etape==0) {
        etape=1;
      }
      if (!isin && etape==1) {
        if (debx!=-1&&deby!=-1) {
          float nx=lerp(xhaut, xbas, u-ecart2);
          float ny=lerp(yhaut, ybas, u-ecart2);
          float[] nl={debx, deby, nx, ny};
          stripLignes=(float[][])append(stripLignes, nl);
        }
        debx=-1;
        deby=-1;
        break;
      }
      float br=norm(brightness(i.get(int(movx), int(movy))), 0, 255);
      if (br<=sensibilite) {
        if (debx==-1&&deby==-1) {
          debx=movx;
          deby=movy;
        }
      } else {
        if (debx!=-1&&deby!=-1) {
          float nx=lerp(xhaut, xbas, u-ecart2);
          float ny=lerp(yhaut, ybas, u-ecart2);

          float[] nl={debx, deby, nx, ny};
          stripLignes=(float[][])append(stripLignes, nl);
          debx=-1;
          deby=-1;
        }
      }
    }
    int nAvant = stripLignes.length;
    stripLignes = optimiserSegmentsStrip(stripLignes, pontGapPx, minLongueurPx);
    int nApres = stripLignes.length;
    statsLignesAvantOptim += nAvant;
    statsLignesApresOptim += nApres;
    lignes = (float[][]) concat(lignes, stripLignes);
  }
  return lignes;
}

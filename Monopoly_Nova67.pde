// =============================================================================
// JUEGO DE MESA MULTINIVEL & ENERGÍA DINÁMICA · BARRANQUILLA
// Estructuras de Datos II - Universidad del Norte
// VERSIÓN PULIDA · adaptada a Barranquilla
//
// Para cambiar el nombre del juego o de la ciudad: variables NOMBRE_JUEGO y NOMBRE_CIUDAD.
//
// IMÁGENES OPCIONALES (carpeta data/):
//   menu_inicio.jpg, seleccion_jugadores.jpg, fondo_dado.jpg, tablero_limpio.jpg
//   ficha_*.png, card_*.png
//   data/casos/<archivo>  -> fotos de los casos reales (ver casoImg[] más abajo).
//   Si una foto no existe, se muestra un recuadro placeholder automáticamente.
// =============================================================================

// ---- Nombres provisionales (se cambian aquí, en un solo lugar) ----
String NOMBRE_JUEGO  = "BARRANQUILLA DIGITAL";
String NOMBRE_CIUDAD = "Barranquilla";

PFont fontTitulo, fontTexto, fontSmall, fontGrande;

PImage imgMenuInicio, imgSeleccionJugadores, imgFondoDado, imgTablero;
PImage imgFichaAlcalde, imgFichaPeriodista, imgFichaInfluencer, imgFichaCiudadana;
PImage imgCardAlcalde, imgCardPeriodista, imgCardInfluencer, imgCardCiudadana;

// =============================================================================
// CASOS (AQUÍ PUEDES CAMBIAR TEXTOS Y FOTOS POR CASOS REALES DE BARRANQUILLA)
// Guarda las fotos en data/casos/ con el nombre indicado en casoImg[].
// =============================================================================
String[] casoTema = {
  "Falso Paro en la Vía 40",
  "Supuesto Monstruo en el Río Magdalena",
  "Cierre Repentino de la Circunvalar",
  "Falso Bono para Universitarios",
  "Falsa Alerta: Arroyo Desbordado",
  "Falsa Alerta en el Transmetro",
  "Audio Filtrado del Alcalde (IA)",
  "¡Colapsa un Puente sobre el Río Magdalena!",
  "Falsa Cancelación del Carnaval"
};
String[] casoDesc = {
  "Un audio anuncia un paro de transportadores sobre la Vía 40. Nadie lo ha confirmado.",
  "Un video borroso asegura que algo enorme nada cerca del Gran Malecón del Río.",
  "Dicen que la Circunvalar cerrará mañana por obras y la gente ya cambia sus rutas.",
  "Un enlace promete un bono a universitarios si comparten sus datos personales.",
  "Un audio anónimo dice que un arroyo arrasa barrios del suroccidente en plena temporada de lluvias. Nadie lo confirma.",
  "Capturas de pantalla muestran una supuesta emergencia en estaciones de Transmetro.",
  "Un audio atribuido al alcalde circula en chats. Podría estar hecho con IA.",
  "Una imagen muestra un puente desplomándose sobre el Magdalena. Miles la comparten por WhatsApp con pánico; nadie la confirma.",
  "Una cadena de WhatsApp asegura que se cancela la Batalla de Flores. Nadie de la organización lo ha dicho."
};

// Consejo real de verificación que se muestra al cerrar cada caso
String[] casoVerifica = {
  "Antes de compartir avisos de paros, consulta los canales oficiales de la Alcaldía y de Movilidad.",
  "Busca el video original: si solo circula en cadenas sin fecha ni lugar, desconfía.",
  "Confirma los cierres viales en las cuentas oficiales de Movilidad y Tránsito.",
  "Los apoyos reales se anuncian en canales oficiales. Nunca des tus datos a cambio de un bono.",
  "Ante alertas de arroyos, sigue a Gestión del Riesgo y Bomberos; no reenvíes audios anónimos.",
  "Verifica el estado del servicio en los canales oficiales de Transmetro.",
  "Contrasta con las redes oficiales de la Alcaldía: las voces clonadas con IA suenan planas y sin contexto.",
  "Haz búsqueda inversa de la imagen y confirma con la Alcaldía, Bomberos o medios locales reconocidos.",
  "Las fechas y cambios del Carnaval los comunican la organización del Carnaval y la Alcaldía, no las cadenas."
};
String[] casoImg = {
  "caso_paro_via40.jpg",
  "caso_monstruo_rio.jpg",
  "caso_circunvalar.jpg",
  "caso_bono.jpg",
  "caso_arroyo.jpg",
  "caso_transmetro.jpg",
  "caso_audio_alcalde.jpg",
  "puente_nova",           // sin extensión: acepta .jpg, .png o .jpeg en data/ o data/casos/
  "caso_carnaval.jpg"
};
PImage[] casoMini;    // miniatura para la carta (cuadrada)
PImage[] casoBanner;  // imagen para el panel del árbol
PImage[] casoOriginal; // imagen completa (para la lupa de inspección)
final int CASO_PUENTE = 7;   // caso especial "Puente Nova": misión del PERIODISTA

// Pistas que se desbloquean al inspeccionar la imagen con la lupa
String[] pistasIA = {
  "Metal que se dobla como goma: las vigas de la cercha se curvan sin romperse y sin uniones claras.",
  "Mira la estructura: las celosías de ambos tramos no encajan y el pilar izquierdo parece pegado a la viga.",
  "Detalles diminutos sin sentido: el camión y los autos sobre el tablero están borrosos y no caen con él.",
  "Escena demasiado cinematográfica y sin fuente oficial. Haz búsqueda inversa de imagen y confirma con la Alcaldía o Bomberos."
};

// =============================================================================
// ESTADOS DEL JUEGO Y VARIABLES DE CONTROL
// =============================================================================
final int ESTADO_PORTADA      = -1;
final int ESTADO_CONFIG       = 0;
final int ESTADO_FEED         = 1;
final int ESTADO_ARBOL        = 2;
final int ESTADO_CONSECUENCIA = 3;
final int ESTADO_FIN          = 4;
final int ESTADO_MENU         = 5;
final int ESTADO_BLOQUEADO    = 6;
final int ESTADO_DADO         = 7;
final int ESTADO_INSPECCION   = 8;

final int COSTO_ENERGIA = 25;   // energía que cuesta cada paso en el árbol
final int MAX_RONDAS_CONST = 5;

int estadoActual = ESTADO_PORTADA;
int estadoAnterior = ESTADO_FEED;
int rondaActual = 1;
final int maxRondas = MAX_RONDAS_CONST;
boolean isMaximized = false;
// Misión del Puente Nova
boolean puenteResuelto = false;     // si ya se tomó la decisión, deja de repartirse
float inspProgreso = 0;             // 0..100: cuánto se ha explorado la imagen
float inspZoom = 3;
int estadoAntesInspeccion = ESTADO_FEED;
int puenteNodoBueno = -1, puenteNodoMalo = -1;
float inspBtnX = 0, inspBtnY = 0, inspBtnW = 200, inspBtnH = 44;

int nodoBloqueadoIntento = -1;
int motivoBloqueo = 0;          // 0 = rol no permitido, 1 = sin energía

// Reglas por turno
boolean jugoCartaEsteTurno = false;
int cartaDelTurno = -1;         // carta en la que el jugador ya está avanzando
boolean[][] cartaBloqueadaParaJugador;

// Dado y reparto de energía
int framesAnimacionDado = 0;
int valorDado = 1;
boolean animandoRepartoEnergia = false;
float progresoReparto = 0;
int[] energiaARepartir = new int[4];
boolean repartoEstaRonda = false;   // true solo cuando la tirada actual cierra la ronda

// Métricas de la ciudad (0 a 100)
int infoVerificada = 45;
int convivenciaDigital = 55;
int confianzaCiudadana = 50;
int desinformacion = 50;
String mensajeUltimaAccion = "";

final int UMBRAL_DESMENTIDO = 40;

// Resultado de la última acción (para mostrarlo en el modal)
final int MAX_RES = 8;
String[] resNombre = new String[MAX_RES];
int[] resDelta = new int[MAX_RES];
boolean[] resInverso = new boolean[MAX_RES];
int resCount = 0;
String resImpactoTxt = "";
boolean resFinal = false;

// Aviso temporal
String toastTxt = "";
int toastFrames = 0;

// Decoración flotante
float[] nubesX = {100, 400, 800, 1050, 250, 700};
float[] nubesY = {50, 80, 40, 90, 150, 120};

// =============================================================================
// JUGADORES (ARREGLOS PARALELOS)
// =============================================================================
final String[] ROLES = {"ALCALDE", "PERIODISTA", "INFLUENCER", "CIUDADANO"};
int cantJugadores = 4;
int turnoActual = 0;

String[] jugNombre       = {"Mateo (Alcalde)", "Elena (Periodista)", "Lucas (Influencer)", "Sofía (Ciudadana)"};
String[] jugRol          = {"ALCALDE", "PERIODISTA", "INFLUENCER", "CIUDADANO"};
int[] jugColor;
int[] jugEnergia         = {100, 100, 100, 100};
int[] jugMaxEnergia      = {100, 100, 100, 100};
int[] jugPopularidad     = new int[4];
int[] jugCredibilidad    = new int[4];
int[] jugAlcance         = new int[4];
int[] jugBienestar       = new int[4];

final int[] POPULARIDAD_INI  = {50, 20, 45, 30};
final int[] CREDIBILIDAD_INI = {40, 75, 30, 65};
final int[] ALCANCE_INI      = {45, 60, 90, 35};
final int[] BIENESTAR_INI    = {50, 50, 40, 80};

// =============================================================================
// PUBLICACIONES (CARTAS DE EVENTO)
// =============================================================================
final int MAX_PUBS = 100;
int totalPubs = 0;
int contadorPubId = 100;
int[] pubId              = new int[MAX_PUBS];
int[] pubCaso            = new int[MAX_PUBS];
String[] pubAutor        = new String[MAX_PUBS];
String[] pubTitular      = new String[MAX_PUBS];
String[] pubContenido    = new String[MAX_PUBS];
int[] pubImpactoViral    = new int[MAX_PUBS];
boolean[] pubVerificada  = new boolean[MAX_PUBS];
boolean[] pubDesmentida  = new boolean[MAX_PUBS];
boolean[] pubEsFakeNews  = new boolean[MAX_PUBS];
int[] pubArbolRaiz       = new int[MAX_PUBS];
int[] pubNodoActual      = new int[MAX_PUBS];
int pubSeleccionada = -1;

// =============================================================================
// ÁRBOL BINARIO DE BÚSQUEDA (BST)
// =============================================================================
final int MAX_NODOS_BST = 100;
int bstRaiz = -1;
int bstTamano = 0;

int[] bstClave     = new int[MAX_NODOS_BST];
int[] bstPubIdx    = new int[MAX_NODOS_BST];
int[] bstIzq       = new int[MAX_NODOS_BST];
int[] bstDer       = new int[MAX_NODOS_BST];
boolean[] bstLibre = new boolean[MAX_NODOS_BST];

// =============================================================================
// ÁRBOL DE DECISIONES N-ARIO MULTINIVEL (TABLERO)
// =============================================================================
final int MAX_NODOS_DECISION = 1000;
int totalNodosDecision = 0;

String[] ndTexto             = new String[MAX_NODOS_DECISION];
String[] ndCorto             = new String[MAX_NODOS_DECISION];   // nombre corto para la casilla
String[] ndDesc              = new String[MAX_NODOS_DECISION];
String[] ndRolReq            = new String[MAX_NODOS_DECISION];
int[] ndDeltaVerdad          = new int[MAX_NODOS_DECISION];
int[] ndDeltaConvivencia     = new int[MAX_NODOS_DECISION];
int[] ndDeltaConfianza       = new int[MAX_NODOS_DECISION];
int[] ndDeltaBienestar       = new int[MAX_NODOS_DECISION];
int[] ndDeltaDesinf          = new int[MAX_NODOS_DECISION];
String[] ndExplicacion       = new String[MAX_NODOS_DECISION];
int[] ndCantHijos            = new int[MAX_NODOS_DECISION];
int[][] ndHijos              = new int[MAX_NODOS_DECISION][6];
float[] ndX                  = new float[MAX_NODOS_DECISION];
float[] ndY                  = new float[MAX_NODOS_DECISION];
int[] ndNivel                = new int[MAX_NODOS_DECISION];
boolean[] ndElegido          = new boolean[MAX_NODOS_DECISION];
int[] ndColorCasilla         = new int[MAX_NODOS_DECISION];
int nodoActualDecision = -1;

// Altura de cada nivel del árbol (se recalcula en cada frame)
float layY0 = 200, layY1 = 350, layY2 = 505;

// Textos de acciones de nivel 1 por rol (índice = rol en ROLES)
String[][] accionTexto = {
  {"Rueda de prensa", "Comunicado de la Alcaldía", "Mesa con las JAC"},
  {"Verificar con fuentes oficiales", "Nota de contexto", "Entrevistar testigos"},
  {"Hilo aclaratorio", "Video en vivo desde el sitio", "Reto #VerificaBAQ"},
  {"Denunciar en redes", "Avisar al barrio por WhatsApp", "Compartir solo lo confirmado"}
};
String[][] accionDesc = {
  {"El alcalde habla directo con los medios de Barranquilla.", "La Alcaldía publica una versión oficial en sus canales.", "Se reúne con las Juntas de Acción Comunal (JAC) de los barrios."},
  {"Contrasta el rumor con las fuentes oficiales de la ciudad.", "Publica una nota que explica el contexto del rumor.", "Busca a quienes estuvieron en el lugar de los hechos."},
  {"Publica un hilo que desmonta el rumor ante su comunidad.", "Transmite en vivo desde el lugar para mostrar la realidad.", "Lanza un reto en redes para premiar la verdad."},
  {"Reporta la publicación falsa a la plataforma.", "Avisa a su cuadra por el grupo de WhatsApp del barrio.", "Comparte solo información confirmada por fuentes oficiales."}
};
String[] metaTxt  = {"Verdad Viral", "Calma en los Barrios", "Alerta Cívica", "Pacto por la Verdad"};
String[] metaDesc = {"La aclaración se vuelve tendencia en Barranquilla.", "Los barrios recuperan la calma.", "La gente aprende a verificar antes de compartir.", "Medios, Alcaldía y vecinos firman un pacto por la verdad."};

String[] NIVEL_TITULO = {"NIVEL 0 · ORIGEN", "NIVEL 1 · INTERVENCIÓN", "NIVEL 2 · DESENLACE"};
String[] NIVEL_SUB    = {"El rumor se riega por Barranquilla", "Cada rol elige su acción", "Barranquilla reacciona"};

// Medidas de la lista de cartas del feed
final float CARD_W = 520;
final float CARD_H = 72;
final float CARD_GAP = 8;
final float CARD_Y0 = 134;

final float MODAL_CONS_H = 390;
final float MODAL_BLOQ_H = 270;
final float MODAL_FIN_H = 480;

// =============================================================================
// SETUP Y DRAW PRINCIPAL
// =============================================================================
void setup() {
  size(1120, 720);
  surface.setResizable(true);
  surface.setTitle(NOMBRE_JUEGO + " - Juego de Mesa Multinivel (BST & N-Ario)");

  fontTitulo = createFont("SansSerif.bold", 16, true);
  fontTexto  = createFont("SansSerif", 13, true);
  fontSmall  = createFont("SansSerif", 11, true);
  fontGrande = createFont("SansSerif.bold", 40, true);

  String basePath = "";

  imgMenuInicio = loadImage(basePath + "menu_inicio.jpg");
  imgSeleccionJugadores = loadImage(basePath + "seleccion_jugadores.jpg");
  imgFondoDado = loadImage(basePath + "fondo_dado.jpg");
  imgTablero = loadImage(basePath + "tablero_limpio.jpg");

  imgFichaAlcalde = loadImage(basePath + "ficha_alcalde.png");
  imgFichaPeriodista = loadImage(basePath + "ficha_periodista.png");
  imgFichaInfluencer = loadImage(basePath + "ficha_influencer.png");
  imgFichaCiudadana = loadImage(basePath + "ficha_ciudadana.png");

  imgCardAlcalde = loadImage(basePath + "card_alcalde.png");
  imgCardPeriodista = loadImage(basePath + "card_periodista.png");
  imgCardInfluencer = loadImage(basePath + "card_influencer.png");
  imgCardCiudadana = loadImage(basePath + "card_ciudadana.png");

  // Fotos de los casos (solo se cargan si el archivo existe)
  casoMini = new PImage[casoTema.length];
  casoBanner = new PImage[casoTema.length];
  casoOriginal = new PImage[casoTema.length];
  for (int i = 0; i < casoTema.length; i++) {
    String ruta = resolverRutaCaso(casoImg[i]);
    if (ruta != null) {
      PImage original = loadImage(ruta);
      if (original != null && original.width > 0) {
        if (original.width > 1600) original.resize(1600, 0);   // limita memoria
        casoOriginal[i] = original;
        casoMini[i] = recortarCover(original, 120, 120);
        casoBanner[i] = recortarCover(original, 200, 128);
      }
    }
  }

  jugColor = new int[4];
  jugColor[0] = color(41, 128, 185);
  jugColor[1] = color(39, 174, 96);
  jugColor[2] = color(155, 89, 182);
  jugColor[3] = color(243, 156, 18);

  cartaBloqueadaParaJugador = new boolean[4][MAX_PUBS];

  inicializarBST();
  estadoActual = ESTADO_PORTADA;
}

void draw() {
  animarNubes();

  if (estadoActual == ESTADO_PORTADA) {
    dibujarPantallaPortada();
  } else if (estadoActual == ESTADO_CONFIG) {
    dibujarPantallaConfiguracion();
    dibujarBotonConfiguracion();
  } else if (estadoActual == ESTADO_FEED) {
    dibujarEntornoTablero();
    dibujarHeaderCentral();
    dibujarEsquinasJugadores();
    dibujarMazoCentral();
    dibujarToast();
    dibujarBotonConfiguracion();
  } else if (estadoActual == ESTADO_DADO) {
    dibujarPantallaDado();
    dibujarBotonConfiguracion();
  } else if (estadoActual == ESTADO_ARBOL) {
    dibujarEntornoTablero();
    dibujarHeaderCentral();
    dibujarEsquinasJugadores();
    dibujarVistaArbolDecision();
    dibujarBotonConfiguracion();
  } else if (estadoActual == ESTADO_CONSECUENCIA) {
    dibujarEntornoTablero();
    dibujarHeaderCentral();
    dibujarEsquinasJugadores();
    if (pubSeleccionada >= 0 && pubSeleccionada < totalPubs && !pubDesmentida[pubSeleccionada]) {
      actualizarLayoutArbol();
      dibujarArbolBase();
    } else {
      dibujarMazoCentral();
    }
    dibujarModalConsecuencia();
  } else if (estadoActual == ESTADO_MENU) {
    dibujarEntornoTablero();
    dibujarHeaderCentral();
    dibujarEsquinasJugadores();
    dibujarMenuOpciones();
  } else if (estadoActual == ESTADO_BLOQUEADO) {
    dibujarEntornoTablero();
    dibujarHeaderCentral();
    dibujarEsquinasJugadores();
    if (pubSeleccionada >= 0 && pubSeleccionada < totalPubs) {
      actualizarLayoutArbol();
      dibujarArbolBase();
    }
    dibujarModalCaminoBloqueado();
  } else if (estadoActual == ESTADO_INSPECCION) {
    dibujarEntornoTablero();
    dibujarInspeccion();
  } else if (estadoActual == ESTADO_FIN) {
    dibujarPantallaFin();
  }
}

// =============================================================================
// UTILIDADES DE DIBUJO
// =============================================================================
void dibujarSombra(float x, float y, float w, float h, int radio, int opacidad) {
  noStroke(); fill(0, opacidad); rect(x + 5, y + 5, w, h, radio);
}

void animarNubes() {
  for (int i = 0; i < nubesX.length; i++) {
    nubesX[i] -= 0.2;
    if (nubesX[i] < -100) nubesX[i] = width + 50;
  }
}

void dibujarCieloYNubes() {
  background(135, 206, 235);
  noStroke(); fill(255, 200);
  for (int i = 0; i < nubesX.length; i++) {
    ellipse(nubesX[i], nubesY[i], 80, 40);
    ellipse(nubesX[i] + 20, nubesY[i] - 15, 60, 40);
    ellipse(nubesX[i] - 20, nubesY[i] - 10, 50, 30);
  }
}

void dibujarImagenFondo(PImage img) {
  if (img == null) return;
  float imgRatio = (float)img.width / img.height;
  float screenRatio = (float)width / height;
  float drawW, drawH;
  if (screenRatio > imgRatio) {
    drawW = width;
    drawH = width / imgRatio;
  } else {
    drawH = height;
    drawW = height * imgRatio;
  }
  image(img, (width - drawW)/2, (height - drawH)/2, drawW, drawH);
}

void dibujarEntornoTablero() {
  if (imgTablero != null) {
    dibujarImagenFondo(imgTablero);
  } else {
    dibujarCieloYNubes();
    noStroke(); fill(120, 200, 100); rect(0, 100, width, height - 100);
    stroke(100, 180, 80); strokeWeight(2);
    for (int i = 0; i < width; i += 60) line(i, 100, i, height);
    for (int i = 100; i < height; i += 60) line(0, i, width, i);
  }
}

// Recorta una imagen para llenar un recuadro w x h sin deformarla
PImage recortarCover(PImage img, int w, int h) {
  float ir = (float)img.width / img.height;
  float br = (float)w / h;
  int sw, sh, sx, sy;
  if (ir > br) {
    sh = img.height; sw = (int)(sh * br); sx = (img.width - sw) / 2; sy = 0;
  } else {
    sw = img.width; sh = (int)(sw / br); sx = 0; sy = (img.height - sh) / 2;
  }
  PImage c = img.get(sx, sy, sw, sh);
  c.resize(w, h);
  return c;
}

// Recorta un texto con "..." para que quepa en maxW (usa la fuente actual)
String recortar(String s, float maxW) {
  if (s == null) return "";
  if (textWidth(s) <= maxW) return s;
  while (s.length() > 1 && textWidth(s + "...") > maxW) s = s.substring(0, s.length() - 1);
  return s + "...";
}

void dibujarPlaceholderFoto(float x, float y, float w, float h) {
  pushStyle();
  noStroke(); fill(205, 218, 232); rect(x, y, w, h, 6);
  fill(170, 190, 210);
  triangle(x + w*0.08f, y + h*0.82f, x + w*0.38f, y + h*0.42f, x + w*0.68f, y + h*0.82f);
  triangle(x + w*0.48f, y + h*0.82f, x + w*0.70f, y + h*0.56f, x + w*0.92f, y + h*0.82f);
  fill(255, 225, 120); ellipse(x + w*0.76f, y + h*0.27f, w*0.18f, w*0.18f);
  popStyle();
}

// ---- Iconos dibujados con formas (no dependen de emojis) ----
void dibujarIconoLlama(float cx, float cy, float s) {
  pushStyle();
  noStroke(); fill(255, 130, 0);
  beginShape();
  vertex(cx, cy - s);
  bezierVertex(cx + s*0.9f, cy - s*0.2f, cx + s*0.6f, cy + s*0.8f, cx, cy + s*0.8f);
  bezierVertex(cx - s*0.6f, cy + s*0.8f, cx - s*0.9f, cy - s*0.2f, cx, cy - s);
  endShape(CLOSE);
  fill(255, 210, 60); ellipse(cx, cy + s*0.3f, s*0.7f, s*0.9f);
  popStyle();
}

void dibujarIconoCandado(float cx, float cy, float s, int col) {
  pushStyle();
  noFill(); stroke(col); strokeWeight(max(2, s*0.16f));
  arc(cx, cy - s*0.15f, s*0.7f, s*0.9f, PI, TWO_PI);
  noStroke(); fill(col); rect(cx - s*0.45f, cy - s*0.15f, s*0.9f, s*0.7f, 3);
  fill(255); ellipse(cx, cy + s*0.15f, s*0.16f, s*0.16f);
  popStyle();
}

void dibujarIconoEngranaje(float cx, float cy, float r) {
  pushStyle();
  stroke(255); strokeWeight(3);
  for (int i = 0; i < 8; i++) {
    float a = TWO_PI * i / 8.0f;
    line(cx + cos(a)*r*0.6f, cy + sin(a)*r*0.6f, cx + cos(a)*r, cy + sin(a)*r);
  }
  noFill(); ellipse(cx, cy, r*1.3f, r*1.3f); ellipse(cx, cy, r*0.5f, r*0.5f);
  popStyle();
}

int indiceRol(String rol) {
  for (int i = 0; i < ROLES.length; i++) if (ROLES[i].equalsIgnoreCase(rol)) return i;
  return 0;
}

PImage obtenerImagenFicha(int colorJugador) {
  if (colorJugador == color(41, 128, 185)) return imgFichaAlcalde;
  if (colorJugador == color(39, 174, 96)) return imgFichaPeriodista;
  if (colorJugador == color(155, 89, 182)) return imgFichaInfluencer;
  if (colorJugador == color(243, 156, 18)) return imgFichaCiudadana;
  return null;
}

void dibujarFichaPeon(float x, float y, int col) {
  PImage img = obtenerImagenFicha(col);
  if (img != null) {
    imageMode(CENTER);
    image(img, x, y - 10, 40, 40);
    imageMode(CORNER);
  } else {
    noStroke(); fill(50, 50, 50, 100); ellipse(x+3, y+5, 24, 10);
    stroke(255); strokeWeight(2); fill(col);
    ellipse(x, y, 24, 10);
    beginShape();
    vertex(x - 8, y - 2); bezierVertex(x - 4, y - 15, x - 2, y - 20, x - 3, y - 25);
    vertex(x + 3, y - 25); bezierVertex(x + 2, y - 20, x + 4, y - 15, x + 8, y - 2);
    endShape(CLOSE);
    ellipse(x, y - 28, 14, 14);
    noStroke(); fill(255, 100); ellipse(x - 2, y - 30, 4, 4);
  }
}

void dibujarCasillaCuadrada3D(float x, float y, float w, int colBase, int colTop, boolean bloqueada, boolean descartada) {
  float h = w * 0.8f;
  if (descartada) { colBase = color(80, 90, 100); colTop = color(120, 130, 140); }
  noStroke(); fill(0, 60); rect(x - w/2 + 6, y - h/2 + 10, w, h, 6);
  fill(colBase); stroke(lerpColor(colBase, color(0), 0.3f)); strokeWeight(2);
  rect(x - w/2, y - h/2 + 8, w, h, 4);
  fill(colTop); rect(x - w/2, y - h/2, w, h, 4);
  fill(255, 200); noStroke(); rect(x - w/2 + 4, y - h/2 + 4, w - 8, h - 8, 2);

  if (descartada) {
    stroke(0, 150); strokeWeight(4);
    line(x - 10, y - 10, x + 10, y + 10); line(x + 10, y - 10, x - 10, y + 10);
  } else if (bloqueada) {
    dibujarIconoCandado(x, y, 22, color(231, 76, 60));
  }
}

// =============================================================================
// GESTIÓN DE ÁRBOL BINARIO DE BÚSQUEDA (BST)
// =============================================================================
void inicializarBST() {
  bstRaiz = -1; bstTamano = 0;
  for (int i = 0; i < MAX_NODOS_BST; i++) {
    bstLibre[i] = true; bstIzq[i] = -1; bstDer[i] = -1; bstClave[i] = 0; bstPubIdx[i] = -1;
  }
}

int bstAsignarNodo(int pIdx, int clave) {
  for (int i = 0; i < MAX_NODOS_BST; i++) {
    if (bstLibre[i]) {
      bstLibre[i] = false; bstClave[i] = clave; bstPubIdx[i] = pIdx;
      bstIzq[i] = -1; bstDer[i] = -1;
      bstTamano++;
      return i;
    }
  }
  return -1;
}

void bstLiberarNodo(int nodo) {
  bstLibre[nodo] = true; bstIzq[nodo] = -1; bstDer[nodo] = -1; bstClave[nodo] = 0; bstPubIdx[nodo] = -1;
  bstTamano--;
}

void bstInsertar(int pIdx) {
  if (pIdx < 0 || pIdx >= totalPubs) return;
  bstRaiz = bstInsertarRecursivo(bstRaiz, pIdx, pubImpactoViral[pIdx]);
}

int bstInsertarRecursivo(int actual, int pIdx, int clave) {
  if (actual == -1) return bstAsignarNodo(pIdx, clave);
  if (clave < bstClave[actual]) bstIzq[actual] = bstInsertarRecursivo(bstIzq[actual], pIdx, clave);
  else if (clave > bstClave[actual]) bstDer[actual] = bstInsertarRecursivo(bstDer[actual], pIdx, clave);
  else {
    if (pubId[pIdx] < pubId[bstPubIdx[actual]]) bstIzq[actual] = bstInsertarRecursivo(bstIzq[actual], pIdx, clave);
    else bstDer[actual] = bstInsertarRecursivo(bstDer[actual], pIdx, clave);
  }
  return actual;
}

int bstMinimoNodo(int nodo) {
  if (nodo == -1) return -1;
  while (bstIzq[nodo] != -1) nodo = bstIzq[nodo];
  return nodo;
}

void bstEliminar(int pIdx) {
  if (pIdx < 0 || pIdx >= totalPubs) return;
  bstRaiz = bstEliminarRecursivo(bstRaiz, pIdx);
}

int bstEliminarRecursivo(int actual, int pIdx) {
  if (actual == -1) return -1;
  if (bstPubIdx[actual] == pIdx) {
    if (bstIzq[actual] == -1 && bstDer[actual] == -1) { bstLiberarNodo(actual); return -1; }
    if (bstIzq[actual] == -1) { int hijoDer = bstDer[actual]; bstLiberarNodo(actual); return hijoDer; }
    if (bstDer[actual] == -1) { int hijoIzq = bstIzq[actual]; bstLiberarNodo(actual); return hijoIzq; }
    int sucesor = bstMinimoNodo(bstDer[actual]);
    int pSucesor = bstPubIdx[sucesor];
    bstClave[actual] = bstClave[sucesor]; bstPubIdx[actual] = pSucesor;
    bstDer[actual] = bstEliminarRecursivo(bstDer[actual], pSucesor);
    return actual;
  }
  int clave = pubImpactoViral[pIdx];
  if (clave < bstClave[actual]) bstIzq[actual] = bstEliminarRecursivo(bstIzq[actual], pIdx);
  else if (clave > bstClave[actual]) bstDer[actual] = bstEliminarRecursivo(bstDer[actual], pIdx);
  else {
    if (pubId[pIdx] < pubId[bstPubIdx[actual]]) bstIzq[actual] = bstEliminarRecursivo(bstIzq[actual], pIdx);
    else bstDer[actual] = bstEliminarRecursivo(bstDer[actual], pIdx);
  }
  return actual;
}

void cambiarImpactoPost(int pIdx, int nuevoImpacto) {
  bstEliminar(pIdx);                                       // sale con su clave vieja
  pubImpactoViral[pIdx] = constrain(nuevoImpacto, 0, 100);
  if (pubImpactoViral[pIdx] <= UMBRAL_DESMENTIDO) pubDesmentida[pIdx] = true;
  else bstInsertar(pIdx);                                  // vuelve con su clave nueva
}

IntList bstObtenerFeedOrdenadoPorImpacto() {
  IntList lista = new IntList(); bstInordenInversoRecursivo(bstRaiz, lista); return lista;
}

void bstInordenInversoRecursivo(int nodo, IntList lista) {
  if (nodo == -1) return;
  bstInordenInversoRecursivo(bstDer[nodo], lista);
  lista.append(bstPubIdx[nodo]);
  bstInordenInversoRecursivo(bstIzq[nodo], lista);
}

// =============================================================================
// GESTIÓN DE ÁRBOL DE DECISIONES N-ARIO (MULTINIVEL)
// =============================================================================
int crearNodoDecision(String texto, String desc, String rol, int dVerdad, int dConv, int dConf, int dBien, int dDesinf, String exp) {
  if (totalNodosDecision >= MAX_NODOS_DECISION) return -1;
  int id = totalNodosDecision; totalNodosDecision++;
  ndTexto[id] = texto; ndCorto[id] = texto; ndDesc[id] = desc; ndRolReq[id] = (rol == null) ? "" : rol;
  ndDeltaVerdad[id] = dVerdad; ndDeltaConvivencia[id] = dConv; ndDeltaConfianza[id] = dConf;
  ndDeltaBienestar[id] = dBien; ndDeltaDesinf[id] = dDesinf; ndExplicacion[id] = exp;
  ndCantHijos[id] = 0; ndX[id] = 0; ndY[id] = 0; ndNivel[id] = 0; ndElegido[id] = false;
  int[] colores = {color(231, 76, 60), color(52, 152, 219), color(46, 204, 113), color(241, 196, 15)};
  ndColorCasilla[id] = colores[(int)random(colores.length)];
  for (int k = 0; k < 6; k++) ndHijos[id][k] = -1;
  return id;
}

void agregarHijoDecision(int padre, int hijo) {
  if (padre < 0 || padre >= totalNodosDecision || hijo < 0 || hijo >= totalNodosDecision) return;
  if (ndCantHijos[padre] < 6) {
    ndHijos[padre][ndCantHijos[padre]] = hijo;
    ndCantHijos[padre]++;
    ndNivel[hijo] = ndNivel[padre] + 1;
  }
}

boolean nodoEstaDisponiblePara(int nodo, String rolJugador) {
  if (nodo < 0 || nodo >= totalNodosDecision) return false;
  String req = ndRolReq[nodo];
  if (req == null || req.trim().isEmpty()) return true;
  return req.equalsIgnoreCase(rolJugador);
}

boolean esHijoDirecto(int padre, int nodo) {
  if (padre < 0 || padre >= totalNodosDecision) return false;
  for (int i = 0; i < ndCantHijos[padre]; i++) if (ndHijos[padre][i] == nodo) return true;
  return false;
}

void calcularLayoutArbol(int raiz, float left, float right, float top, float bottom) {
  if (raiz == -1) return;
  layY0 = top + 30; layY2 = bottom - 10; layY1 = (layY0 + layY2) / 2.0f;

  ndX[raiz] = (left + right) / 2.0f;
  ndY[raiz] = layY0;

  int cantN1 = ndCantHijos[raiz];
  if (cantN1 > 0) {
    float anchoSegN1 = (right - left) / cantN1;
    for (int i = 0; i < cantN1; i++) {
      int hijoN1 = ndHijos[raiz][i];
      float sLeft = left + i * anchoSegN1;
      ndX[hijoN1] = sLeft + anchoSegN1 / 2.0f;
      ndY[hijoN1] = layY1;

      int cantN2 = ndCantHijos[hijoN1];
      if (cantN2 > 0) {
        float anchoSegN2 = anchoSegN1 / cantN2;
        for (int j = 0; j < cantN2; j++) {
          int hijoN2 = ndHijos[hijoN1][j];
          ndX[hijoN2] = sLeft + j * anchoSegN2 + anchoSegN2 / 2.0f;
          ndY[hijoN2] = layY2;
        }
      }
    }
  }
}

void actualizarLayoutArbol() {
  if (pubSeleccionada >= 0 && pubSeleccionada < totalPubs) {
    calcularLayoutArbol(pubArbolRaiz[pubSeleccionada], 250, width - 250, 170, height - 205);
  }
}

// =============================================================================
// INICIALIZACIÓN Y GENERADOR MULTINIVEL DE CARTAS
// =============================================================================
void configurarPartida(int cantidad) {
  cantJugadores = constrain(cantidad, 2, 4);
  turnoActual = 0; rondaActual = 1;
  infoVerificada = 45; convivenciaDigital = 55; confianzaCiudadana = 50; desinformacion = 50;
  pubSeleccionada = -1; nodoActualDecision = -1; mensajeUltimaAccion = "";
  jugoCartaEsteTurno = false; cartaDelTurno = -1;
  framesAnimacionDado = 0; animandoRepartoEnergia = false; progresoReparto = 0;
  contadorPubId = 100; toastFrames = 0; resCount = 0;
  puenteResuelto = false; inspProgreso = 0; inspZoom = 3;

  for (int i = 0; i < 4; i++) {
    jugEnergia[i] = 100; jugPopularidad[i] = POPULARIDAD_INI[i]; jugCredibilidad[i] = CREDIBILIDAD_INI[i];
    jugAlcance[i] = ALCANCE_INI[i]; jugBienestar[i] = BIENESTAR_INI[i];
    for (int p = 0; p < MAX_PUBS; p++) cartaBloqueadaParaJugador[i][p] = false;
  }

  inicializarBST(); totalPubs = 0; totalNodosDecision = 0;
  repartirCasos(3);

  estadoActual = ESTADO_FEED;
}

// Reparte n casos distintos (no se repite el mismo caso en la misma mano)
void repartirCasos(int n) {
  int resto = n;
  // La misión del Puente Nova siempre está en la mesa hasta que se resuelva
  if (!puenteResuelto && resto >= 1) { generarCasoPuenteNova(); resto--; }

  IntList idx = new IntList();
  for (int i = 0; i < casoTema.length; i++) if (i != CASO_PUENTE) idx.append(i);
  idx.shuffle();
  int cuantos = min(resto, idx.size());
  for (int i = 0; i < cuantos; i++) generarCasoAleatorio(idx.get(i));
}

boolean esMision(int pIdx) { return pIdx >= 0 && pIdx < totalPubs && pubCaso[pIdx] == CASO_PUENTE; }

// Busca la imagen del caso: acepta nombre con o sin extensión, en data/casos/ o en data/
String resolverRutaCaso(String nombre) {
  String[] exts = {"", ".jpg", ".jpeg", ".png", ".JPG", ".JPEG", ".PNG", ".gif"};
  String[] bases = {"casos/" + nombre, nombre};
  for (int b = 0; b < bases.length; b++) {
    for (int e = 0; e < exts.length; e++) {
      File f = new File(dataPath(bases[b] + exts[e]));
      if (f.isFile()) return bases[b] + exts[e];
    }
  }
  return null;
}

// Caso especial: imagen falsa creada con IA. Misión exclusiva del PERIODISTA (2 opciones).
void generarCasoPuenteNova() {
  if (totalPubs >= MAX_PUBS) return;

  int r = crearNodoDecision("Imagen viral", "Circula en WhatsApp la imagen de un puente colapsando sobre el Magdalena. ¿Es real o fue creada con IA?", "", 0, 0, 0, 0, 0, "La imagen del puente se vuelve viral en los grupos de Barranquilla.");
  ndCorto[r] = "Puente viral";

  int malo = crearNodoDecision("No desmentir (expandir desinformación)",
    "Callas y dejas que la imagen siga circulando: la desinformación se expande.",
    "PERIODISTA", -15, -10, -12, -8, 25,
    "No desmentiste la imagen: miles la creyeron real y se compartió todavía más.");
  ndCorto[malo] = "No desmentir";

  int bueno = crearNodoDecision("Informar que es IA y cómo identificar estas imágenes",
    "Explicas que el puente fue generado con IA y enseñas a reconocer imágenes falsas.",
    "PERIODISTA", 22, 12, 15, 6, -25,
    "Informaste que es IA y enseñaste a identificarlas: la gente aprendió a verificar.");
  ndCorto[bueno] = "Informar: es IA";

  puenteNodoMalo = malo; puenteNodoBueno = bueno;

  // El orden cambia al azar para que la respuesta correcta no siempre esté en el mismo lado
  if (random(1) < 0.5f) { agregarHijoDecision(r, malo); agregarHijoDecision(r, bueno); }
  else { agregarHijoDecision(r, bueno); agregarHijoDecision(r, malo); }

  // Desenlaces (nivel 2)
  int m1 = crearNodoDecision("Pánico en redes", "La gente cree que el puente se cayó y satura las líneas de emergencia.", "", -8, -10, -8, -6, 10, "Desenlace: el rumor se multiplicó y creció el pánico en redes.");
  int m2 = crearNodoDecision("Confianza rota", "La ciudadanía deja de creer en lo que ve en redes.", "", -6, -8, -10, -4, 8, "Desenlace: la confianza en las noticias se rompió.");
  agregarHijoDecision(malo, m1); agregarHijoDecision(malo, m2);

  int b1 = crearNodoDecision("Guía anti-fakes viral", "Tu guía para detectar imágenes de IA se comparte por toda Barranquilla.", "", 12, 10, 12, 8, -12, "Desenlace: tu guía se volvió tendencia y se desmontó el bulo.");
  int b2 = crearNodoDecision("Barrios verificando", "Los vecinos empiezan a revisar la fuente antes de reenviar en sus grupos.", "", 10, 12, 10, 10, -10, "Desenlace: los barrios adoptaron el hábito de verificar.");
  agregarHijoDecision(bueno, b1); agregarHijoDecision(bueno, b2);

  contadorPubId++;
  registrarPublicacion(contadorPubId, CASO_PUENTE, "@AlertaBAQ_Ya", casoTema[CASO_PUENTE], casoDesc[CASO_PUENTE], 92, false, false, true, r);
  bstInsertar(totalPubs - 1);
}

void registrarPublicacion(int id, int casoIdx, String autor, String titular, String contenido, int impacto, boolean verif, boolean desm, boolean fake, int arbolRaiz) {
  if (totalPubs >= MAX_PUBS) return;
  int idx = totalPubs; totalPubs++;
  pubId[idx] = id; pubCaso[idx] = casoIdx; pubAutor[idx] = autor; pubTitular[idx] = titular; pubContenido[idx] = contenido;
  pubImpactoViral[idx] = impacto; pubVerificada[idx] = verif; pubDesmentida[idx] = desm; pubEsFakeNews[idx] = fake;
  pubArbolRaiz[idx] = arbolRaiz; pubNodoActual[idx] = arbolRaiz; ndElegido[arbolRaiz] = true;
}

void generarCasoAleatorio(int casoIdx) {
  if (totalPubs >= MAX_PUBS) return;
  casoIdx = constrain(casoIdx, 0, casoTema.length - 1);
  String tema = casoTema[casoIdx];

  int r = crearNodoDecision("Alerta Viral", "Circula el rumor: " + tema, "", 0, 0, 0, 0, 0, "¡Barranquilla reacciona al caso!");
  ndNivel[r] = 0;

  // 3 roles distintos por caso (así cada caso favorece a unos roles y bloquea a otros)
  IntList ordenRoles = new IntList();
  for (int k = 0; k < 4; k++) ordenRoles.append(k);
  ordenRoles.shuffle();

  for (int i = 0; i < 3; i++) {
    int ri = ordenRoles.get(i);
    int ai = (int)random(3);
    String rol = ROLES[ri];
    String txt = accionTexto[ri][ai];
    String dsc = accionDesc[ri][ai];
    int h1 = crearNodoDecision(txt, dsc, rol, (int)random(-10, 20), (int)random(-10, 15), (int)random(-10, 20), (int)random(-5, 10), (int)random(-20, 5), "El " + rol + " intervino. " + dsc);
    ndNivel[h1] = 1;
    agregarHijoDecision(r, h1);

    IntList ordenMetas = new IntList();
    for (int k = 0; k < metaTxt.length; k++) ordenMetas.append(k);
    ordenMetas.shuffle();
    for (int j = 0; j < 2; j++) {
      int mi = ordenMetas.get(j);
      int h2 = crearNodoDecision(metaTxt[mi], metaDesc[mi], "", (int)random(5, 25), (int)random(5, 20), (int)random(5, 20), (int)random(5, 15), (int)random(-30, -10), "Desenlace: " + metaDesc[mi]);
      ndNivel[h2] = 2;
      agregarHijoDecision(h1, h2);
    }
  }

  contadorPubId++;
  registrarPublicacion(contadorPubId, casoIdx, "@Usuario_" + (int)random(10, 99), tema, casoDesc[casoIdx], (int)random(50, 99), false, false, random(1) > 0.5f, r);
  bstInsertar(totalPubs - 1);
}

int obtenerMetricaPrincipalPuntos(int idx) {
  String r = jugRol[idx];
  if (r.equals("ALCALDE")) return jugPopularidad[idx];
  if (r.equals("PERIODISTA")) return jugCredibilidad[idx];
  if (r.equals("INFLUENCER")) return jugAlcance[idx];
  return jugBienestar[idx];
}

String nombreMetrica(int idx) {
  String r = jugRol[idx];
  if (r.equals("ALCALDE")) return "Popularidad";
  if (r.equals("PERIODISTA")) return "Credibilidad";
  if (r.equals("INFLUENCER")) return "Alcance";
  return "Bienestar";
}

boolean jugadorTieneCaminosEnCarta(int pIdx, String rol) {
  if (pIdx < 0 || pIdx >= totalPubs) return false;
  int act = pubNodoActual[pIdx];
  if (act == -1) return false;
  int cant = ndCantHijos[act];
  if (cant == 0) return true;
  for (int i = 0; i < cant; i++) {
    if (nodoEstaDisponiblePara(ndHijos[act][i], rol)) return true;
  }
  return false;
}

// =============================================================================
// AVISOS Y RESULTADOS
// =============================================================================
void mostrarToast(String t) { toastTxt = t; toastFrames = 170; }

void dibujarToast() {
  if (toastFrames <= 0) return;
  toastFrames--;
  float a = min(255, toastFrames * 6);
  textFont(fontTexto); textSize(13);
  float w = textWidth(toastTxt) + 44;
  float x = width/2.0f - w/2; float y = 60;
  noStroke(); fill(0, a * 0.3f); rect(x + 3, y + 3, w, 30, 15);
  fill(40, 60, 80, a); rect(x, y, w, 30, 15);
  fill(255, a); textAlign(CENTER, CENTER); text(toastTxt, width/2.0f, y + 14);
}

void agregarResultado(String nombre, int delta, boolean inverso) {
  if (resCount >= MAX_RES) return;
  resNombre[resCount] = nombre; resDelta[resCount] = delta; resInverso[resCount] = inverso;
  resCount++;
}

// =============================================================================
// MENÚ DE OPCIONES Y CONFIGURACIÓN
// =============================================================================
boolean estadoConEngranaje() {
  return estadoActual == ESTADO_CONFIG || estadoActual == ESTADO_FEED || estadoActual == ESTADO_DADO || estadoActual == ESTADO_ARBOL;
}

void dibujarBotonConfiguracion() {
  float bx = width - 62; float by = 8; float bs = 46;
  dibujarSombra(bx, by, bs, bs, 10, 50);
  fill(mouseEn(bx, by, bs, bs) ? color(60, 90, 120) : color(40, 60, 80)); stroke(255); strokeWeight(2);
  rect(bx, by, bs, bs, 10);
  dibujarIconoEngranaje(bx + bs/2, by + bs/2, 12);
}

void dibujarMenuOpciones() {
  noStroke(); fill(0, 180); rect(0, 0, width, height);
  float mw = 420; float mh = 400; float mx = (width - mw) / 2; float my = (height - mh) / 2;
  dibujarSombra(mx, my, mw, mh, 15, 80); fill(250, 245, 235); stroke(41, 128, 185); strokeWeight(4); rect(mx, my, mw, mh, 15);
  noStroke(); fill(41, 128, 185); rect(mx, my, mw, 60, 11, 11, 0, 0); fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(20);
  text("CONFIGURACIÓN DEL JUEGO", mx + mw/2, my + 30);
  dibujarBoton3D(mx + 40, my + 90, mw - 80, 50, isMaximized ? "Modo Ventana (Reducir)" : "Pantalla Completa", color(39, 174, 96));
  dibujarBoton3D(mx + 40, my + 160, mw - 80, 50, "Volver al Menú Principal", color(243, 156, 18));
  dibujarBoton3D(mx + 40, my + 230, mw - 80, 50, "Salir al Escritorio", color(231, 76, 60));
  dibujarBoton3D(mx + 40, my + 320, mw - 80, 50, "Volver a la Partida", color(52, 152, 219));
}

// =============================================================================
// MODAL DE CAMINO BLOQUEADO
// =============================================================================
void dibujarModalCaminoBloqueado() {
  noStroke(); fill(0, 180); rect(0, 0, width, height);
  float mw = 540; float mh = MODAL_BLOQ_H; float mx = (width - mw) / 2; float my = (height - mh) / 2;
  dibujarSombra(mx, my, mw, mh, 15, 80); fill(250, 245, 225); stroke(231, 76, 60); strokeWeight(4); rect(mx, my, mw, mh, 15);
  noStroke(); fill(231, 76, 60); rect(mx, my, mw, 50, 11, 11, 0, 0); fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(22);
  text(motivoBloqueo == 1 ? "SIN ENERGÍA SUFICIENTE" : "ALTO AHÍ: RUTA CERRADA", width/2.0f, my + 25);
  String msj;
  if (motivoBloqueo == 1) {
    msj = "Cada paso en el árbol cuesta " + COSTO_ENERGIA + " de energía y solo tienes " + jugEnergia[turnoActual] + ".\n\n" +
          "La energía se reparte al terminar cada ronda, cuando todos hayan tirado el dado.";
  } else {
    msj = "No puedes pisar la casilla '" + ndTexto[nodoBloqueadoIntento] + "'.\n\n" +
          "Este atajo está reservado para el rol: " + ndRolReq[nodoBloqueadoIntento] + ".\nTu rol actual es: " + jugRol[turnoActual] + ".\n\n" +
          "Elige otra casilla o pasa el turno tirando el dado.";
  }
  fill(60, 40, 20); textFont(fontTexto); textSize(14); textAlign(CENTER, TOP);
  text(msj, mx + 30, my + 70, mw - 60, 120);
  dibujarBoton3D(width/2.0f - 120, my + mh - 60, 240, 45, "Buscar Otro Camino", color(41, 128, 185));
}

// =============================================================================
// PANTALLAS DE INTERFAZ GENERAL
// =============================================================================
void dibujarPantallaPortada() {
  if (imgMenuInicio != null) {
    dibujarImagenFondo(imgMenuInicio);
  } else {
    dibujarCieloYNubes();
    dibujarSombra(width/2.0f - 330, height/2.0f - 120, 660, 190, 20, 60);
    fill(255, 245, 225); stroke(41, 128, 185); strokeWeight(5); rect(width/2.0f - 330, height/2.0f - 120, 660, 190, 20);
    fill(41, 128, 185); textAlign(CENTER, CENTER); textFont(fontGrande); textSize(44);
    text(NOMBRE_JUEGO, width/2.0f, height/2.0f - 55);
    fill(40, 60, 80); textFont(fontTitulo); textSize(18);
    text("Juego de mesa multinivel · Puerta de Oro de Colombia", width/2.0f, height/2.0f + 5);
    textFont(fontTexto); textSize(13); fill(90);
    text("Estructuras de Datos II · BST + Árbol de decisiones N-ario", width/2.0f, height/2.0f + 40);
  }
  dibujarBoton3D(width/2.0f - 120, height - 120, 240, 60, "INICIAR JUEGO", color(46, 204, 113));
}

void dibujarPantallaConfiguracion() {
  if (imgSeleccionJugadores != null) {
    dibujarImagenFondo(imgSeleccionJugadores);
  } else {
    dibujarCieloYNubes();
    dibujarSombra(width/2.0f - 280, 40, 560, 60, 10, 50); fill(41, 128, 185); noStroke(); rect(width/2.0f - 280, 40, 560, 60, 10);
    fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(30);
    text(NOMBRE_JUEGO, width/2.0f, 68);
    textFont(fontTitulo); textSize(14); fill(40, 60, 80); text("Estructuras de Datos II - Selecciona la cantidad de jugadores:", width/2.0f, 130);

    float cX = width/2.0f - 400;
    dibujarCartaPersonaje(cX, 170, 180, 250, "Alcalde", color(41, 128, 185), "Gana popularidad.", imgCardAlcalde);
    dibujarCartaPersonaje(cX+210, 170, 180, 250, "Periodista", color(39, 174, 96), "Desactiva fakes.", imgCardPeriodista);
    dibujarCartaPersonaje(cX+420, 170, 180, 250, "Influencer", color(155, 89, 182), "Viralidad pura.", imgCardInfluencer);
    dibujarCartaPersonaje(cX+630, 170, 180, 250, "Ciudadana", color(243, 156, 18), "Defiende su barrio.", imgCardCiudadana);
  }

  dibujarBoton3D(width/2.0f - 270, height - 100, 160, 60, "2 Jugadores", color(41, 128, 185));
  dibujarBoton3D(width/2.0f - 80, height - 100, 160, 60, "3 Jugadores", color(39, 174, 96));
  dibujarBoton3D(width/2.0f + 110, height - 100, 160, 60, "4 Jugadores", color(243, 156, 18));
}

void dibujarCartaPersonaje(float x, float y, float w, float h, String titulo, int col, String desc, PImage imgCard) {
  if (imgCard != null) {
    image(imgCard, x, y, w, h);
  } else {
    dibujarSombra(x, y, w, h, 12, 40); fill(250, 245, 240); stroke(col); strokeWeight(3); rect(x, y, w, h, 12);
    fill(col); noStroke(); rect(x+2, y+2, w-4, 50, 10, 10, 0, 0);
    fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(16); text(titulo, x + w/2, y + 27);
    dibujarFichaPeon(x + w/2, y + 120, col);
    fill(60); textFont(fontSmall); textSize(12); text(desc, x + w/2, y + 190);
  }
}

// ---- Panel superior: ronda, turno y métricas de la ciudad ----
void dibujarMiniBarra(float x, float y, float w, float h, int valor, int col) {
  noStroke(); fill(0, 40); rect(x, y, w, h, h/2);
  fill(col); rect(x, y, w * constrain(valor, 0, 100) / 100.0f, h, h/2);
}

void dibujarHeaderCentral() {
  float w = 720; float h = 72; float x = width/2.0f - w/2; float y = -12;
  dibujarSombra(x, y, w, h, 15, 30);
  fill(255, 245, 225); stroke(200, 170, 120); strokeWeight(3); rect(x, y, w, h, 15);
  fill(40, 60, 80); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(14);
  text("RONDA " + rondaActual + "/" + maxRondas + "   ·   Turno de " + jugNombre[turnoActual], width/2.0f, 13);

  String[] metNom = {"Verificada", "Convivencia", "Confianza", "Desinformación"};
  int[] metVal = {infoVerificada, convivenciaDigital, confianzaCiudadana, desinformacion};
  int[] metCol = {color(46, 204, 113), color(52, 152, 219), color(243, 156, 18), color(231, 76, 60)};
  float colW = (w - 40) / 4.0f;
  for (int i = 0; i < 4; i++) {
    float cx = x + 20 + i * colW;
    fill(40, 60, 80); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(10);
    text(metNom[i] + " " + metVal[i] + "%", cx, 31);
    dibujarMiniBarra(cx, 39, colW - 14, 8, metVal[i], metCol[i]);
  }
}

float panelX(int i) { return (i % 2 == 0) ? 20 : width - 270; }
float panelY(int i) { return (i < 2) ? 64 : height - 100; }

void dibujarEsquinasJugadores() {
  for (int i = 0; i < cantJugadores; i++) {
    boolean esTurno = (i == turnoActual);
    float x = panelX(i); float y = panelY(i); float w = 250; float h = 84;
    if (esTurno) { dibujarSombra(x, y, w, h, 15, 60); noStroke(); fill(jugColor[i], 100); rect(x - 6, y - 6, w + 12, h + 12, 15); }
    else { dibujarSombra(x, y, w, h, 15, 20); }
    fill(250, 245, 235); stroke(jugColor[i]); strokeWeight(esTurno ? 4 : 2); rect(x, y, w, h, 15);
    noStroke(); fill(jugColor[i]); rect(x+2, y+2, w-4, 24, 12, 12, 0, 0);
    fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(13); text(jugNombre[i], x + w/2, y + 14);
    dibujarFichaPeon(x + 30, y + 62, jugColor[i]);

    fill(40, 60, 80); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
    text(nombreMetrica(i) + ": " + obtenerMetricaPrincipalPuntos(i), x + 62, y + 38);

    // Barra de energía
    dibujarIconoLlama(x + 70, y + 56, 7);
    float ebx = x + 82; float eby = y + 51; float ebw = 120; float ebh = 11;
    float prop = jugEnergia[i] / (float)jugMaxEnergia[i];
    int colE = prop > 0.5f ? color(46, 204, 113) : (prop > 0.25f ? color(243, 156, 18) : color(231, 76, 60));
    noStroke(); fill(0, 40); rect(ebx, eby, ebw, ebh, 5);
    fill(colE); rect(ebx, eby, ebw * prop, ebh, 5);
    fill(40, 60, 80); textAlign(LEFT, CENTER); text(jugEnergia[i] + "/" + jugMaxEnergia[i], ebx + ebw + 6, eby + 5);

    if (esTurno) { fill(231, 76, 60); textAlign(LEFT, CENTER); textSize(11); text("¡TU TURNO!", x + 62, y + 73); }
  }
}

// =============================================================================
// FEED: BANCO DE EVENTOS (BST)
// =============================================================================
float cardX() { return width/2.0f - CARD_W/2; }
float cardY(int i) { return CARD_Y0 + i * (CARD_H + CARD_GAP); }

void dibujarMazoCentral() {
  float tw = CARD_W;
  dibujarSombra(width/2.0f - tw/2, 98, tw, 30, 10, 30);
  noStroke(); fill(40, 60, 80); rect(width/2.0f - tw/2, 98, tw, 30, 10);
  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(13);
  text("BANCO DE EVENTOS · ordenado por impacto viral (BST: " + bstTamano + " casos)", width/2.0f, 113);

  IntList feed = bstObtenerFeedOrdenadoPorImpacto();

  if (feed.size() == 0) {
    fill(40, 60, 80); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(16);
    text("¡Mesa vacía! Tira el dado para buscar nuevos casos.", width/2.0f, 230);
  }

  int mostrar = min(feed.size(), 6);
  for (int i = 0; i < mostrar; i++) {
    int pIdx = feed.get(i);
    dibujarCartaEvento(cardX(), cardY(i), CARD_W, CARD_H, pIdx);
  }

  dibujarBoton3D(width/2.0f - 160, height - 68, 320, 48, "TIRAR DADO Y REPARTIR ENERGÍA", color(243, 156, 18));
}

void dibujarCartaEvento(float x, float y, float w, float h, int pIdx) {
  boolean esM = esMision(pIdx);
  boolean hover = mouseEn(x, y, w, h);
  dibujarSombra(x, y, w, h, 8, 40);
  fill(esM ? color(255, 249, 230) : color(250, 250, 245));
  stroke(esM ? color(230, 170, 30) : (hover ? color(41, 128, 185) : color(200))); strokeWeight((esM || hover) ? 3 : 2);
  rect(x, y, w, h, 8);

  // Miniatura del caso (foto real si existe)
  int ci = pubCaso[pIdx];
  if (casoMini[ci] != null) image(casoMini[ci], x + 6, y + 6, 60, 60);
  else dibujarPlaceholderFoto(x + 6, y + 6, 60, 60);
  if (esM) {
    // Lupa: invita a inspeccionar la imagen (clic en la miniatura)
    noStroke(); fill(40, 60, 80, 210); ellipse(x + 54, y + 54, 20, 20);
    dibujarIconoLupa(x + 54, y + 54, 6, color(255));
    if (pubVerificada[pIdx]) dibujarSello(x + 36, y + 36, 58, "FALSA · IA", color(200, 40, 40), -0.3f);
  }

  float tx = x + 76; float tw = w - 76 - 140;
  textAlign(LEFT, TOP);
  fill(esM ? color(180, 110, 0) : color(110)); textFont(fontSmall); textSize(10);
  text(recortar(pubAutor[pIdx] + "  ·  " + (esM ? "MISIÓN DEL PERIODISTA" : "caso viral"), tw), tx, y + 5);
  fill(20, 30, 40); textFont(fontTitulo); textSize(13);
  text(recortar(pubTitular[pIdx], tw), tx, y + 18);
  fill(90); textFont(fontSmall); textSize(10);
  text(pubContenido[pIdx], tx, y + 36, tw, 24);

  // Barra de impacto con marca del umbral de desmentido
  float bx = tx; float by = y + 63; float bw = tw;
  noStroke(); fill(225); rect(bx, by, bw, 5, 3);
  fill(pubImpactoViral[pIdx] > 70 ? color(231, 76, 60) : color(243, 156, 18));
  rect(bx, by, bw * pubImpactoViral[pIdx] / 100.0f, 5, 3);
  stroke(40, 60, 80); strokeWeight(2);
  line(bx + bw * UMBRAL_DESMENTIDO / 100.0f, by - 2, bx + bw * UMBRAL_DESMENTIDO / 100.0f, by + 7);

  // Insignia de impacto
  noStroke(); fill(231, 76, 60); rect(x + w - 130, y + 8, 120, 22, 6);
  dibujarIconoLlama(x + w - 116, y + 19, 7);
  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(12);
  text("Impacto " + pubImpactoViral[pIdx], x + w - 62, y + 19);

  // Botón de acción
  boolean esLaDelTurno = (cartaDelTurno == pIdx);
  boolean tieneCaminos = jugadorTieneCaminosEnCarta(pIdx, jugRol[turnoActual]);
  boolean bloqueada = cartaBloqueadaParaJugador[turnoActual][pIdx] || !tieneCaminos;
  boolean sinEnergia = (jugEnergia[turnoActual] < COSTO_ENERGIA);

  if (jugoCartaEsteTurno && !esLaDelTurno) {
    dibujarBoton3D(x + w - 130, y + 36, 120, 30, "Ya jugaste", color(150));
  } else if (bloqueada) {
    dibujarBoton3D(x + w - 130, y + 36, 120, 30, esM ? "Solo Periodista" : "Sin Caminos", color(120, 130, 140));
  } else if (sinEnergia) {
    dibujarBoton3D(x + w - 130, y + 36, 120, 30, "Sin Energía", color(150, 50, 50));
  } else {
    dibujarBoton3D(x + w - 130, y + 36, 120, 30, esLaDelTurno ? "Continuar" : "Jugar (-" + COSTO_ENERGIA + ")", color(46, 204, 113));
  }
}

void intentarJugarCarta(int pIdx) {
  boolean esLaDelTurno = (cartaDelTurno == pIdx);
  if (jugoCartaEsteTurno && !esLaDelTurno) {
    mostrarToast("Ya jugaste una carta este turno. Tira el dado para pasar.");
    return;
  }
  if (!jugadorTieneCaminosEnCarta(pIdx, jugRol[turnoActual]) || cartaBloqueadaParaJugador[turnoActual][pIdx]) {
    cartaBloqueadaParaJugador[turnoActual][pIdx] = true;
    mostrarToast(esMision(pIdx) ? "Esta misión es del PERIODISTA. Pasa el turno con el dado." : "Tu rol no tiene rutas disponibles en este caso.");
    return;
  }
  if (jugEnergia[turnoActual] < COSTO_ENERGIA) {
    mostrarToast("Energía insuficiente (cada paso cuesta " + COSTO_ENERGIA + "). Se recarga al terminar la ronda.");
    return;
  }
  abrirArbolPublicacion(pIdx);
}

// =============================================================================
// ANIMACIÓN Y LÓGICA DEL DADO / REPARTO DE ENERGÍA
// =============================================================================
float dadoCentroY() { return height/2.0f - 40; }
float dadoBotonY() {
  if (repartoEstaRonda) return dadoCentroY() + 95 + cantJugadores * 28 + 16 + 12;
  return dadoCentroY() + 175;
}

String etiquetaBotonDado() {
  boolean ultimaTirada = (turnoActual == cantJugadores - 1 && rondaActual >= maxRondas);
  if (ultimaTirada) return "Ver resultados >";
  String sig = jugNombre[(turnoActual + 1) % cantJugadores];
  return "Turno de " + sig.split(" ")[0] + " >";
}

void dibujarDado(float cx, float cy, float s, int valor, boolean tambalear) {
  pushMatrix();
  translate(cx, cy);
  if (tambalear) rotate(sin(frameCount * 0.6f) * 0.18f);
  noStroke(); fill(0, 80); rect(-s/2 + 6, -s/2 + 8, s, s, 22);
  fill(250, 245, 235); stroke(41, 128, 185); strokeWeight(6); rect(-s/2, -s/2, s, s, 22);
  noStroke(); fill(41, 128, 185);
  float d = s * 0.16f; float o = s * 0.27f;
  if (valor == 1 || valor == 3 || valor == 5) ellipse(0, 0, d, d);
  if (valor >= 2) { ellipse(-o, -o, d, d); ellipse(o, o, d, d); }
  if (valor >= 4) { ellipse(o, -o, d, d); ellipse(-o, o, d, d); }
  if (valor == 6) { ellipse(-o, 0, d, d); ellipse(o, 0, d, d); }
  popMatrix();
}

void dibujarPantallaDado() {
  if (imgFondoDado != null) {
    dibujarImagenFondo(imgFondoDado);
  } else {
    dibujarEntornoTablero();
  }
  dibujarHeaderCentral();
  dibujarEsquinasJugadores();

  noStroke(); fill(0, 150); rect(0, 0, width, height);

  float mx = width / 2.0f; float my = dadoCentroY();
  boolean rodando = framesAnimacionDado > 0;

  if (rodando) {
    valorDado = (int)random(1, 7);
    framesAnimacionDado--;
    if (framesAnimacionDado == 0 && repartoEstaRonda) iniciarRepartoEnergiaMonopoly();
  }
  dibujarDado(mx, my, 150, valorDado, rodando);

  if (animandoRepartoEnergia) {
    progresoReparto += 0.035f;
    if (progresoReparto >= 1.0f) {
      animandoRepartoEnergia = false;
      for (int i = 0; i < cantJugadores; i++) {
        jugEnergia[i] = min(jugMaxEnergia[i], jugEnergia[i] + energiaARepartir[i]);
      }
    } else {
      float t = progresoReparto * progresoReparto * (3 - 2 * progresoReparto);
      for (int i = 0; i < cantJugadores; i++) {
        float currX = lerp(mx, panelX(i) + 125, t);
        float currY = lerp(my, panelY(i) + 42, t);
        dibujarIconoLlama(currX - 24, currY, 10);
        fill(255, 210, 60); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(22);
        text("+" + energiaARepartir[i], currX + 6, currY);
      }
    }
  }

  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(22);
  if (rodando) {
    text("Lanzando dado...", mx, my + 100);
  } else if (animandoRepartoEnergia) {
    text("Repartiendo energía a los jugadores...", mx, my + 100);
  } else {
    String tituloDado = repartoEstaRonda
      ? "¡Salió " + valorDado + "! Fin de la ronda " + rondaActual + ": energía repartida"
      : "¡Salió " + valorDado + "! Se reparten " + valorDado + " casos nuevos";
    text(tituloDado, mx, my + 100);

    if (!repartoEstaRonda) {
      fill(255, 220, 120); textFont(fontTexto); textSize(14); textAlign(CENTER, CENTER);
      int faltan = cantJugadores - 1 - turnoActual;
      if (faltan > 0) text("La energía se reparte al terminar la ronda (faltan " + faltan + " turnos después de este).", mx, my + 135);
      else text("Esta fue la última tirada de la partida.", mx, my + 135);
      dibujarBoton3D(mx - 100, dadoBotonY(), 200, 45, etiquetaBotonDado(), color(46, 204, 113));
      return;
    }

    // Tabla de resultados (solo al final de la ronda)
    float bw = 400; float bx = mx - bw/2; float by = my + 95 + 22;
    float bh = cantJugadores * 28 + 16 - 22 + 22;
    dibujarSombra(bx, by, bw, cantJugadores * 28 - 6, 10, 40);
    fill(250, 245, 235); stroke(41, 128, 185); strokeWeight(3); rect(bx, by, bw, cantJugadores * 28 - 6, 10);
    for (int i = 0; i < cantJugadores; i++) {
      float ry = by + 14 + i * 28 - 6;
      fill(jugColor[i]); noStroke(); ellipse(bx + 20, ry + 8, 12, 12);
      fill(40, 60, 80); textAlign(LEFT, CENTER); textFont(fontTexto); textSize(13);
      text(jugNombre[i], bx + 36, ry + 7);
      dibujarIconoLlama(bx + bw - 118, ry + 8, 7);
      fill(39, 174, 96); textFont(fontTitulo); textSize(13); textAlign(LEFT, CENTER);
      text("+" + energiaARepartir[i], bx + bw - 106, ry + 7);
      fill(40, 60, 80); textFont(fontTexto); textSize(12);
      text("= " + jugEnergia[i], bx + bw - 62, ry + 7);
    }
    dibujarBoton3D(mx - 100, dadoBotonY(), 200, 45, etiquetaBotonDado(), color(46, 204, 113));
  }
}

void iniciarRepartoEnergiaMonopoly() {
  animandoRepartoEnergia = true;
  progresoReparto = 0;
  for (int i = 0; i < cantJugadores; i++) {
    energiaARepartir[i] = (valorDado * 6) + (int)random(5, 25);
  }
}

void procesarResultadoDado() {
  turnoActual = (turnoActual + 1) % cantJugadores;

  jugoCartaEsteTurno = false;
  cartaDelTurno = -1;
  for (int p = 0; p < MAX_PUBS; p++) {
    cartaBloqueadaParaJugador[turnoActual][p] = false;
  }

  if (turnoActual == 0) {
    rondaActual++;
    if (rondaActual > maxRondas) {
      rondaActual = maxRondas;
      estadoActual = ESTADO_FIN;
      return;
    }
  }

  inicializarBST();
  totalPubs = 0;
  totalNodosDecision = 0;
  pubSeleccionada = -1;
  nodoActualDecision = -1;

  repartirCasos(valorDado);

  mensajeUltimaAccion = "Es el turno de " + jugNombre[turnoActual] + ".";
  mostrarToast("Turno de " + jugNombre[turnoActual] + " · " + totalPubs + " casos nuevos en la mesa");
  estadoActual = ESTADO_FEED;
}

// =============================================================================
// TABLERO N-ARIO (VISTA DE RUTAS MULTINIVEL)
// =============================================================================
void dibujarBandasNiveles() {
  float[] ys = {layY0, layY1, layY2};
  int actual = (nodoActualDecision >= 0 && nodoActualDecision < totalNodosDecision) ? ndNivel[nodoActualDecision] : 0;
  for (int k = 0; k < 3; k++) {
    // Franja suave del nivel
    noStroke(); fill(255, k == actual ? 50 : 22); rect(10, ys[k] - 50, width - 20, 100, 12);
    // Etiqueta del nivel
    boolean esActual = (k == actual);
    dibujarSombra(14, ys[k] - 21, 205, 42, 10, 30);
    fill(esActual ? color(255, 215, 80) : color(40, 60, 80, 225)); stroke(255); strokeWeight(2);
    rect(14, ys[k] - 21, 205, 42, 10);
    fill(esActual ? color(40, 40, 40) : color(255)); textAlign(LEFT, CENTER); textFont(fontTitulo); textSize(11);
    text(NIVEL_TITULO[k], 24, ys[k] - 7);
    textFont(fontSmall); textSize(10);
    fill(esActual ? color(70, 60, 20) : color(210, 220, 230));
    text(NIVEL_SUB[k], 24, ys[k] + 9);
  }
}

void dibujarArbolBase() {
  if (pubSeleccionada < 0 || pubSeleccionada >= totalPubs) return;
  int raiz = pubArbolRaiz[pubSeleccionada];
  dibujarBandasNiveles();
  dibujarCaminosTablero(raiz, false);
  dibujarCasillasTablero(raiz, jugRol[turnoActual], false);
}

void dibujarTarjetaCasoArbol() {
  float cw = 580; float ch = 78; float cx = width/2.0f - cw/2; float cy = 60;
  dibujarSombra(cx, cy, cw, ch, 12, 40);
  fill(255, 245, 225); stroke(200, 170, 120); strokeWeight(3); rect(cx, cy, cw, ch, 12);
  int ci = pubCaso[pubSeleccionada];
  if (casoBanner[ci] != null) image(casoBanner[ci], cx + 8, cy + 7, 100, 64);
  else dibujarPlaceholderFoto(cx + 8, cy + 7, 100, 64);
  boolean esM = esMision(pubSeleccionada);
  if (esM) {
    // Lupa pulsante: clic en la imagen para inspeccionarla
    float pulso = 1 + 0.12f * sin(frameCount * 0.12f);
    noStroke(); fill(243, 156, 18, 235); ellipse(cx + 92, cy + 55, 26 * pulso, 26 * pulso);
    dibujarIconoLupa(cx + 92, cy + 55, 8, color(255));
    if (pubVerificada[pubSeleccionada]) dibujarSello(cx + 58, cy + 39, 88, "FALSA · IA", color(200, 40, 40), -0.25f);
  }

  float tw = cw - 120 - 140;
  textAlign(LEFT, TOP);
  fill(esM ? color(180, 110, 0) : color(40, 60, 80)); textFont(fontTitulo); textSize(14);
  text(recortar((esM ? "MISIÓN · " : "CASO: ") + pubTitular[pubSeleccionada], tw), cx + 120, cy + 8);
  fill(80); textFont(fontSmall); textSize(11);
  text(pubContenido[pubSeleccionada], cx + 120, cy + 27, tw, 30);
  fill(160, 50, 40); textSize(10);
  text("Impacto viral " + pubImpactoViral[pubSeleccionada] + " · se desmiente si baja a " + UMBRAL_DESMENTIDO + " o menos", cx + 120, cy + 60);

  dibujarBoton3D(cx + cw - 130, cy + 24, 120, 30, "Volver a Mesa", color(231, 76, 60));
}

// Geometría del panel de acciones (usada al dibujar y al hacer clic)
float panelAccX() { return width/2.0f - 280; }
float panelAccY() { return height - 160; }
float btnAccW(int cant) { return min(250, (560 - 40 - 10 * (cant - 1)) / (float)cant); }
float btnAccX0(int cant) { return panelAccX() + (560 - (btnAccW(cant) * cant + 10 * (cant - 1))) / 2.0f; }

void dibujarPanelAcciones() {
  String rolActual = jugRol[turnoActual];
  float panelW = 560; float panelH = 140; float panelX = panelAccX(); float panelY = panelAccY();
  dibujarSombra(panelX, panelY, panelW, panelH, 15, 40);
  fill(250, 245, 235); stroke(200, 180, 150); strokeWeight(3); rect(panelX, panelY, panelW, panelH, 15);

  if (nodoActualDecision == -1) return;

  fill(40, 60, 80); textAlign(LEFT, TOP); textFont(fontTitulo); textSize(15);
  text(recortar("Estás en: " + ndTexto[nodoActualDecision] + "  (Nivel " + ndNivel[nodoActualDecision] + ")", panelW - 40), panelX + 20, panelY + 12);
  fill(90); textFont(fontTexto); textSize(12);
  text(ndDesc[nodoActualDecision], panelX + 20, panelY + 34, panelW - 40, 30);

  int cant = ndCantHijos[nodoActualDecision];
  if (cant == 0) {
    fill(231, 76, 60); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(16);
    text("¡LLEGASTE AL NIVEL FINAL DE ESTA RUTA!", panelX + panelW/2, panelY + 78);
    return;
  }

  // Pista de energía
  if (esMision(pubSeleccionada) && nodoActualDecision == pubArbolRaiz[pubSeleccionada] && inspProgreso < 100) {
    dibujarIconoLupa(panelX + 28, panelY + 76, 7, color(180, 110, 0));
    fill(180, 110, 0); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
    text("Tip: toca la imagen del caso y analízala con la lupa antes de decidir: da bono.", panelX + 44, panelY + 76);
  } else {
    dibujarIconoLlama(panelX + 28, panelY + 76, 7);
    fill(90); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
    text("Tienes " + jugEnergia[turnoActual] + " de energía · cada paso cuesta " + COSTO_ENERGIA + " · pasa el cursor sobre una casilla para ver su efecto", panelX + 40, panelY + 76);
  }

  float btnW = btnAccW(cant); float btnX = btnAccX0(cant); float btnY = panelY + 92;
  for (int i = 0; i < cant; i++) {
    int hijo = ndHijos[nodoActualDecision][i];
    boolean disponible = nodoEstaDisponiblePara(hijo, rolActual);
    boolean conEnergia = jugEnergia[turnoActual] >= COSTO_ENERGIA;
    int colBtn = (disponible && conEnergia) ? color(46, 204, 113) : color(120, 130, 140);
    dibujarBoton3D(btnX, btnY, btnW, 38, ndTexto[hijo], colBtn);
    if (!disponible) dibujarIconoCandado(btnX + 14, btnY + 18, 14, color(231, 76, 60));
    btnX += btnW + 10;
  }
}

void dibujarTooltipNodo() {
  if (pubSeleccionada < 0) return;
  int n = obtenerNodoBajoMouseArbol(pubArbolRaiz[pubSeleccionada], mouseX, mouseY);
  if (n < 0) return;
  float w = 280; float h = (ndNivel[n] >= 1) ? 108 : 70;
  float x = constrain(mouseX + 16, 10, width - w - 10);
  float y = constrain(mouseY + 16, 10, height - h - 10);
  dibujarSombra(x, y, w, h, 10, 70);
  fill(255, 250, 235); stroke(40, 60, 80); strokeWeight(2); rect(x, y, w, h, 10);
  textAlign(LEFT, TOP);
  fill(40, 60, 80); textFont(fontTitulo); textSize(13);
  text(recortar(ndTexto[n] + "  (Nivel " + ndNivel[n] + ")", w - 20), x + 10, y + 8);
  fill(90); textFont(fontSmall); textSize(11);
  text(ndDesc[n], x + 10, y + 27, w - 20, 28);
  String req = (ndRolReq[n] == null || ndRolReq[n].length() == 0) ? "Disponible para todos los roles" : "Solo para: " + ndRolReq[n];
  fill(ndRolReq[n].length() == 0 ? color(39, 130, 90) : color(190, 60, 50)); text(req, x + 10, y + 56);
  if (ndNivel[n] >= 1) {
    fill(40, 60, 80); textFont(fontSmall); textSize(11);
    text("Verif " + signo(ndDeltaVerdad[n]) + "   Conv " + signo(ndDeltaConvivencia[n]) + "   Conf " + signo(ndDeltaConfianza[n]), x + 10, y + 74);
    text("Bienestar " + signo(ndDeltaBienestar[n]) + "   Desinf " + signo(ndDeltaDesinf[n]), x + 10, y + 90);
  }
}

String signo(int v) { return (v > 0 ? "+" : "") + v; }

void dibujarVistaArbolDecision() {
  if (pubSeleccionada < 0 || pubSeleccionada >= totalPubs) return;
  actualizarLayoutArbol();
  dibujarTarjetaCasoArbol();
  dibujarArbolBase();
  dibujarPanelAcciones();
  dibujarTooltipNodo();
}

void dibujarCaminosTablero(int nodo, boolean descartadoPadre) {
  if (nodo == -1) return;
  for (int i = 0; i < ndCantHijos[nodo]; i++) {
    int h = ndHijos[nodo][i];
    boolean caminoDescartado = descartadoPadre || (ndElegido[nodo] && !ndElegido[h] && nodo != nodoActualDecision);
    stroke(caminoDescartado ? color(120, 130, 140) : color(230, 200, 150)); strokeWeight(10);
    float midY = (ndY[nodo] + ndY[h]) / 2.0f; noFill(); bezier(ndX[nodo], ndY[nodo], ndX[nodo], midY, ndX[h], midY, ndX[h], ndY[h]);
    stroke(caminoDescartado ? color(150, 160, 170) : color(255, 150)); strokeWeight(2);
    bezier(ndX[nodo], ndY[nodo], ndX[nodo], midY, ndX[h], midY, ndX[h], ndY[h]);
    dibujarCaminosTablero(h, caminoDescartado);
  }
}

void dibujarCasillasTablero(int nodo, String rolActual, boolean descartadoPadre) {
  if (nodo == -1) return;
  boolean esActual = (nodo == nodoActualDecision);
  boolean disponible = nodoEstaDisponiblePara(nodo, rolActual);
  float w = 55; float h = w * 0.8f;
  int colCasilla = ndColorCasilla[nodo];

  if (esActual) { noStroke(); fill(255, 255, 0, 120); ellipse(ndX[nodo], ndY[nodo], w*2.2f, w*2.2f); }

  // Anillo pulsante en las casillas a las que se puede avanzar
  if (!descartadoPadre && esHijoDirecto(nodoActualDecision, nodo) && disponible && jugEnergia[turnoActual] >= COSTO_ENERGIA) {
    noFill(); stroke(46, 204, 113, 150 + 100 * sin(frameCount * 0.15f)); strokeWeight(4);
    rect(ndX[nodo] - w/2 - 7, ndY[nodo] - h/2 - 7, w + 14, h + 24, 9);
  }

  dibujarCasillaCuadrada3D(ndX[nodo], ndY[nodo], w, lerpColor(colCasilla, color(0), 0.2f), colCasilla, !disponible, descartadoPadre);

  if (!descartadoPadre) {
    // Nombre de la casilla
    float bw = 96;
    dibujarSombra(ndX[nodo] - bw/2, ndY[nodo] - 45, bw, 18, 5, 50);
    noStroke(); fill(40, 60, 80); rect(ndX[nodo] - bw/2, ndY[nodo] - 45, bw, 18, 5);
    fill(255); textAlign(CENTER, CENTER); textFont(fontSmall); textSize(9);
    text(recortar(ndCorto[nodo], bw - 8), ndX[nodo], ndY[nodo] - 36);

    // Etiqueta del rol requerido
    if (ndRolReq[nodo].length() > 0) {
      int rc = jugColor[indiceRol(ndRolReq[nodo])];
      textFont(fontSmall); textSize(9);
      float tw = textWidth(ndRolReq[nodo]) + 12;
      noStroke(); fill(rc); rect(ndX[nodo] - tw/2, ndY[nodo] + 36, tw, 14, 7);
      fill(255); textAlign(CENTER, CENTER); text(ndRolReq[nodo], ndX[nodo], ndY[nodo] + 43);
    }
  }
  if (esActual) dibujarFichaPeon(ndX[nodo], ndY[nodo] - 15, jugColor[turnoActual]);

  for (int i = 0; i < ndCantHijos[nodo]; i++) {
    int hijo = ndHijos[nodo][i];
    boolean hijoDescartado = descartadoPadre || (ndElegido[nodo] && !ndElegido[hijo] && nodo != nodoActualDecision);
    dibujarCasillasTablero(hijo, rolActual, hijoDescartado);
  }
}

// =============================================================================
// MODAL DE CONSECUENCIA (MUESTRA CADA SUMA Y RESTA)
// =============================================================================
void dibujarChipResultado(float x, float y, float w, float h, String nombre, int delta, boolean inverso) {
  boolean neutro = (delta == 0);
  boolean bueno = inverso ? (delta < 0) : (delta > 0);
  int c = neutro ? color(130) : (bueno ? color(39, 174, 96) : color(231, 76, 60));
  fill(255); stroke(c); strokeWeight(2); rect(x, y, w, h, 8);
  fill(40, 60, 80); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(12);
  text(nombre, x + 10, y + h/2);
  fill(c); textAlign(RIGHT, CENTER); textFont(fontTitulo); textSize(15);
  text(signo(delta), x + w - 10, y + h/2);
}

void dibujarModalConsecuencia() {
  noStroke(); fill(0, 150); rect(0, 0, width, height);
  float mw = 620; float mh = MODAL_CONS_H; float mx = (width - mw) / 2; float my = (height - mh) / 2;
  int colMod = resFinal ? color(39, 174, 96) : color(243, 156, 18);
  dibujarSombra(mx, my, mw, mh, 15, 80); fill(255, 245, 225); stroke(colMod); strokeWeight(4); rect(mx, my, mw, mh, 15);
  noStroke(); fill(colMod); rect(mx, my, mw, 50, 11, 11, 0, 0);
  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(22);
  text(resFinal ? "CASO CERRADO" : "ACCIÓN EJECUTADA", width/2.0f, my + 25);

  fill(60, 40, 20); textFont(fontTexto); textSize(13); textAlign(LEFT, TOP);
  boolean conFoto = (pubSeleccionada >= 0 && pubSeleccionada < totalPubs && pubCaso[pubSeleccionada] == CASO_PUENTE);
  text(mensajeUltimaAccion, mx + 30, my + 62, conFoto ? mw - 60 - 130 : mw - 60, 100);

  if (conFoto) {
    // Imagen del caso con su sello de veredicto
    float fx = mx + mw - 140; float fy = my + 62;
    int ci = pubCaso[pubSeleccionada];
    if (casoBanner[ci] != null) image(casoBanner[ci], fx, fy, 110, 70);
    else dibujarPlaceholderFoto(fx, fy, 110, 70);
    noFill(); stroke(200, 170, 120); strokeWeight(2); rect(fx, fy, 110, 70, 4);
    if (pubVerificada[pubSeleccionada]) dibujarSello(fx + 55, fy + 35, 100, "FALSA · IA", color(200, 40, 40), -0.2f);
    else dibujarSello(fx + 55, fy + 35, 104, "SIN DESMENTIR", color(120, 120, 120), -0.2f);
  }

  if (resImpactoTxt.length() > 0) {
    fill(160, 50, 40); textFont(fontTitulo); textSize(13); textAlign(LEFT, TOP);
    text(resImpactoTxt, mx + 30, my + 166);
  }

  float chipW = (mw - 60 - 20) / 3.0f; float chipH = 34;
  for (int i = 0; i < resCount; i++) {
    int fila = i / 3; int col = i % 3;
    dibujarChipResultado(mx + 30 + col * (chipW + 10), my + 192 + fila * (chipH + 8), chipW, chipH, resNombre[i], resDelta[i], resInverso[i]);
  }

  // Al cerrar un caso: consejo real para verificar este tipo de rumor
  if (resFinal && pubSeleccionada >= 0 && pubSeleccionada < totalPubs) {
    noStroke(); fill(225, 240, 230); rect(mx + 30, my + 276, mw - 60, 44, 8);
    fill(30, 90, 60); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
    text("Cómo verificarlo en " + NOMBRE_CIUDAD + ": " + casoVerifica[pubCaso[pubSeleccionada]], mx + 40, my + 278, mw - 80, 40);
  }

  dibujarBoton3D(width/2.0f - 100, my + mh - 62, 200, 45, "Aceptar", color(41, 128, 185));
}

// =============================================================================
// PANTALLA FINAL
// =============================================================================
void dibujarPantallaFin() {
  dibujarCieloYNubes(); noStroke(); fill(0, 100); rect(0, 0, width, height);
  float mw = 640; float mh = MODAL_FIN_H; float mx = (width - mw) / 2; float my = (height - mh) / 2;
  dibujarSombra(mx, my, mw, mh, 15, 60); fill(255); stroke(41, 128, 185); strokeWeight(5); rect(mx, my, mw, mh, 15);
  noStroke(); fill(41, 128, 185); rect(mx, my, mw, 60, 10, 10, 0, 0);
  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(24); text("FIN DEL JUEGO: " + NOMBRE_JUEGO, width/2.0f, my + 30);

  boolean alcaldeGano = (jugPopularidad[0] >= 55);
  fill(60); textFont(fontTexto); textSize(14);
  text(alcaldeGano ? "¡Victoria política! El Alcalde de " + NOMBRE_CIUDAD + " conserva el respaldo ciudadano." : "El Alcalde de " + NOMBRE_CIUDAD + " perdió el respaldo ciudadano.", width/2.0f, my + 90);

  // Ranking por métrica principal
  int[] orden = new int[cantJugadores];
  for (int i = 0; i < cantJugadores; i++) orden[i] = i;
  for (int i = 0; i < cantJugadores - 1; i++) {
    for (int j = i + 1; j < cantJugadores; j++) {
      if (obtenerMetricaPrincipalPuntos(orden[j]) > obtenerMetricaPrincipalPuntos(orden[i])) {
        int tmp = orden[i]; orden[i] = orden[j]; orden[j] = tmp;
      }
    }
  }

  float py = my + 118;
  for (int k = 0; k < cantJugadores; k++) {
    int i = orden[k];
    fill(240); noStroke(); rect(mx + 40, py, mw - 80, 46, 10);
    fill(k == 0 ? color(241, 196, 15) : color(170)); ellipse(mx + 62, py + 23, 28, 28);
    fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(15); text("" + (k + 1), mx + 62, py + 22);
    dibujarFichaPeon(mx + 106, py + 28, jugColor[i]);
    fill(40); textAlign(LEFT, CENTER); textFont(fontTexto); textSize(14);
    text(jugNombre[i], mx + 132, py + 16);
    textFont(fontSmall); textSize(11); fill(90);
    text(nombreMetrica(i) + ": " + obtenerMetricaPrincipalPuntos(i) + " pts", mx + 132, py + 33);
    dibujarMiniBarra(mx + mw - 240, py + 18, 170, 10, obtenerMetricaPrincipalPuntos(i), jugColor[i]);
    py += 54;
  }

  fill(60); textAlign(CENTER, CENTER); textFont(fontSmall); textSize(12);
  text(NOMBRE_CIUDAD + ": Verificada " + infoVerificada + "% · Convivencia " + convivenciaDigital + "% · Confianza " + confianzaCiudadana + "% · Desinformación " + desinformacion + "%", width/2.0f, my + mh - 100);

  dibujarBoton3D(width/2.0f - 120, my + mh - 70, 240, 50, "Volver al Inicio", color(46, 204, 113));
}

// =============================================================================
// INTERACCIÓN CON RATÓN Y CLICS
// =============================================================================
boolean mouseEn(float x, float y, float w, float h) { return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h; }

void dibujarBoton3D(float x, float y, float w, float h, String texto, int fondo) {
  boolean hover = mouseEn(x, y, w, h); float realY = hover ? y + 2 : y;
  noStroke(); fill(lerpColor(fondo, color(0), 0.4f)); rect(x, y + 4, w, h, 8);
  fill(hover ? lerpColor(fondo, color(255), 0.15f) : fondo); rect(x, realY, w, h, 8);
  fill(255, 40); rect(x, realY, w, h/2, 8, 8, 0, 0);
  fill(255); textAlign(CENTER, CENTER); textFont(fontTitulo);
  float s = 14; textSize(s);
  float minS = (h >= 34) ? 11 : 9;
  while (textWidth(texto) > w - 14 && s > minS) { s--; textSize(s); }
  if (textWidth(texto) > w - 14 && h >= 34) {
    textSize(11);
    text(texto, x + 6, realY + 1, w - 12, h - 2);      // texto largo: dos líneas
  } else {
    text(texto, x + w/2, realY + h/2);
  }
}

void abrirArbolPublicacion(int pIdx) {
  if (pIdx < 0 || pIdx >= totalPubs) return;
  pubSeleccionada = pIdx;
  nodoActualDecision = pubNodoActual[pIdx];
  actualizarLayoutArbol();
  estadoActual = ESTADO_ARBOL;
}

void volverAMesa() {
  if (pubSeleccionada >= 0 && pubSeleccionada < totalPubs && !jugadorTieneCaminosEnCarta(pubSeleccionada, jugRol[turnoActual])) {
    cartaBloqueadaParaJugador[turnoActual][pubSeleccionada] = true;
  }
  pubSeleccionada = -1;
  estadoActual = ESTADO_FEED;
}

// Valida rol y energía antes de avanzar a una casilla
void intentarMoverA(int hijo) {
  if (!nodoEstaDisponiblePara(hijo, jugRol[turnoActual])) {
    nodoBloqueadoIntento = hijo; motivoBloqueo = 0; estadoActual = ESTADO_BLOQUEADO; return;
  }
  if (jugEnergia[turnoActual] < COSTO_ENERGIA) {
    nodoBloqueadoIntento = hijo; motivoBloqueo = 1; estadoActual = ESTADO_BLOQUEADO; return;
  }
  seleccionarOpcionArbol(hijo);
}

void seleccionarOpcionArbol(int hijoIdx) {
  if (hijoIdx < 0 || hijoIdx >= totalNodosDecision) return;
  int pIdx = pubSeleccionada;
  if (pIdx < 0 || pIdx >= totalPubs) return;
  int t = turnoActual;
  boolean esFinal = (ndCantHijos[hijoIdx] == 0);
  resCount = 0; resImpactoTxt = "";

  // 1) Métricas de la ciudad (se muestra el cambio REAL, ya recortado a 0..100)
  int a = infoVerificada;
  infoVerificada = constrain(infoVerificada + ndDeltaVerdad[hijoIdx], 0, 100);
  agregarResultado("Verificada", infoVerificada - a, false);

  a = convivenciaDigital;
  convivenciaDigital = constrain(convivenciaDigital + ndDeltaConvivencia[hijoIdx], 0, 100);
  agregarResultado("Convivencia", convivenciaDigital - a, false);

  a = confianzaCiudadana;
  confianzaCiudadana = constrain(confianzaCiudadana + ndDeltaConfianza[hijoIdx], 0, 100);
  agregarResultado("Confianza", confianzaCiudadana - a, false);

  a = desinformacion;
  desinformacion = constrain(desinformacion + ndDeltaDesinf[hijoIdx], 0, 100);
  agregarResultado("Desinformación", desinformacion - a, true);

  // 2) Métrica personal del jugador
  int antesM = obtenerMetricaPrincipalPuntos(t);
  String r = jugRol[t];
  if (r.equals("ALCALDE")) jugPopularidad[t] = constrain(jugPopularidad[t] + ndDeltaConfianza[hijoIdx], 0, 100);
  else if (r.equals("PERIODISTA")) jugCredibilidad[t] = constrain(jugCredibilidad[t] + ndDeltaVerdad[hijoIdx], 0, 100);
  else if (r.equals("INFLUENCER")) jugAlcance[t] = constrain(jugAlcance[t] + abs(ndDeltaConvivencia[hijoIdx]) + 5, 0, 100);
  else if (r.equals("CIUDADANO")) jugBienestar[t] = constrain(jugBienestar[t] + ndDeltaBienestar[hijoIdx] + 5, 0, 100);
  // Misión Puente Nova: bono si se inspeccionó la imagen a fondo y se informó que es IA
  boolean esPuente = (pubCaso[pIdx] == CASO_PUENTE);
  int bonoInsp = 0;
  if (esPuente && hijoIdx == puenteNodoBueno && inspProgreso >= 100) {
    bonoInsp = 8;
    jugCredibilidad[t] = constrain(jugCredibilidad[t] + bonoInsp, 0, 100);
  }
  if (esPuente && ndNivel[hijoIdx] == 1) puenteResuelto = true;
  agregarResultado(nombreMetrica(t), obtenerMetricaPrincipalPuntos(t) - antesM, false);

  // 3) Energía
  int eAntes = jugEnergia[t];
  jugEnergia[t] = max(0, jugEnergia[t] - COSTO_ENERGIA);
  agregarResultado("Energía", jugEnergia[t] - eAntes, false);

  // 4) Impacto viral de la carta (se reubica en el BST)
  int impactoAntes = pubImpactoViral[pIdx];
  if (ndDeltaVerdad[hijoIdx] > 0) { pubVerificada[pIdx] = true; cambiarImpactoPost(pIdx, impactoAntes - ndDeltaVerdad[hijoIdx]); }
  else if (ndDeltaVerdad[hijoIdx] < 0) { cambiarImpactoPost(pIdx, impactoAntes + abs(ndDeltaVerdad[hijoIdx])); }
  resImpactoTxt = "Impacto viral: " + impactoAntes + " -> " + pubImpactoViral[pIdx];

  // 5) La ficha SIEMPRE avanza a la casilla elegida (también en el nivel final)
  pubNodoActual[pIdx] = hijoIdx; ndElegido[hijoIdx] = true; nodoActualDecision = hijoIdx;
  jugoCartaEsteTurno = true; cartaDelTurno = pIdx;

  String veredicto = pubEsFakeNews[pIdx] ? "Veredicto: el rumor era FALSO." : "Veredicto: la noticia tenía base real.";
  String msj = jugNombre[t] + " eligió «" + ndCorto[hijoIdx] + "».\n" + ndExplicacion[hijoIdx];
  if (bonoInsp > 0) msj += "\nBono de inspección: +" + bonoInsp + " Credibilidad por analizar la imagen a fondo.";
  else if (esPuente && hijoIdx == puenteNodoBueno) msj += "\nTip: con la lupa habrías ganado un bono de credibilidad.";

  if (esFinal) {
    if (!pubDesmentida[pIdx]) { pubDesmentida[pIdx] = true; bstEliminar(pIdx); }
    msj += "\nNivel final alcanzado: el caso se retira de la mesa. " + veredicto;
  } else if (pubDesmentida[pIdx]) {
    msj += "\nEl impacto cayó tanto que el caso fue desmentido y sale de la mesa. " + veredicto;
  } else {
    msj += "\nLa ficha avanzó al Nivel " + ndNivel[hijoIdx] + ".";
  }

  mensajeUltimaAccion = msj;
  resFinal = esFinal || pubDesmentida[pIdx];
  estadoActual = ESTADO_CONSECUENCIA;
}

int obtenerNodoBajoMouseArbol(int nodo, float mx, float my) {
  if (nodo == -1) return -1;
  if (mx >= ndX[nodo] - 30 && mx <= ndX[nodo] + 30 && my >= ndY[nodo] - 30 && my <= ndY[nodo] + 30) return nodo;
  for (int i = 0; i < ndCantHijos[nodo]; i++) {
    int encontrado = obtenerNodoBajoMouseArbol(ndHijos[nodo][i], mx, my);
    if (encontrado != -1) return encontrado;
  }
  return -1;
}

// =============================================================================
// INSPECCIÓN DE IMAGEN (LUPA / ZOOM) Y DETALLES VISUALES
// =============================================================================
void abrirInspeccion(int desde) {
  estadoAntesInspeccion = desde;
  inspZoom = 3;
  estadoActual = ESTADO_INSPECCION;
}

void mouseWheel(MouseEvent event) {
  if (estadoActual == ESTADO_INSPECCION) {
    inspZoom = constrain(inspZoom - event.getCount() * 0.4f, 1.5f, 8);
  }
}

void dibujarIconoLupa(float cx, float cy, float r, int col) {
  pushStyle();
  stroke(col); strokeWeight(max(2, r * 0.28f)); noFill();
  ellipse(cx - r * 0.15f, cy - r * 0.15f, r * 1.4f, r * 1.4f);
  line(cx + r * 0.35f, cy + r * 0.35f, cx + r * 0.95f, cy + r * 0.95f);
  popStyle();
}

// Sello rotado tipo "FALSA · IA"
void dibujarSello(float cx, float cy, float w, String txt, int col, float ang) {
  pushStyle();
  pushMatrix();
  translate(cx, cy); rotate(ang);
  noStroke(); fill(255, 215); rect(-w/2, -11, w, 22, 5);
  noFill(); stroke(col); strokeWeight(2.5f); rect(-w/2, -11, w, 22, 5);
  fill(col); noStroke(); textAlign(CENTER, CENTER); textFont(fontTitulo);
  float s = 11; textSize(s);
  while (textWidth(txt) > w - 8 && s > 7) { s--; textSize(s); }
  text(txt, 0, -1);
  popMatrix();
  popStyle();
}

void dibujarInspeccion() {
  noStroke(); fill(0, 190); rect(0, 0, width, height);
  float mw = min(width - 40, 1000); float mh = min(height - 40, 640);
  float mx = (width - mw) / 2; float my = (height - mh) / 2;
  dibujarSombra(mx, my, mw, mh, 15, 80);
  fill(32, 40, 54); stroke(243, 156, 18); strokeWeight(4); rect(mx, my, mw, mh, 15);
  noStroke(); fill(243, 156, 18); rect(mx, my, mw, 50, 11, 11, 0, 0);
  fill(40, 30, 10); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(20);
  text("INSPECCIÓN DE IMAGEN · " + casoTema[CASO_PUENTE], mx + mw/2, my + 25);

  // ---- Zona de la imagen ----
  float ax = mx + 20, ay = my + 66, aw = mw * 0.6f, ah = mh - 66 - 80;
  PImage src = casoOriginal[CASO_PUENTE];
  float ix = ax, iy = ay, iw = aw, ih = ah;
  if (src != null) {
    float ir = (float)src.width / src.height;
    if (aw / ah > ir) { ih = ah; iw = ah * ir; } else { iw = aw; ih = aw / ir; }
    ix = ax + (aw - iw) / 2; iy = ay + (ah - ih) / 2;
    image(src, ix, iy, iw, ih);
  } else {
    dibujarPlaceholderFoto(ax, ay, aw, ah);
    fill(50); textAlign(CENTER, CENTER); textFont(fontSmall); textSize(12);
    text("Falta la imagen: guárdala en la carpeta data como puente_nova.jpg (o .png)", ax + aw/2, ay + ah/2);
  }
  noFill(); stroke(255); strokeWeight(3); rect(ix, iy, iw, ih);

  boolean dentro = mouseEn(ix, iy, iw, ih);
  if (dentro) {
    inspProgreso = min(100, inspProgreso + dist(mouseX, mouseY, pmouseX, pmouseY) * 0.1f);
    float L = 180;
    float lx = constrain(mouseX - L/2, 0, width - L);
    float ly = constrain(mouseY - L/2, 0, height - L);
    if (src != null) {
      float esc = (float)src.width / iw;
      float sw = L / inspZoom * esc; float sh = sw;
      float sx = constrain((mouseX - ix) * esc - sw/2, 0, max(0, src.width - sw));
      float sy = constrain((mouseY - iy) * esc - sh/2, 0, max(0, src.height - sh));
      noStroke(); fill(0, 120); rect(lx + 5, ly + 5, L, L, 8);
      image(src, lx, ly, L, L, (int)sx, (int)sy, (int)(sx + sw), (int)(sy + sh));
    } else {
      noStroke(); fill(255, 230); rect(lx, ly, L, L, 8);
    }
    noFill(); stroke(255, 220, 80); strokeWeight(4); rect(lx, ly, L, L, 4);
    stroke(255, 220, 80, 200); strokeWeight(1);
    line(lx + L/2 - 8, ly + L/2, lx + L/2 + 8, ly + L/2); line(lx + L/2, ly + L/2 - 8, lx + L/2, ly + L/2 + 8);
    noStroke(); fill(40, 30, 10, 220); rect(lx + L - 46, ly + L - 22, 46, 22, 6, 0, 4, 0);
    fill(255, 220, 80); textAlign(CENTER, CENTER); textFont(fontTitulo); textSize(12);
    text("x" + nf(inspZoom, 1, 1), lx + L - 23, ly + L - 11);
  }

  // ---- Panel de análisis ----
  float px = ax + aw + 20; float pw = mx + mw - 20 - px;
  fill(255); textAlign(LEFT, TOP); textFont(fontTitulo); textSize(14);
  text("Análisis de la imagen: " + (int)inspProgreso + "%", px, my + 64);
  noStroke(); fill(0, 90); rect(px, my + 86, pw, 14, 7);
  fill(inspProgreso >= 100 ? color(46, 204, 113) : color(243, 156, 18));
  rect(px, my + 86, pw * inspProgreso / 100.0f, 14, 7);

  float ty = my + 114; float th = 66;
  for (int k = 0; k < pistasIA.length; k++) {
    boolean abierta = inspProgreso >= (k + 1) * 25 - 0.01f;
    noStroke(); fill(abierta ? color(250, 245, 225) : color(55, 66, 84)); rect(px, ty, pw, th - 6, 8);
    if (abierta) {
      fill(40, 60, 80); textAlign(LEFT, TOP); textFont(fontSmall); textSize(12);
      text((k + 1) + ". " + pistasIA[k], px + 10, ty + 6, pw - 20, th - 14);
    } else {
      dibujarIconoCandado(px + 22, ty + (th - 6)/2, 18, color(170, 180, 195));
      fill(170, 180, 195); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
      text("Pista bloqueada: sigue explorando la imagen", px + 42, ty + (th - 6)/2);
    }
    ty += th;
  }

  // ---- Pie ----
  fill(220, 225, 235); textAlign(LEFT, CENTER); textFont(fontSmall); textSize(11);
  String info = "Mueve la lupa por la imagen · Rueda del ratón: zoom (x" + nf(inspZoom, 1, 1) + ")";
  if (inspProgreso >= 100) info = "Análisis completo: si desmientes el caso ganas +8 de Credibilidad.";
  text(info, mx + 20, my + mh - 40);

  inspBtnW = 200; inspBtnH = 44; inspBtnX = mx + mw - 20 - inspBtnW; inspBtnY = my + mh - 62;
  dibujarBoton3D(inspBtnX, inspBtnY, inspBtnW, inspBtnH, "Cerrar lupa", color(41, 128, 185));
}

void mousePressed() {
  if (estadoConEngranaje() && mouseEn(width - 62, 8, 46, 46)) {
    estadoAnterior = estadoActual; estadoActual = ESTADO_MENU; return;
  }

  if (estadoActual == ESTADO_INSPECCION) {
    if (mouseEn(inspBtnX, inspBtnY, inspBtnW, inspBtnH)) estadoActual = estadoAntesInspeccion;
    return;
  }

  if (estadoActual == ESTADO_PORTADA) {
    if (mouseEn(width/2.0f - 120, height - 120, 240, 60)) estadoActual = ESTADO_CONFIG;
    return;
  }

  if (estadoActual == ESTADO_CONFIG) {
    if (mouseEn(width/2.0f - 270, height - 100, 160, 60)) configurarPartida(2);
    else if (mouseEn(width/2.0f - 80, height - 100, 160, 60)) configurarPartida(3);
    else if (mouseEn(width/2.0f + 110, height - 100, 160, 60)) configurarPartida(4);
    return;
  }

  if (estadoActual == ESTADO_MENU) {
    float mw = 420; float mh = 400; float mx = (width - mw) / 2; float my = (height - mh) / 2;
    if (mouseEn(mx + 40, my + 90, mw - 80, 50)) {
      if (!isMaximized) { surface.setSize(displayWidth, displayHeight); surface.setLocation(0, 0); isMaximized = true; }
      else { surface.setSize(1120, 720); isMaximized = false; }
    }
    else if (mouseEn(mx + 40, my + 160, mw - 80, 50)) { estadoActual = ESTADO_PORTADA; }
    else if (mouseEn(mx + 40, my + 230, mw - 80, 50)) { exit(); }
    else if (mouseEn(mx + 40, my + 320, mw - 80, 50)) { estadoActual = estadoAnterior; }
    return;
  }

  if (estadoActual == ESTADO_BLOQUEADO) {
    float my = (height - MODAL_BLOQ_H) / 2;
    if (mouseEn(width/2.0f - 120, my + MODAL_BLOQ_H - 60, 240, 45)) estadoActual = ESTADO_ARBOL;
    return;
  }

  if (estadoActual == ESTADO_DADO) {
    if (framesAnimacionDado == 0 && !animandoRepartoEnergia) {
      if (mouseEn(width/2.0f - 100, dadoBotonY(), 200, 45)) {
        procesarResultadoDado();   // decide por sí sola si pasa a FEED o a FIN
      }
    }
    return;
  }

  if (estadoActual == ESTADO_FEED) {
    IntList feed = bstObtenerFeedOrdenadoPorImpacto();
    int mostrar = min(feed.size(), 6);
    for (int i = 0; i < mostrar; i++) {
      int pIdx = feed.get(i);
      if (esMision(pIdx) && mouseEn(cardX() + 6, cardY(i) + 6, 60, 60)) { abrirInspeccion(ESTADO_FEED); return; }
      if (mouseEn(cardX() + CARD_W - 130, cardY(i) + 36, 120, 30)) {
        intentarJugarCarta(pIdx);
        return;
      }
    }
    if (mouseEn(width/2.0f - 160, height - 68, 320, 48)) {
      // La energía solo se reparte cuando esta tirada cierra la ronda (último jugador)
      repartoEstaRonda = (turnoActual == cantJugadores - 1) && rondaActual < maxRondas;
      estadoActual = ESTADO_DADO; framesAnimacionDado = 30; animandoRepartoEnergia = false; return;
    }
    return;
  }

  if (estadoActual == ESTADO_ARBOL) {
    if (mouseEn(width/2.0f + 160, 84, 120, 30)) { volverAMesa(); return; }
    if (esMision(pubSeleccionada) && mouseEn(width/2.0f - 282, 67, 100, 64)) { abrirInspeccion(ESTADO_ARBOL); return; }

    if (nodoActualDecision != -1) {
      int cant = ndCantHijos[nodoActualDecision];
      if (cant > 0) {
        float btnW = btnAccW(cant); float btnX = btnAccX0(cant); float btnY = panelAccY() + 92;
        for (int i = 0; i < cant; i++) {
          int hijo = ndHijos[nodoActualDecision][i];
          if (mouseEn(btnX, btnY, btnW, 38)) { intentarMoverA(hijo); return; }
          btnX += btnW + 10;
        }
      }

      int clicado = obtenerNodoBajoMouseArbol(pubArbolRaiz[pubSeleccionada], mouseX, mouseY);
      if (clicado != -1 && esHijoDirecto(nodoActualDecision, clicado)) {
        intentarMoverA(clicado);
        return;
      }
    }
    return;
  }

  if (estadoActual == ESTADO_CONSECUENCIA) {
    float my = (height - MODAL_CONS_H) / 2;
    if (mouseEn(width/2.0f - 100, my + MODAL_CONS_H - 62, 200, 45)) {
      if (pubSeleccionada == -1 || pubDesmentida[pubSeleccionada]) {
        pubSeleccionada = -1;
        estadoActual = ESTADO_FEED;
      } else {
        estadoActual = ESTADO_ARBOL;
      }
    }
    return;
  }

  if (estadoActual == ESTADO_FIN) {
    float my = (height - MODAL_FIN_H) / 2;
    if (mouseEn(width/2.0f - 120, my + MODAL_FIN_H - 70, 240, 50)) {
      estadoActual = ESTADO_CONFIG;
    }
    return;
  }
}

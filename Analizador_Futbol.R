# ============================================================
# ANALIZADOR DE ESTADISTICAS DE FUTBOL
# Proyecto completo para RStudio
# Datos locales: jugadores, partidos y rendimiento
# ============================================================

# 1. PAQUETES -------------------------------------------------
paquetes <- c("dplyr", "tidyr", "readr", "readxl", "writexl", "purrr")

instalar_paquetes <- function() {
  faltantes <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltantes) > 0) {
    install.packages(faltantes, dependencies = TRUE)
  }
  invisibile <- lapply(paquetes, function(p) {
    suppressPackageStartupMessages(
      library(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
    )
  })
  invisible(invisibile)
}
instalar_paquetes()

# 2. RUTAS Y CARGA DE DATOS -----------------------------------
# Coloca los tres CSV dentro de la carpeta "datos".
# El proyecto intenta primero encontrarlos junto al script y luego en datos/.
buscar_archivo <- function(nombre) {
  candidatos <- c(file.path("datos", nombre), nombre,
                  file.path(getwd(), "datos", nombre))
  encontrado <- candidatos[file.exists(candidatos)]
  if (length(encontrado) > 0) return(encontrado[1])
  message("No se encontro: ", nombre)
  message("Selecciona manualmente el archivo.")
  file.choose()
}

cargar_csv_inicial <- function(nombre) {
  readr::read_csv(buscar_archivo(nombre), show_col_types = FALSE,
                  progress = FALSE, na = c("", "NA"))
}

jugadores <- cargar_csv_inicial("jugadores_1500.csv")
partidos <- cargar_csv_inicial("partidos_2500.csv")
rendimiento <- cargar_csv_inicial("rendimiento_7000.csv")

# 3. PREPARACION Y VALIDACION ---------------------------------
columnas_requeridas <- list(
  jugadores = c("id_jugador", "jugador", "posicion", "edad", "equipo", "nacionalidad"),
  partidos = c("id_partido", "fecha", "temporada", "equipo_local",
               "equipo_visitante", "goles_local", "goles_visitante"),
  rendimiento = c("id_registro", "id_partido", "id_jugador", "minutos",
                  "goles", "asistencias", "tiros", "pases_completados",
                  "tarjetas_amarillas", "tarjeta_roja")
)

validar_columnas <- function(df, requeridas, nombre) {
  faltan <- setdiff(requeridas, names(df))
  if (length(faltan) > 0) {
    stop("El archivo ", nombre, " no contiene estas columnas: ",
         paste(faltan, collapse = ", "))
  }
}

# for: valida de forma iterativa las columnas requeridas de cada data frame.
tablas_iniciales <- list(jugadores = jugadores, partidos = partidos,
                         rendimiento = rendimiento)
for (nombre_tabla in names(columnas_requeridas)) {
  validar_columnas(tablas_iniciales[[nombre_tabla]],
                   columnas_requeridas[[nombre_tabla]], nombre_tabla)
}

jugadores <- jugadores %>%
  mutate(
    id_jugador = as.integer(id_jugador),
    edad = as.integer(edad),
    posicion = as.factor(posicion),
    jugador = as.character(jugador),
    equipo = as.character(equipo)
  )

partidos <- partidos %>%
  mutate(
    id_partido = as.integer(id_partido),
    fecha = as.Date(fecha),
    temporada = as.factor(temporada),
    goles_local = as.integer(goles_local),
    goles_visitante = as.integer(goles_visitante)
  )

rendimiento <- rendimiento %>%
  mutate(across(c(id_registro, id_partido, id_jugador, minutos, goles,
                  asistencias, tiros, pases_completados,
                  tarjetas_amarillas, tarjeta_roja), as.integer))

validar_datos <- function() {
  cat("\n========== VALIDACION DE DATOS ==========\n")
  cat("Jugadores:", nrow(jugadores), "\n")
  cat("Partidos:", nrow(partidos), "\n")
  cat("Registros de rendimiento:", nrow(rendimiento), "\n")
  cat("IDs de jugadores duplicados:", sum(duplicated(jugadores$id_jugador)), "\n")
  cat("IDs de partidos duplicados:", sum(duplicated(partidos$id_partido)), "\n")
  cat("IDs de rendimiento duplicados:", sum(duplicated(rendimiento$id_registro)), "\n")
  cat("Rendimientos sin jugador relacionado:",
      sum(!rendimiento$id_jugador %in% jugadores$id_jugador), "\n")
  cat("Rendimientos sin partido relacionado:",
      sum(!rendimiento$id_partido %in% partidos$id_partido), "\n")
  cat("Jugadores sin registros de rendimiento:",
      sum(!jugadores$id_jugador %in% rendimiento$id_jugador), "\n")
  cat("Combinaciones repetidas partido-jugador:",
      sum(duplicated(rendimiento[c("id_partido", "id_jugador")])), "\n")
  cat("Valores faltantes (jugadores/partidos/rendimiento):",
      sum(is.na(jugadores)), "/", sum(is.na(partidos)), "/",
      sum(is.na(rendimiento)), "\n")
  cat("=========================================\n")
}

# Une las tres tablas mediante sus claves.
crear_base_completa <- function() {
  rendimiento %>%
    left_join(jugadores, by = "id_jugador") %>%
    left_join(partidos, by = "id_partido")
}

# 4. FUNCIONES AUXILIARES -------------------------------------
pausa <- function() {
  invisible(readline("\nPresiona ENTER para continuar..."))
}

leer_numero <- function(mensaje, minimo = 0, maximo = Inf) {
  repeat {
    x <- suppressWarnings(as.numeric(readline(mensaje)))
    if (length(x) == 1 && !is.na(x) && x >= minimo && x <= maximo) {
      return(x)
    }
    cat("Ingresa un numero valido entre", minimo, "y", maximo, ".\n")
  }
}

leer_texto <- function(mensaje) {
  repeat {
    x <- trimws(readline(mensaje))
    if (nzchar(x)) return(x)
    cat("El valor no puede quedar vacio.\n")
  }
}

mostrar_tabla <- function(df, n = 30) {
  if (nrow(df) == 0) {
    cat("No se encontraron resultados.\n")
  } else {
    print(as.data.frame(utils::head(df, n)), row.names = FALSE)
    if (nrow(df) > n) cat("Mostrando", n, "de", nrow(df), "registros.\n")
  }
}

obtener_estadisticas_jugador <- function() {
  rendimiento %>%
    group_by(id_jugador) %>%
    summarise(
      partidos_registrados = n_distinct(id_partido),
      minutos = sum(minutos, na.rm = TRUE),
      goles = sum(goles, na.rm = TRUE),
      asistencias = sum(asistencias, na.rm = TRUE),
      tiros = sum(tiros, na.rm = TRUE),
      pases_completados = sum(pases_completados, na.rm = TRUE),
      amarillas = sum(tarjetas_amarillas, na.rm = TRUE),
      rojas = sum(tarjeta_roja, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(jugadores, by = "id_jugador")
}

# 5. OPCIONES DEL MENU ----------------------------------------

# Opcion 1: registrar jugador
registrar_jugador <- function() {
  cat("\n--- REGISTRAR JUGADOR ---\n")
  id <- if (nrow(jugadores) == 0) 1L else max(jugadores$id_jugador, na.rm = TRUE) + 1L
  nombre <- leer_texto("Nombre del jugador: ")
  posiciones <- levels(droplevels(jugadores$posicion))
  cat("Posiciones disponibles:", paste(posiciones, collapse = ", "), "\n")
  posicion <- leer_texto("Posicion: ")
  edad <- as.integer(leer_numero("Edad: ", 15, 60))
  equipo <- leer_texto("Equipo: ")
  nacionalidad <- leer_texto("Nacionalidad: ")

  nuevo <- tibble(
    id_jugador = as.integer(id), jugador = nombre,
    posicion = posicion, edad = edad,
    equipo = equipo, nacionalidad = nacionalidad
  )
  jugadores <<- bind_rows(jugadores, nuevo) %>%
    mutate(posicion = as.factor(posicion))
  cat("Jugador registrado con ID", id, "\n")
}

# Opcion 2: registrar estadisticas para un jugador y partido existente
registrar_estadisticas <- function() {
  cat("\n--- REGISTRAR ESTADISTICAS ---\n")
  idj <- as.integer(leer_numero("ID del jugador: ", 1))
  idp <- as.integer(leer_numero("ID del partido: ", 1))
  if (!idj %in% jugadores$id_jugador) {
    cat("No existe ese jugador.\n"); return(invisible(NULL))
  }
  if (!idp %in% partidos$id_partido) {
    cat("No existe ese partido.\n"); return(invisible(NULL))
  }
  nuevo <- tibble(
    id_registro = if (nrow(rendimiento) == 0) 1L else max(rendimiento$id_registro) + 1L,
    id_partido = idp, id_jugador = idj,
    minutos = as.integer(leer_numero("Minutos (0-120): ", 0, 120)),
    goles = as.integer(leer_numero("Goles: ", 0)),
    asistencias = as.integer(leer_numero("Asistencias: ", 0)),
    tiros = as.integer(leer_numero("Tiros: ", 0)),
    pases_completados = as.integer(leer_numero("Pases completados: ", 0)),
    tarjetas_amarillas = as.integer(leer_numero("Tarjetas amarillas: ", 0)),
    tarjeta_roja = as.integer(leer_numero("Tarjetas rojas: ", 0))
  )
  if (any(rendimiento$id_partido == idp & rendimiento$id_jugador == idj)) {
    cat("Aviso: ya existe un registro para este jugador y partido.\n")
    confirmar <- tolower(readline("¿Agregar otro registro de todos modos? (s/n): "))
    if (confirmar != "s") return(invisible(NULL))
  }
  rendimiento <<- bind_rows(rendimiento, nuevo)
  cat("Estadisticas registradas.\n")
}

# Opcion 3: mostrar jugadores
mostrar_jugadores <- function() {
  cat("\n--- JUGADORES ---\n")
  mostrar_tabla(jugadores %>% arrange(jugador))
}

# Opcion 4: buscar jugador
buscar_jugador <- function() {
  termino <- tolower(leer_texto("Nombre o parte del nombre: "))
  resultado <- jugadores %>%
    filter(grepl(termino, tolower(jugador), fixed = TRUE))
  mostrar_tabla(resultado)
}

# Opcion 5: buscar jugadores por equipo
buscar_por_equipo <- function() {
  cat("Equipos disponibles:\n")
  print(sort(unique(jugadores$equipo)))
  equipo_buscar <- leer_texto("Equipo: ")
  mostrar_tabla(jugadores %>% filter(tolower(equipo) == tolower(equipo_buscar)) %>%
                   arrange(jugador))
}

# Opcion 6: buscar jugadores por posicion
buscar_por_posicion <- function() {
  cat("Posiciones disponibles:\n")
  print(levels(droplevels(jugadores$posicion)))
  pos <- leer_texto("Posicion: ")
  mostrar_tabla(jugadores %>% filter(tolower(as.character(posicion)) == tolower(pos)) %>%
                  arrange(jugador))
}

# Opcion 7: goleadores
mostrar_goleadores <- function() {
  resultado <- obtener_estadisticas_jugador() %>%
    arrange(desc(goles), desc(asistencias), desc(minutos)) %>%
    select(id_jugador, jugador, equipo, posicion, partidos_registrados, goles,
           asistencias, minutos)
  mostrar_tabla(resultado)
}

# Opcion 8: lideres en asistencias
mostrar_asistentes <- function() {
  resultado <- obtener_estadisticas_jugador() %>%
    arrange(desc(asistencias), desc(goles), desc(minutos)) %>%
    select(id_jugador, jugador, equipo, posicion, partidos_registrados,
           asistencias, goles, minutos)
  mostrar_tabla(resultado)
}

# Opcion 9: mas minutos
mostrar_minutos <- function() {
  resultado <- obtener_estadisticas_jugador() %>%
    arrange(desc(minutos)) %>%
    select(id_jugador, jugador, equipo, posicion, partidos_registrados,
           minutos, goles, asistencias)
  mostrar_tabla(resultado)
}

# Opcion 10: comparar jugadores
comparar_jugadores <- function() {
  cat("\n--- COMPARAR JUGADORES ---\n")
  id1 <- as.integer(leer_numero("ID del primer jugador: ", 1))
  id2 <- as.integer(leer_numero("ID del segundo jugador: ", 1))
  if (id1 == id2) {
    cat("Selecciona dos IDs diferentes.\n"); return(invisible(NULL))
  }
  resultado <- obtener_estadisticas_jugador() %>%
    filter(id_jugador %in% c(id1, id2)) %>%
    select(jugador, equipo, posicion, partidos_registrados, minutos,
           goles, asistencias, tiros, pases_completados, amarillas, rojas)
  mostrar_tabla(resultado)
  if (nrow(resultado) < 2) cat("Uno o ambos IDs no tienen datos suficientes.\n")
}

# Opcion 11: comparar equipos usando resultados de partidos
calcular_tabla_equipos <- function() {
  local <- partidos %>%
    transmute(equipo = equipo_local, GF = goles_local, GC = goles_visitante)
  visitante <- partidos %>%
    transmute(equipo = equipo_visitante, GF = goles_visitante, GC = goles_local)
  bind_rows(local, visitante) %>%
    mutate(
      puntos = case_when(GF > GC ~ 3L, GF == GC ~ 1L, TRUE ~ 0L),
      victoria = as.integer(GF > GC),
      empate = as.integer(GF == GC),
      derrota = as.integer(GF < GC)
    ) %>%
    group_by(equipo) %>%
    summarise(
      partidos = n(), victorias = sum(victoria), empates = sum(empate),
      derrotas = sum(derrota), goles_favor = sum(GF), goles_contra = sum(GC),
      diferencia = goles_favor - goles_contra, puntos = sum(puntos),
      .groups = "drop"
    ) %>%
    arrange(desc(puntos), desc(diferencia), desc(goles_favor))
}

comparar_equipos <- function() {
  tabla <- calcular_tabla_equipos()
  cat("\n--- TABLA GENERAL DE EQUIPOS ---\n")
  mostrar_tabla(tabla)
  e1 <- leer_texto("Primer equipo: ")
  e2 <- leer_texto("Segundo equipo: ")
  mostrar_tabla(tabla %>% filter(tolower(equipo) %in% tolower(c(e1, e2))))
  cat("Nota: los equipos se comparan usando los marcadores del archivo de partidos.\n")
}

# Opcion 12: analizar temporada
analizar_temporada <- function() {
  cat("\nTemporadas disponibles:\n")
  print(levels(droplevels(partidos$temporada)))
  temp <- leer_texto("Temporada: ")
  partidos_temp <- partidos %>% filter(as.character(temporada) == temp)
  if (nrow(partidos_temp) == 0) {
    cat("No se encontraron partidos para esa temporada.\n"); return(invisible(NULL))
  }
  rendimiento_temp <- rendimiento %>%
    inner_join(partidos_temp %>% select(id_partido, temporada), by = "id_partido")
  resumen <- rendimiento_temp %>%
    summarise(
      registros = n(), jugadores = n_distinct(id_jugador),
      minutos = sum(minutos), goles = sum(goles),
      asistencias = sum(asistencias),
      amarillas = sum(tarjetas_amarillas), rojas = sum(tarjeta_roja)
    )
  cat("\n--- RESUMEN DE TEMPORADA ---\n")
  print(resumen)
  cat("\nResultados por equipo (partidos):\n")
  equipos_temp <- partidos_temp %>%
    transmute(equipo = equipo_local, GF = goles_local, GC = goles_visitante) %>%
    bind_rows(partidos_temp %>%
                transmute(equipo = equipo_visitante, GF = goles_visitante,
                          GC = goles_local)) %>%
    group_by(equipo) %>%
    summarise(partidos = n(), goles_favor = sum(GF),
              goles_contra = sum(GC), .groups = "drop") %>%
    arrange(desc(goles_favor))
  mostrar_tabla(equipos_temp)
  cat("\nGoles y asistencias por jugador:\n")
  jugadores_temp <- rendimiento_temp %>%
    group_by(id_jugador) %>%
    summarise(goles = sum(goles), asistencias = sum(asistencias),
              minutos = sum(minutos), .groups = "drop") %>%
    left_join(jugadores, by = "id_jugador") %>%
    arrange(desc(goles), desc(asistencias))
  mostrar_tabla(jugadores_temp)
  # pivot_longer: pasa goles/asistencias a formato largo.
  largo <- jugadores_temp %>%
    select(jugador, goles, asistencias) %>%
    tidyr::pivot_longer(cols = c(goles, asistencias),
                        names_to = "estadistica", values_to = "valor")
  cat("\nFormato largo (pivot_longer):\n")
  mostrar_tabla(largo, 10)
  # pivot_wider: vuelve a formato ancho.
  ancho <- largo %>%
    tidyr::pivot_wider(names_from = estadistica, values_from = valor)
  cat("\nFormato ancho (pivot_wider):\n")
  mostrar_tabla(ancho, 10)
}

# Opcion 13: mejores jugadores por contribuciones (goles + asistencias)
mostrar_mejores <- function() {
  resultado <- obtener_estadisticas_jugador() %>%
    mutate(contribuciones = goles + asistencias,
           contribuciones_por_90 = if_else(minutos > 0,
             contribuciones / minutos * 90, 0)) %>%
    arrange(desc(contribuciones), desc(contribuciones_por_90), desc(minutos)) %>%
    select(jugador, equipo, posicion, partidos_registrados, goles,
           asistencias, contribuciones, minutos, contribuciones_por_90)
  cat("Criterio: contribuciones = goles + asistencias. No es una calificacion oficial.\n")
  mostrar_tabla(resultado)
}

# Opcion 14: estadisticas generales y uso de apply/lapply/sapply/tapply/map
estadisticas_generales <- function() {
  cat("\n--- ESTADISTICAS GENERALES ---\n")
  cat("Jugadores:", nrow(jugadores), "\n")
  cat("Equipos en jugadores:", n_distinct(jugadores$equipo), "\n")
  cat("Partidos:", nrow(partidos), "\n")
  cat("Temporadas:", n_distinct(partidos$temporada), "\n")
  cat("Registros de rendimiento:", nrow(rendimiento), "\n")
  cat("Goles registrados:", sum(rendimiento$goles), "\n")
  cat("Asistencias registradas:", sum(rendimiento$asistencias), "\n")
  cat("Minutos registrados:", sum(rendimiento$minutos), "\n")

  cat("\nJugadores por posicion (tapply):\n")
  print(tapply(jugadores$id_jugador, jugadores$posicion, length))

  cat("\nResumen numerico por columnas (apply):\n")
  numericas <- rendimiento %>%
    select(minutos, goles, asistencias, tiros, pases_completados,
           tarjetas_amarillas, tarjeta_roja) %>% as.matrix()
  print(apply(numericas, 2, mean, na.rm = TRUE))

  cat("\nResumen de cada tabla (lapply):\n")
  resumen_tablas <- lapply(list(jugadores = jugadores,
                                partidos = partidos,
                                rendimiento = rendimiento),
                           function(x) c(filas = nrow(x), columnas = ncol(x)))
  print(resumen_tablas)

  cat("\nConteos por posicion (sapply):\n")
  conteos <- sapply(levels(droplevels(jugadores$posicion)),
                    function(pos) sum(jugadores$posicion == pos, na.rm = TRUE))
  print(conteos)

  cat("\nGoles por temporada (purrr::map):\n")
  goles_por_temporada <- partidos %>%
    distinct(id_partido, temporada) %>%
    inner_join(rendimiento, by = "id_partido") %>%
    group_by(temporada) %>%
    summarise(goles = sum(goles), .groups = "drop")
  lista_temporadas <- split(goles_por_temporada, goles_por_temporada$temporada)
  print(purrr::map(lista_temporadas, ~ .x$goles))
}

# Opcion 15: cargar datos desde CSV o Excel
cargar_archivo_externo <- function() {
  cat("\n--- CARGAR DATOS ---\n")
  cat("1. Reemplazar tabla de jugadores\n")
  cat("2. Reemplazar tabla de partidos\n")
  cat("3. Reemplazar tabla de rendimiento\n")
  cat("4. Volver\n")
  op <- readline("Selecciona: ")
  if (op == "4") return(invisible(NULL))
  tabla <- switch(op, "1" = "jugadores", "2" = "partidos", "3" = "rendimiento",
                  {cat("Opcion no valida.\n"); return(invisible(NULL))})
  archivo <- file.choose()
  extension <- tolower(tools::file_ext(archivo))
  nuevo <- if (extension == "csv") {
    readr::read_csv(archivo, show_col_types = FALSE)
  } else if (extension %in% c("xlsx", "xls")) {
    readxl::read_excel(archivo)
  } else {
    cat("Formato no compatible. Usa CSV o Excel.\n"); return(invisible(NULL))
  }
  requeridas <- columnas_requeridas[[tabla]]
  validar_columnas(nuevo, requeridas, tabla)
  if (tabla == "jugadores") {
    jugadores <<- nuevo %>% mutate(id_jugador = as.integer(id_jugador),
      edad = as.integer(edad), posicion = as.factor(posicion))
  } else if (tabla == "partidos") {
    partidos <<- nuevo %>% mutate(id_partido = as.integer(id_partido),
      fecha = as.Date(fecha), temporada = as.factor(temporada))
  } else {
    rendimiento <<- nuevo %>% mutate(across(all_of(requeridas), as.integer))
  }
  cat("Tabla", tabla, "cargada. Ejecuta la validacion para revisar relaciones.\n")
}

# Opcion 16: exportar analisis
exportar_analisis <- function() {
  if (!dir.exists("exportaciones")) dir.create("exportaciones")
  resumen_jugadores <- obtener_estadisticas_jugador()
  tabla_equipos <- calcular_tabla_equipos()
  base_completa <- crear_base_completa()

  readr::write_csv(resumen_jugadores,
                   "exportaciones/resumen_jugadores.csv")
  readr::write_csv(tabla_equipos,
                   "exportaciones/tabla_equipos.csv")
  readr::write_csv(base_completa,
                   "exportaciones/base_completa.csv")
  writexl::write_xlsx(
    list(
      jugadores = jugadores,
      partidos = partidos,
      rendimiento = rendimiento,
      resumen_jugadores = resumen_jugadores,
      tabla_equipos = tabla_equipos
    ),
    "exportaciones/analisis_futbol.xlsx"
  )
  cat("Exportaciones guardadas en la carpeta 'exportaciones'.\n")
}

# 6. MENU PRINCIPAL -------------------------------------------
menu_principal <- function() {
  continuar <- TRUE
  while (continuar) {
    cat("\n")
    cat("============================================\n")
    cat("       ANALIZADOR DE ESTADISTICAS DE FUTBOL\n")
    cat("============================================\n")
    cat(" 1. Registrar jugador\n")
    cat(" 2. Registrar estadisticas\n")
    cat(" 3. Mostrar jugadores\n")
    cat(" 4. Buscar jugador\n")
    cat(" 5. Buscar jugadores por equipo\n")
    cat(" 6. Buscar jugadores por posicion\n")
    cat(" 7. Mostrar goleadores\n")
    cat(" 8. Mostrar lideres en asistencias\n")
    cat(" 9. Mostrar jugadores con mas minutos\n")
    cat("10. Comparar jugadores\n")
    cat("11. Comparar equipos\n")
    cat("12. Analizar temporada\n")
    cat("13. Mostrar mejores jugadores\n")
    cat("14. Mostrar estadisticas generales\n")
    cat("15. Cargar datos desde archivo\n")
    cat("16. Exportar analisis\n")
    cat(" 0. Salir\n")
    cat("============================================\n")

    opcion <- trimws(readline("Selecciona una opcion: "))
    if (opcion == "0") {
      cat("Gracias por utilizar el Analizador de Futbol.\n")
      break
    }

    tryCatch({
      switch(opcion,
        "1" = registrar_jugador(),
        "2" = registrar_estadisticas(),
        "3" = mostrar_jugadores(),
        "4" = buscar_jugador(),
        "5" = buscar_por_equipo(),
        "6" = buscar_por_posicion(),
        "7" = mostrar_goleadores(),
        "8" = mostrar_asistentes(),
        "9" = mostrar_minutos(),
        "10" = comparar_jugadores(),
        "11" = comparar_equipos(),
        "12" = analizar_temporada(),
        "13" = mostrar_mejores(),
        "14" = {validar_datos(); estadisticas_generales()},
        "15" = cargar_archivo_externo(),
        "16" = exportar_analisis(),
        {cat("Opcion no valida. Intenta nuevamente.\n")}
      )
    }, error = function(e) {
      cat("Ocurrio un error:", conditionMessage(e), "\n")
    })
    pausa()
  }
}

# 7. INICIO ---------------------------------------------------
cat("\nDatos cargados correctamente.\n")
validar_datos()
menu_principal()

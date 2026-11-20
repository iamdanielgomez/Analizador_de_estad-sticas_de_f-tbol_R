# Analizador de estadísticas de fútbol — RStudio

## Contenido
- `Analizador_Futbol.R`: programa principal con menú de 16 opciones.
- `datos/jugadores_1500.csv`: catálogo de jugadores.
- `datos/partidos_2500.csv`: partidos, marcadores y temporadas.
- `datos/rendimiento_7000.csv`: estadísticas individuales por jugador y partido.

## Cómo ejecutarlo
1. Extrae esta carpeta completa.
2. Abre RStudio.
3. Abre `Analizador_Futbol.R`.
4. Establece como directorio de trabajo la carpeta `Analizador_Futbol_RStudio`:
   - RStudio: Session > Set Working Directory > To Source File Location (si el script está abierto desde la carpeta raíz).
   - O ejecuta `setwd("ruta/a/Analizador_Futbol_RStudio")`.
5. Ejecuta el script completo con Source.

La primera ejecución instala los paquetes que falten: dplyr, tidyr, readr, readxl, writexl y purrr.

## Funcionalidades
1. Registrar jugador
2. Registrar estadísticas para un jugador y partido existente
3. Mostrar jugadores
4. Buscar jugador
5. Buscar jugadores por equipo
6. Buscar jugadores por posición
7. Mostrar goleadores
8. Líderes en asistencias
9. Jugadores con más minutos
10. Comparar jugadores
11. Comparar equipos mediante marcadores de partidos
12. Analizar temporada
13. Mejores jugadores (goles + asistencias)
14. Estadísticas generales
15. Cargar una tabla desde CSV o Excel
16. Exportar análisis a CSV y Excel
0. Salir

## Consideraciones de los datos
- `rendimiento` se relaciona con `jugadores` por `id_jugador` y con `partidos` por `id_partido`.
- Se detectaron 3 combinaciones repetidas de `id_partido` + `id_jugador`. El programa las conserva y avisa antes de agregar otra combinación repetida.
- Hay 16 jugadores sin registros de rendimiento.
- El archivo de jugadores guarda un equipo por jugador, pero no el historial de equipos. Por ello, los resúmenes individuales por equipo usan el equipo actualmente registrado en `jugadores`; no deben interpretarse como historial de equipo en cada partido.
- La tabla de equipos se calcula desde `equipo_local`, `equipo_visitante` y los marcadores, por lo que no depende del equipo actual del jugador.
- La etiqueta `temporada` se toma del CSV tal como está. Conviene validar manualmente la coherencia entre las fechas y las temporadas antes de sacar conclusiones deportivas.
- El ranking de mejores jugadores usa `goles + asistencias`, criterio transparente definido para este proyecto, no una calificación oficial.

## Requisitos técnicos cubiertos
Vectores, factores, listas, data frames, while, for, funciones, apply, lapply, sapply, tapply, purrr::map, dplyr, group_by, summarise, joins, pivot_longer, pivot_wider, CSV y Excel.



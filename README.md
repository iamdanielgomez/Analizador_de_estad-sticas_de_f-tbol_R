
# ⚽ Analizador de Estadísticas de Fútbol

## 📌 Descripción

Sistema desarrollado en R para registrar, consultar y analizar estadísticas de jugadores y equipos de fútbol.

El proyecto permite consultar jugadores, comparar rendimientos, encontrar goleadores, analizar equipos y estudiar diferentes temporadas mediante archivos locales CSV y Excel, sin necesidad de utilizar APIs externas.

## 🎯 Objetivo

Desarrollar un sistema de análisis de estadísticas de fútbol utilizando estructuras de datos, funciones, ciclos y herramientas de manipulación de datos en R.

## ✨ Funcionalidades

El programa cuenta con un menú principal de 16 opciones:

1. Registrar jugador.
2. Registrar estadísticas.
3. Mostrar jugadores.
4. Buscar jugador.
5. Buscar jugadores por equipo.
6. Buscar jugadores por posición.
7. Mostrar goleadores.
8. Mostrar líderes en asistencias.
9. Mostrar jugadores con más minutos.
10. Comparar jugadores.
11. Comparar equipos.
12. Analizar temporada.
13. Mostrar mejores jugadores.
14. Mostrar estadísticas generales.
15. Cargar datos desde archivo.
16. Exportar análisis.
0. Salir.

## 📁 Estructura del proyecto

```text
Analizador_Futbol_RStudio/
│
├── Analizador_Futbol.R
├── README.md
│
├── datos/
│   ├── jugadores_1500.csv
│   ├── partidos_2500.csv
│   └── rendimiento_7000.csv
│
└── exportaciones/
    ├── resumen_jugadores.csv
    ├── tabla_equipos.csv
    ├── base_completa.csv
    └── analisis_futbol.xlsx
```

## 📊 Archivos de datos

El proyecto utiliza tres archivos CSV:

### 1. jugadores_1500.csv

Contiene información general de los jugadores:

- `id_jugador`: Identificador del jugador.
- `jugador`: Nombre del jugador.
- `posicion`: Posición de juego.
- `edad`: Edad.
- `equipo`: Equipo registrado.
- `nacionalidad`: Nacionalidad.

### 2. partidos_2500.csv

Contiene información de los partidos:

- `id_partido`: Identificador del partido.
- `fecha`: Fecha del encuentro.
- `temporada`: Temporada.
- `equipo_local`: Equipo local.
- `equipo_visitante`: Equipo visitante.
- `goles_local`: Goles del equipo local.
- `goles_visitante`: Goles del equipo visitante.

### 3. rendimiento_7000.csv

Contiene las estadísticas individuales de los jugadores:

- `id_registro`: Identificador del registro.
- `id_partido`: Identificador del partido.
- `id_jugador`: Identificador del jugador.
- `minutos`: Minutos jugados.
- `goles`: Goles anotados.
- `asistencias`: Asistencias.
- `tiros`: Tiros realizados.
- `pases_completados`: Pases completados.
- `tarjetas_amarillas`: Tarjetas amarillas.
- `tarjeta_roja`: Tarjetas rojas.

### Relaciones entre archivos

Los archivos se relacionan mediante identificadores:

- `jugadores.id_jugador` con `rendimiento.id_jugador`.
- `partidos.id_partido` con `rendimiento.id_partido`.

Esto permite combinar la información para realizar análisis más completos.

## 🛠️ Tecnologías utilizadas

- **Lenguaje:** R.
- **Entorno de desarrollo:** RStudio.
- **Almacenamiento:** Archivos CSV y Excel.

### Librerías utilizadas

| Librería | Funcionalidad |
|---|---|
| `dplyr` | Filtrar, ordenar, agrupar y resumir datos. |
| `tidyr` | Transformar tablas. |
| `readr` | Importar y exportar archivos CSV. |
| `readxl` | Leer archivos Excel. |
| `writexl` | Exportar archivos Excel. |
| `purrr` | Aplicar funciones mediante `map()`. |

## 📚 Conceptos de R implementados

El proyecto utiliza los siguientes conceptos:

- Vectores.
- Factores.
- Listas.
- Data frames.
- Estructuras de repetición `while` y `for`.
- Funciones.
- `apply()`.
- `lapply()`.
- `sapply()`.
- `tapply()`.
- `purrr` y `map()`.
- `dplyr`.
- `group_by()`.
- `summarise()`.
- Joins (`left_join()` e `inner_join()`).
- `pivot_longer()`.
- `pivot_wider()`.
- Lectura y escritura de archivos CSV y Excel.

## 🚀 Instalación y ejecución

### 1. Descargar el proyecto

Descargar o clonar el repositorio de GitHub.

### 2. Abrir en RStudio

Abrir el archivo `Analizador_Futbol.R` desde RStudio.

### 3. Instalar las librerías

Ejecutar el siguiente código en la consola de RStudio:

```r
install.packages(c(
  "dplyr",
  "tidyr",
  "readr",
  "readxl",
  "writexl",
  "purrr"
))
```

### 4. Configurar el directorio de trabajo

En RStudio seleccionar:

**Session → Set Working Directory → To Source File Location**

Esto permitirá que R encuentre los archivos CSV dentro de la carpeta `datos`.

### 5. Ejecutar el programa

Presionar el botón **Source** en RStudio.

El menú principal aparecerá en la consola y permitirá seleccionar las diferentes funcionalidades escribiendo el número correspondiente.

## 📤 Exportación de resultados

El sistema permite exportar los análisis generados en formatos CSV y Excel.

Los archivos se guardan automáticamente en la carpeta `exportaciones`.

Se generan los siguientes archivos:

- `resumen_jugadores.csv`
- `tabla_equipos.csv`
- `base_completa.csv`
- `analisis_futbol.xlsx`

## ⚠️ Consideraciones

- Los archivos CSV deben conservar sus nombres y estructura de columnas.
- Para registrar estadísticas es necesario que el jugador y el partido existan previamente.
- El sistema comprueba las relaciones entre jugadores, partidos y estadísticas.
- Los análisis individuales por equipo utilizan el equipo registrado en la tabla de jugadores.
- La comparación de equipos utiliza los resultados registrados en los partidos.
- El ranking de mejores jugadores utiliza la suma de goles y asistencias.
- Los cambios realizados durante la ejecución deben exportarse para conservarlos.

## 🎓 Objetivo académico

Este proyecto busca aplicar los conocimientos de programación y análisis de datos en R mediante un caso práctico relacionado con el fútbol.

Permite trabajar con estructuras de datos, programación funcional, ciclos, funciones, manipulación de tablas, agrupaciones, resúmenes y exportación de información.

## 👨‍💻 Autor

**[Tu nombre aquí]**

Proyecto académico desarrollado en RStudio.

---

# 🌿 Herbario Lógico: Sistema Experto Botánico y Evaluación Ambiental

Sistema experto desarrollado en **SWI-Prolog** e integrado con una interfaz web moderna en **Python (Streamlit)**, diseñado como práctica integradora para la unidad de aprendizaje **Paradigmas de Programación** en la **Escuela Superior de Cómputo (ESCOM - IPN)**.

---

##  Autores
* **Nolasco Quezada Neshmi Natalia y Santiago Antonio Karla Yamina** — ESCOM IPN
---
##  Enlace de la Aplicación en Producción
Puedes probar el sistema experto funcionando en la nube a través del siguiente enlace:
👉 [Herbario Lógico - Web App](https://herbario-logico.onrender.com)
---

##  Características del Sistema Experto (Prolog)
El motor lógico (`plantas.pl`) implementa conceptos avanzados de programación declarativa:
1. **Hechos y Atributos:** 20 especies vegetales con datos taxonómicos, requerimientos de luz, humedad, tamaño y formas de vida.
2. **Motor de Recomendación con Puntaje Ponderado:** Utiliza escalas ordinales y funciones de distancia numérica para evaluar la viabilidad ambiental (Luz 40pts, Humedad 30pts, Follaje 20pts, Tamaño 10pts).
3. **Seguridad con Negación por Fallo (`\+`):** Filtra automáticamente especies tóxicas o reguladas para entornos domésticos.
4. **Redes de Compatibilidad y Recursividad:** Implementa búsqueda en profundidad con control de visitados (`camino/3`) para conectar plantas complementarias.
5. **Diagnóstico Fitosanitario Probabilístico:** Calcula el porcentaje de confianza de una patología aplicando el **Índice de Jaccard** entre los síntomas observados y los teóricos de cada causa.

---

## ⚙️ Instrucciones de Instalación y Ejecución Local

### Prerrequisitos
* Python 3.10 o superior instalado.
* SWI-Prolog instalado y configurado en el sistema.

### Pasos de ejecución
1. Clona este repositorio o descarga los archivos en una carpeta local:
   ```bash
   git clone [https://github.com/tu-usuario/herbario-logico.git](https://github.com/tu-usuario/herbario-logico.git)
   cd herbario-logico

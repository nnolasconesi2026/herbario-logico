FROM python:3.10-slim

# Instalar SWI-Prolog y dependencias del sistema
RUN apt-get update && apt-get install -y \
    swi-prolog \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo en el contenedor
WORKDIR /app

# Copiar e instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código del proyecto (app.py, plantas.pl, etc.)
COPY . .

# Exponer el puerto predeterminado de Streamlit
EXPOSE 8501

# Comando para arrancar la aplicación web
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
#  Agenda Móvil - Frontend (Flutter)

Aplicación móvil nativa diseñada para la gestión rápida de recordatorios, conectada al backend de Laravel.

##  Requisitos de Sistema
* **Flutter SDK**: Versión estable.
* **Android Studio**: Con el componente "Android SDK Command-line Tools" instalado.
* **Dispositivo**: Emulador de Android o Celular físico con Depuración USB activa.

##  Instalación y Configuración

**1. Clonar y descargar paquetes:**
```bash
git clone https://github.com/PaoAlantara/agenda-m-vil.git
cd agenda_movil
flutter pub get
2. Vincular con el Backend:
Abre lib/main.dart y localiza la variable apiUrl. Sustituye la dirección por la IP de tu servidor:

Emulador: http://10.0.2.2:8000/api/recordatorios

Celular Físico: http://tu_ip_local:8000/api/recordatorios

3. Diagnóstico de Entorno:
Verifica que todo esté listo para compilar:

Bash
flutter doctor
  Ejecución
Con el servidor Laravel encendido, lanza la aplicación:

Bash
flutter run

 Dependencias Utilizadas
http: Para la comunicación con la API REST.

material: Para el diseño de interfaz nativo.

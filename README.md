# UrbanReport
Sistema de Reporte Ciudadano con Geolocalización desarrollado en Flutter.

# Descripcion
UrbanReport es una aplicacion movil que permite a los ciudadanos reportar problemas urbanos en su comunidad, tales como baches, luminarias danadas, acumulacion de basura, alcantarillas obstruidas, entre otros. La aplicacion utiliza Supabase como backend integral y OpenStreetMap para la visualizacion geografica de los reportes.

# Tecnologias
Flutter - Framework de desarrollo movil

Supabase - Backend (Auth, Database, Storage)

OpenStreetMap - Mapas interactivos con flutter_map

Geolocator - Ubicacion del dispositivo

# Estructura del Proyecto
lib/
├── auth/                    # Autenticacion (login, registro, recuperar contrasena)
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   └── auth_service.dart
├── dashboard/               # Pantalla principal con navegacion
│   └── dashboard_screen.dart
├── reports/                 # CRUD de reportes
│   ├── create_report_screen.dart
│   ├── report_list_screen.dart
│   └── report_detail_screen.dart
├── map/                     # Mapas
│   ├── map_general_screen.dart
│   └── map_picker_screen.dart
├── profile/                 # Perfil de usuario
│   └── profile_screen.dart
├── splash/                  # Pantalla de carga inicial
│   └── splash_screen.dart
├── services/                # Servicios
│   ├── report_service.dart
│   └── storage_service.dart
├── models/                  # Modelos de datos
│   └── reporte.dart
└── main.dart
Dependencias
dependencies:
  supabase_flutter: ^2.3.4    # Conexion a Supabase
  flutter_dotenv: ^5.0.0      # Variables de entorno
  flutter_map: ^6.1.0         # Mapas
  latlong2: ^0.9.0            # Coordenadas para flutter_map
  geolocator: ^10.1.0         # Ubicacion del dispositivo
  image_picker: ^1.0.4        # Seleccionar imagenes de camara o galeria

# Configuracion
Crear archivo .env en la raiz del proyecto:
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_public_key_aqui

Configurar Supabase:

- Crear tabla reportes con los campos requeridos

- Crear tabla profiles para datos de usuario

- Crear bucket imagenes en Storage

#### Es importante configurar politicas RLS

# Funcionalidades
1. Autenticacion
- Registro de usuario con nombre, telefono, email y contraseña
- Confirmacion de cuenta por correo electronico
- Inicio de sesión
- Recuperación de contraseña
Cierre de sesion

2. Reportes
Crear reporte con titulo, descripcion, categoria, foto y ubicacion

Listar reportes del usuario

Ver detalle del reporte

Editar reporte

Eliminar reporte

3. Mapa
Visualizacion de todos los reportes no resueltos

Marcadores diferenciados por categoria

Detalle del reporte al tocar marcador

Seleccion de ubicacion al crear reporte

4. Almacenamiento
Captura de imagen desde camara

Seleccion de imagen desde galeria

Subida a Supabase Storage

Visualizacion de imagenes en reportes

## Pantallas
Splash Screen - Pantalla de carga inicial animada

Login - Inicio de sesion

Registro - Creacion de cuenta

Recuperar Contrasena - Solicitud de restablecimiento

Dashboard - Lista de reportes del usuario

Mapa General - Visualizacion de todos los reportes

Crear Reporte - Formulario con camara y mapa

Detalle de Reporte - Vista completa, editar y eliminar

Perfil de Usuario - Informacion y cierre de sesion

## Final: Pasos para compilacion
flutter pub get
flutter build apk --release
# Incauca Labs

Proyecto Flutter para Incauca.

## Configuración de Entornos

Este proyecto utiliza el **Strategy Pattern** para manejar diferentes entornos (Local y Cloud/Azure). La configuración se maneja a través de variables de entorno pasadas en tiempo de compilación.

### Pasos para configurar:

1. Copia el archivo de ejemplo:
   ```bash
   cp env.example .env
   ```
2. Edita el archivo `.env` con los valores correspondientes a tu entorno.
3. Asegúrate de configurar la variable `ENVIRONMENT` como `local` o `cloud`.

### Variables Requeridas

Dependiendo del valor de `ENVIRONMENT`, estas son las variables obligatorias:

#### Común
- `ENVIRONMENT`: (local | cloud) - Define qué estrategia de configuración usar.

#### Local (`ENVIRONMENT=local`)
- `LOCAL_BASE_URL`: IP y puerto del servidor local (ej: `10.0.2.2:8000`).
- `LOCAL_UPLOAD_ENDPOINT`: Ruta del endpoint de subida.

#### Cloud (`ENVIRONMENT=cloud`)
- `AZURE_API_BASE_URL`: URL base de la Function App en Azure.
- `AZURE_NEGOTIATE_ENDPOINT`: Endpoint para SignalR.
- `AZURE_GENERATE_UPLOAD_URL_ENDPOINT`: Endpoint para generar SAS URLs.
- `COSMOS_DB_*`: Credenciales de acceso a la base de datos.
- `STORAGE_*`: Credenciales del Storage Account.

> [!TIP]
> Consulta el archivo [env.example](env.example) para ver la lista completa de variables y valores de ejemplo.

## Cómo Ejecutar

Para ejecutar el proyecto cargando la configuración desde el archivo `.env`, utiliza el siguiente comando:

### En Desarrollo (Debug)
```bash
flutter run --dart-define-from-file=.env
```

### Generar APK/Build
```bash
flutter build apk --dart-define-from-file=.env
```

## Estructura de Configuración

La lógica de selección de entorno se encuentra en `lib/core/config.dart`, la cual inicializa la estrategia correcta basándose en la variable `ENVIRONMENT`:

- **LocalConfigStrategy**: Utiliza `LOCAL_BASE_URL`.
- **CloudConfigStrategy**: Utiliza las variables de Azure (`AZURE_API_BASE_URL`, etc.).

## Testing

### Ejecutar pruebas unitarias
```bash
flutter test
```

### Correr test con informe de cobertura
```bash
flutter test --coverage
```

## Generar informe detallado (después de correr test con cobertura)

Para un informe limpio que ignore archivos de dominio e interfaces:

```bash
# 1. Asegúrate de haber corrido los tests con cobertura primero
flutter test --coverage

# 2. Filtrar archivos innecesarios (dominio, firebase_options, etc.)
dart scripts/filter_coverage.dart

# 3. Generar el reporte en consola
dart pub global run test_cov_console -i
```

### Ejecutar pruebas de integración
Estas pruebas cubren las fronteras entre BLoCs, Repositorios y Datasources.
```bash
flutter test test/integration
```

### Ejecutar pruebas End-to-End (E2E)
Estas pruebas validan el flujo completo desde la interfaz de usuario hasta el Backend (integración real).

#### Opción A: Automatizado (Recomendado para Local)
Existe un script de PowerShell que se encarga de preparar el backend (seed), levantarlo en el puerto 8001 y ejecutar los tests de Flutter automáticamente.

> [!IMPORTANT]
> Debes tener un emulador de Android abierto o un dispositivo físico conectado antes de ejecutar el script.

```powershell
./run_e2e.ps1
```

#### Opción B: Manual
Si ya tienes el backend corriendo manualmente en otro terminal, puedes ejecutar los tests directamente:

**Android / iOS:**
```bash
flutter test integration_test/app_e2e_test.dart --dart-define-from-file=.env
```

**Web (Chrome):**
```bash
flutter test integration_test/app_e2e_test.dart -d chrome --dart-define-from-file=.env
```

> [!TIP]
> Puedes usar la bandera `--dart-define-from-file=.env.test` si deseas usar credenciales o URLs específicas para el entorno de pruebas.

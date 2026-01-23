# 🎨 Paleta de Colores - URBÁN REPORT

## Diseño Formal y Académico con Enfoque Profesional

---

## 📋 Colores Principales

### 1. **Color Primario** - Azul Oscuro Profesional
- **HEX:** `#1e3a8a`
- **RGB:** `(30, 58, 138)`
- **Uso:** Botones principales, acentos, títulos, bordes activos
- **Aplicación:** Botones de acción, AppBar, texto principal

### 2. **Color Secundario** - Azul Corporativo
- **HEX:** `#3b82f6`
- **RGB:** `(59, 130, 246)`
- **Uso:** Iconos, bordes activos, campos de texto enfocados
- **Aplicación:** Prefijos de inputs, estados hover

### 3. **Color Terciario** - Azul Casi Negro
- **HEX:** `#0f172a`
- **RGB:** `(15, 23, 42)`
- **Uso:** Fondos de gradiente superior, texto oscuro
- **Aplicación:** Background principal del auth, sombras

### 4. **Color de Acento** - Azul Claro
- **HEX:** `#60a5fa`
- **RGB:** `(96, 165, 250)`
- **Uso:** Destacados suaves, estados secundarios
- **Aplicación:** Efectos visuales adicionales

---

## ✅ Colores de Validación

### 5. **Color de Éxito** - Verde Esmeralda
- **HEX:** `#10b981`
- **RGB:** `(16, 185, 129)`
- **Uso:** Indicadores de contraseña fuerte, validaciones exitosas
- **Aplicación:** Fuerza de contraseña (nivel máximo)

### 6. **Color de Advertencia** - Ámbar
- **HEX:** `#f59e0b`
- **RGB:** `(245, 158, 11)`
- **Uso:** Indicador de contraseña media
- **Aplicación:** Fuerza de contraseña (nivel intermedio)

### 7. **Color de Error** - Rojo Profesional
- **HEX:** `#dc2626`
- **RGB:** `(220, 38, 38)`
- **Uso:** Mensajes de error, validaciones fallidas, advertencias
- **Aplicación:** SnackBars de error, campos inválidos

---

## 🎯 Colores Neutrales

### 8. **Fondo Card** - Blanco Puro
- **HEX:** `#ffffff`
- **RGB:** `(255, 255, 255)`
- **Uso:** Cards, campos de entrada
- **Aplicación:** Contenedores principales

### 9. **Fondo Input** - Azul Muy Claro
- **HEX:** `#f8fafc`
- **RGB:** `(248, 250, 252)`
- **Uso:** Fondo de inputs y campos de texto
- **Aplicación:** TextFields, forms

### 10. **Bordes Deshabilitados** - Gris Profundo
- **HEX:** `#94a3b8`
- **RGB:** `(148, 163, 184)`
- **Uso:** Estados deshabilitados, bordes inactivos
- **Aplicación:** Botones deshabilitados

### 11. **Bordes Neutros** - Gris Claro
- **HEX:** `#e2e8f0`
- **RGB:** `(226, 232, 240)`
- **Uso:** Bordes de inputs, separadores
- **Aplicación:** Líneas divisorias, bordes sutiles

---

## 🌐 Configuración para Supabase

### Correos - Colores Recomendados

```html
<!-- Para Encabezados y Títulos -->
<h1 style="color: #1e3a8a; font-size: 28px; font-weight: bold;">
  URBÁN REPORT
</h1>

<!-- Para Botones en Emails -->
<a href="[link]" style="
  background-color: #1e3a8a;
  color: #ffffff;
  padding: 12px 24px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: bold;
  display: inline-block;
">
  Confirmar Email / Resetear Contraseña / Aceptar
</a>

<!-- Para Información Importante -->
<p style="color: #1e3a8a; font-weight: bold;">
  Información importante
</p>

<!-- Para Advertencias -->
<p style="color: #dc2626;">
  ⚠️ Advertencia o error crítico
</p>

<!-- Para Éxito -->
<p style="color: #10b981;">
  ✅ Operación exitosa
</p>
```

---

## 📱 Resumen de Aplicación en Flutter

```dart
// Importar colores como constantes
const Color primaryColor = Color(0xFF1e3a8a);          // Azul Oscuro
const Color secondaryColor = Color(0xFF3b82f6);        // Azul Corporativo
const Color tertiaryColor = Color(0xFF0f172a);         // Azul Casi Negro
const Color accentColor = Color(0xFF60a5fa);           // Azul Claro
const Color successColor = Color(0xFF10b981);          // Verde Éxito
const Color warningColor = Color(0xFFf59e0b);          // Ámbar
const Color errorColor = Color(0xFFdc2626);            // Rojo Error
const Color neutralGray = Color(0xFF94a3b8);           // Gris Deshabilitado
const Color borderGray = Color(0xFFe2e8f0);            // Gris Bordes
const Color inputBackground = Color(0xFFF8FAFC);       // Fondo Input

// Gradiente para AuthLayout
LinearGradient authGradient = LinearGradient(
  colors: [
    Color(0xFF0f172a),
    Color(0xFF1e3a8a),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## 🎨 Paleta Visual

```
┌─────────────────────────────────────────────────────┐
│                  URBÁN REPORT COLORS                │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ■ #1e3a8a  ← Primario (Botones, Acentos)        │
│  ■ #3b82f6  ← Secundario (Iconos, Bordes)        │
│  ■ #0f172a  ← Terciario (Fondos Gradiente)       │
│  ■ #60a5fa  ← Acento (Destacados)                │
│  ■ #10b981  ← Éxito (Verde)                      │
│  ■ #f59e0b  ← Advertencia (Ámbar)                │
│  ■ #dc2626  ← Error (Rojo)                       │
│                                                     │
├─────────────────────────────────────────────────────┤
│  Enfoque: Formal, Académico, Profesional          │
│  Estilo: Moderno con toque institucional          │
│  Mood: Confianza, Seguridad, Profesionalismo     │
└─────────────────────────────────────────────────────┘
```

---

## ✨ Características del Diseño

✅ **Colores Accesibles** - Contraste adecuado (WCAG AA)
✅ **Paleta Coherente** - Colores que trabajan juntos armoniosamente
✅ **Formal y Académico** - Adecuado para reportes urbanos
✅ **Profesional** - Inspira confianza y seguridad
✅ **Moderno** - Gradientes y sombras sutiles
✅ **Consistencia** - Los mismos colores en toda la app

---

**Última actualización:** 22 Enero 2026
**Versión:** 1.0

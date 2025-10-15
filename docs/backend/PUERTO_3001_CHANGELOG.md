# Cambio de Puerto del Backend - De 3000 a 3001

## 📅 Fecha

**Octubre 10, 2025**

## 🎯 Objetivo

Configurar el backend de Creapolis para que funcione **siempre en el puerto 3001** en todos los entornos, evitando conflictos con otras aplicaciones que comúnmente usan el puerto 3000.

## ✅ Cambios Realizados

### 1. Archivos de Configuración de Variables de Entorno

- ✅ `backend/.env` - PORT cambiado de 3000 a 3001
- ✅ `backend/.env.example` - PORT cambiado de 3000 a 3001
- ✅ `.env.docker` - BACKEND_PORT cambiado de 3000 a 3001
- ✅ Actualización de GOOGLE_REDIRECT_URI en todos los archivos

### 2. Código del Servidor

- ✅ `backend/src/server.js` - Puerto por defecto cambiado a 3001

### 3. Configuración Docker

- ✅ `backend/Dockerfile` - EXPOSE cambiado a 3001
- ✅ `backend/Dockerfile.dev` - EXPOSE cambiado a 3001
- ✅ `docker-compose.yml` - Mapeo de puertos actualizado a 3001
- ✅ `docker-compose.dev.yml` - Configuración de desarrollo actualizada
- ✅ Health checks actualizados para usar puerto 3001

### 4. Documentación Actualizada

- ✅ `backend/API_DOCUMENTATION.md` - Base URL actualizada
- ✅ `backend/API_DOCS.md` - URLs de ejemplo actualizadas
- ✅ `backend/INSTALLATION.md` - Configuración de puerto actualizada
- ✅ `backend/README.md` - Todas las referencias actualizadas
- ✅ `README.md` - URLs principales actualizadas
- ✅ `TEST_RESULTS.md` - URLs de testing actualizadas

### 5. Frontend Flutter

- ✅ `creapolis_app/lib/core/constants/api_constants.dart` - Ya estaba configurado para 3001
- ✅ Documentación de Flutter actualizada

### 6. Nueva Documentación

- ✅ `backend/PORT_CONFIGURATION.md` - Guía completa de configuración de puerto

## 🔧 Archivos Afectados

```
backend/
├── .env                        ✅ PORT=3001
├── .env.example               ✅ PORT=3001
├── Dockerfile                 ✅ EXPOSE 3001
├── Dockerfile.dev             ✅ EXPOSE 3001
├── src/server.js              ✅ Default port 3001
├── README.md                  ✅ URLs actualizadas
├── API_DOCUMENTATION.md       ✅ Base URL actualizada
├── API_DOCS.md               ✅ URLs actualizadas
├── INSTALLATION.md           ✅ PORT actualizado
└── PORT_CONFIGURATION.md     ✅ Nueva documentación

.env.docker                    ✅ BACKEND_PORT=3001
docker-compose.yml             ✅ Puerto mapeado a 3001
docker-compose.dev.yml         ✅ Puerto de desarrollo 3001
README.md                      ✅ URLs principales actualizadas
TEST_RESULTS.md               ✅ URLs de testing actualizadas

creapolis_app/
├── lib/core/constants/api_constants.dart  ✅ Ya configurado
├── TAREA_4.1_COMPLETADA.md              ✅ URLs actualizadas
└── FLUTTER_ROADMAP.md                   ✅ URLs actualizadas
```

## 🌐 URLs Actualizadas

| Servicio              | URL Anterior                                             | URL Nueva                                                |
| --------------------- | -------------------------------------------------------- | -------------------------------------------------------- |
| API Base              | `http://localhost:3000/api`                              | `http://localhost:3001/api`                              |
| Health Check          | `http://localhost:3000/api/health`                       | `http://localhost:3001/api/health`                       |
| Google OAuth Callback | `http://localhost:3000/api/integrations/google/callback` | `http://localhost:3001/api/integrations/google/callback` |

## 🚀 Verificación de Cambios

### Desarrollo Local

```bash
# Iniciar backend
cd backend
npm run dev
# Verificar que corre en puerto 3001
curl http://localhost:3001/api/health
```

### Docker Desarrollo

```bash
docker-compose -f docker-compose.dev.yml up
curl http://localhost:3001/api/health
```

### Docker Producción

```bash
docker-compose up
curl http://localhost:3001/api/health
```

## 📋 Tareas Post-Cambio

### ✅ Completado

- [x] Actualizar todas las configuraciones de backend
- [x] Actualizar documentación técnica
- [x] Verificar configuración de Flutter
- [x] Actualizar Docker y docker-compose
- [x] Crear documentación específica del puerto

### 🔄 Para el Equipo

- [ ] Actualizar configuraciones locales de desarrollo
- [ ] Actualizar collections de Postman/Insomnia
- [ ] Verificar integración con Google OAuth
- [ ] Actualizar scripts de testing automatizado
- [ ] Notificar a stakeholders sobre el cambio de URL

## ⚠️ Notas Importantes

1. **Compatibilidad**: El puerto anterior (3000) ya no estará disponible
2. **Google OAuth**: Verificar que las URLs de callback estén actualizadas en Google Cloud Console
3. **CORS**: Configuración CORS mantenida para puertos de frontend (5173, 8080)
4. **Docker**: Los contenedores exponen internamente el puerto 3001
5. **Testing**: Todos los health checks actualizados

## 📞 Soporte

Si encuentras problemas relacionados con este cambio:

1. Consulta `backend/PORT_CONFIGURATION.md` para troubleshooting
2. Verifica que no haya otros servicios usando el puerto 3001
3. Reinicia completamente el backend después del cambio
4. Verifica las variables de entorno en tu configuración local

---

**Realizado por**: Sistema de desarrollo Creapolis  
**Revisado por**: Equipo de desarrollo  
**Estado**: ✅ Completado  
**Impacto**: Cambio de configuración - Sin pérdida de funcionalidad

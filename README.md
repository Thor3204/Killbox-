# KILLBOX

## Blueprint maestro — Juego V1

KILLBOX es un juego móvil multijugador horizontal de acción, supervivencia, alianzas y traición. La prioridad de V1 es crear una experiencia divertida, fácil de aprender y visualmente atractiva antes de integrar billeteras, promotores, recargas o recompensas externas.

## Concepto

- Género: supervivencia + acción + interacción social.
- Cámara: vista superior 2D/2.5D.
- Orientación: horizontal (landscape).
- Capacidad objetivo: hasta 100 jugadores por evento.
- Objetivo: ser el último superviviente.
- Todos los personajes pueden combatir y eliminar.
- Los personajes tienen roles/profesiones que cambian su estilo de juego, no su capacidad de matar.
- Los jugadores pueden formar alianzas y bandas.
- Las alianzas pueden romperse en cualquier momento.
- Las eliminaciones generan una recompensa conceptual de 90 BOX; la economía real se implementará en una fase posterior.
- Las victorias se representan mediante estrellas ⭐ de reputación.

## Ciclo principal

1. Entrar al evento.
2. Aparecer en el mapa.
3. Fase de preparación/escondite.
4. Fase de caza/combate.
5. Resolver eventos del mapa.
6. Crear, aceptar o abandonar alianzas.
7. Eliminar rivales.
8. Sobrevivir.
9. Declarar ganador al último superviviente.
10. Otorgar ⭐ por victoria.
11. Mostrar resumen y regresar al lobby.

## Principios de diseño

- Fácil de entender en menos de un minuto.
- Difícil de dominar completamente.
- Partidas dinámicas y diferentes entre sí.
- UI de videojuego, no de aplicación financiera.
- Gráficos estilizados y ligeros.
- Sin sangre ni gore explícito.
- Servidor autoritativo para reglas competitivas.
- La economía BOX queda desacoplada del cliente del juego.

## V1 no incluye

- App de promotores.
- App administrativa.
- Recargas.
- Retiros.
- Gift cards.
- Catálogo de recompensas.
- Transferencias libres de BOX entre jugadores.

Estas funciones se documentarán después de validar el juego base.

## Tecnología objetivo

- Motor: Godot.
- Lenguaje principal: GDScript.
- Plataforma inicial: Android.
- Orientación: landscape.
- Backend multijugador: capa independiente del cliente; se decidirá durante la implementación online.

## Estado actual del código

Ya está implementado el **Prototipo V1 offline contra bots** (Fase 1-2 del roadmap): movimiento, cámara, colisiones, ataque, vida, eliminación, ciclos de 30s (preparación/caza), un personaje jugable de los 5 del roster, mapa Nova City, alianzas/bandas con reparto de BOX, eventos de mapa (zona peligrosa, apagón, suministro, alarma) y pantallas de login/lobby/partida/resultado. Todo el juego está armado 100% por código GDScript (sin escenas .tscn adicionales), para que sea fácil de mantener y diffear desde GitHub.

Lo que falta para Fase 3 (multijugador real en red, hasta 100 jugadores, servidor autoritativo) es un backend dedicado — no es algo que se resuelva solo con el cliente. El código ya está separado en `MatchManager`/`AllianceManager` pensando en esa migración (ver `docs/ARCHITECTURE.md`).

### Estructura

```
autoload/          # Singletons: RemoteConfig, Game (perfil), CharacterData (roster)
scripts/           # Player, BotBrain, MatchManager, AllianceManager, NovaCity (mapa), HUD, pantallas, Main
data/              # game_config.json (balance editable en vivo)
scenes/Main.tscn   # única escena .tscn del proyecto (punto de entrada)
export_presets.cfg # preset de exportación Android
```

## Cómo compilar el APK

### Automático (GitHub Actions)

El repo está pensado para compilar solo en cada push a `main` vía `.github/workflows/build-apk.yml`, que descarga Godot 4.7.2, genera un keystore de debug, exporta el proyecto a APK y lo publica como artifact del run **y** como asset de un GitHub Release (`build-N`).

> **Nota:** el conector que uso para escribir en este repo no tiene permiso para crear archivos dentro de `.github/workflows/` (GitHub restringe eso a un scope aparte por seguridad). Te paso el archivo completo en el chat — copialo a `.github/workflows/build-apk.yml` desde la web de GitHub (Add file → Create new file) o con `git push` local, y desde ese momento cada push compila solo.

Una vez que el workflow esté en el repo: pestaña **Actions** → el run más reciente → **Artifacts** (o pestaña **Releases**) para bajar el APK. También se puede disparar a mano desde **Actions → Build KILLBOX APK → Run workflow**.

### Local (si tenés Godot instalado)

```
godot --headless --export-debug "Android" build/killbox.apk
```

Requiere Android SDK y un keystore de debug configurados en Editor Settings → Export → Android.

## Actualización en tiempo real (sin recompilar)

`data/game_config.json` se lee en vivo desde GitHub (`raw.githubusercontent.com`) al abrir la app y cada ~90s mientras estás en el lobby (`autoload/RemoteConfig.gd`). Ahí se puede ajustar sin tocar código ni recompilar:

- `kill_reward_box` — recompensa base por kill.
- `cycle_prep_seconds` / `cycle_hunt_seconds` — duración de cada fase del ciclo.
- `bot_count` — cantidad de bots por partida.
- `map_events` — qué eventos de mapa pueden dispararse.
- `characters.<id>.*` — cooldowns y stats por personaje.

Los cambios de **balance/config** (los campos de arriba) se aplican solos, sin reinstalar nada.

Los cambios de **lógica/código** (una habilidad nueva, un mapa nuevo, un bug fix) sí necesitan un APK nuevo — pero como la compilación ya está automatizada, alcanza con hacer push y bajar el último build. Si subís el número en `latest_app_version` / `min_app_version` de `game_config.json`, el lobby le muestra al jugador un aviso de que hay una versión nueva disponible.

## Documentación

- [Reglas del juego](docs/RULES.md)
- [Gameplay](docs/GAMEPLAY.md)
- [Personajes y roles](docs/CHARACTERS.md)
- [Alianzas y traición](docs/ALLIANCES.md)
- [Mapa y mundo](docs/WORLD.md)
- [UI/UX](docs/UI-UX.md)
- [Arquitectura técnica](docs/ARCHITECTURE.md)
- [Modelo BOX](docs/BOX.md)
- [Roadmap](docs/ROADMAP.md)
- [Criterios de calidad](docs/DESIGN-QA.md)

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

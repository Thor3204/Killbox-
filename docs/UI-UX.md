# KILLBOX — UI/UX Blueprint

## Principio

La app del jugador debe sentirse como un videojuego, no como un panel administrativo.

## Pantallas V1

Solo se necesitan tres superficies principales:

1. Login/Registro.
2. Lobby.
3. Juego.

El resultado de partida puede aparecer como overlay y devolver al lobby.

## Login/Registro

- Logo KILLBOX.
- Usuario.
- Contraseña.
- Registro.
- Inicio de sesión.
- Recuperación de acceso en fase posterior.

Diseño limpio, rápido y sin formularios innecesarios.

## Lobby

El lobby concentra la información importante:

- personaje actual;
- nombre del jugador;
- estrellas ⭐;
- botón JUGAR;
- perfil;
- personajes;
- ajustes;
- información del próximo evento cuando corresponda.

No debe tener decenas de botones.

## Juego

Orientación obligatoria: landscape.

### HUD

Arriba:

- vida;
- jugadores vivos;
- ciclo/temporizador;
- estado de alianza cuando sea relevante.

Abajo izquierda:

- joystick virtual.

Abajo derecha:

- ataque;
- habilidad;
- interacción.

Zona central:

- mapa y personajes.

## Alianza

La interacción debe ser contextual y rápida.

Al tocar a un jugador o seleccionarlo:

- Proponer alianza.
- Ver estado de alianza.
- Abandonar alianza.

Las acciones peligrosas deben pedir confirmación cuando puedan causar pérdida accidental de una alianza.

## Final de partida

Overlay de victoria/derrota:

- ganador;
- estrellas obtenidas;
- kills;
- supervivencia;
- resumen de alianza/banda;
- botón CONTINUAR.

## Estilo visual

Dirección base:

- urbano caricaturesco;
- apocalipsis ligero;
- colores con alto contraste;
- personajes expresivos;
- iconografía grande;
- textos cortos;
- sombras y profundidad suaves.

## Rendimiento UX

- Objetivo de respuesta inmediata al tocar controles.
- Evitar animaciones largas que bloqueen el juego.
- UI adaptada a diferentes resoluciones landscape.
- Elementos táctiles suficientemente grandes para móvil.

# KILLBOX — Arquitectura técnica V1

## Cliente

Motor recomendado: Godot.

Lenguaje principal: GDScript.

Plataforma inicial: Android.

Orientación: landscape.

## Separación

El cliente contiene:

- renderizado;
- input;
- animaciones;
- UI;
- efectos;
- presentación de estado recibido del servidor.

El servidor controla:

- estado de partida;
- jugadores;
- posiciones válidas;
- daño;
- kills;
- alianzas;
- composición de bandas;
- recompensas;
- victoria;
- anti-cheat;
- resultado final.

## Principio autoritativo

Nunca confiar en el cliente para determinar una kill o una recompensa.

Flujo conceptual:

CLIENTE → evento de ataque → SERVIDOR → validación → daño → eliminación → reparto → broadcast.

## Escalabilidad

La capacidad objetivo es 100 jugadores por partida/evento.

El primer prototipo no debe intentar resolver 100 jugadores de inmediato.

Orden de pruebas:

1. local/2 jugadores;
2. 8 jugadores;
3. 20 jugadores;
4. 50 jugadores;
5. 100 jugadores.

## Rendimiento

Objetivos:

- paquetes de red pequeños;
- sincronización de estado eficiente;
- interpolación de movimiento;
- pooling de efectos y proyectiles;
- pocos objetos físicos simultáneos;
- assets comprimidos y reutilizables.

## Economía desacoplada

BOX aparece en el blueprint para definir la lógica de recompensa, pero la primera versión jugable no debe depender de un sistema de recarga, promotores o gift cards.

La economía será una capa posterior y no debe modificar la lógica fundamental del combate.

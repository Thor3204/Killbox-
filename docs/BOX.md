# KILLBOX — Modelo conceptual BOX

## Estado

Este documento define únicamente la mecánica conceptual para que el gameplay pueda diseñarse correctamente. No implementa pagos, recargas, retiros ni gift cards.

## Valor base

Entrada conceptual: 100 BOX.

Comisión conceptual: 10%.

Recompensa base por eliminación: 90 BOX.

## Reparto

La recompensa de una kill se divide entre los integrantes válidos de la alianza del killer en el momento de la eliminación.

Fórmula:

90 BOX / número de integrantes válidos.

## Reglas técnicas

- La recompensa se calcula una sola vez por kill.
- El servidor genera un identificador único de transacción.
- No se puede acreditar dos veces la misma eliminación.
- Cambios posteriores de alianza no alteran el reparto histórico.
- La economía real se implementará después del MVP.

## Fuera de V1

- compra de BOX;
- recarga de promotores;
- solicitudes de retiro;
- gift cards;
- conversiones externas;
- catálogo de recompensas.

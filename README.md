# Power Settings Manager

Gestor de opciones de energía para Windows que permite mostrar y ocultar configuraciones avanzadas del panel de control de energía.

## Requisitos

- Windows
- PowerShell con privilegios de Administrador

## Uso

Ejecutar como Administrador:

```powershell
.\PowerManager.ps1
```

## Funciones

1. **Desbloquear todas las opciones** - Revela todas las opciones de energía ocultas en Windows
2. **Restaurar a default** - Oculta todas las opciones y vuelve al estado predeterminado
3. **Seleccionar categorías** - Muestra u oculta opciones por categoría específica

## Categorías disponibles

- Procesador
- Disco Duro
- Pantalla
- Suspensión
- Botones de Energía
- USB
- Batería
- PCI Express

## Nota

Se recomienda reiniciar el sistema después de realizar cambios para aplicarlos correctamente.

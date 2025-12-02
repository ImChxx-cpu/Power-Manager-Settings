# ========================================================================
# POWER SETTINGS MANAGER - Gestor de Opciones de Energia
# ========================================================================
# Script todo-en-uno para gestionar opciones de energia en Windows
# Ejecutar como Administrador
# Autor: ImChxx-cpu
# ========================================================================

#Requires -RunAsAdministrator

# ========================================================================
# CONSTANTES Y VARIABLES GLOBALES
# ========================================================================

$script:PowerSettingsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings"

$script:Categorias = @{
    "Procesador" = "54533251-82be-4824-96c1-47b60b740d00"
    "Disco Duro" = "0012ce2d-ce84-4696-bf6f-2f89b215f26a"
    "Pantalla" = "7516b95f-f776-4464-8c53-06167f40cc99"
    "Suspension" = "238c9fa8-0aad-41ed-83f4-97be242c8f20"
    "Botones de Energia" = "4f971e89-eebd-4455-a8de-9e59040e7347"
    "USB" = "2a737441-1930-4859-8476-1d7d0e80b06e"
    "Bateria" = "e73a048d-bf27-4f12-9731-6b2b8b301c63"
    "PCI Express" = "501a4d13-42af-4429-9fd1-a8218084f794"
}

# ========================================================================
# FUNCIONES PRINCIPALES
# ========================================================================

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "  POWER SETTINGS MANAGER - Gestor Energia " -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Unlock-AllOptions {
    Show-Header
    Write-Host "DESBLOQUEAR TODAS LAS OPCIONES" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta accion revelara TODAS las opciones de energia ocultas." -ForegroundColor White
    Write-Host ""

    $confirm = Read-Host "Continuar? (S/N)"

    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Host ""
        Write-Host "Operacion cancelada." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    Write-Host ""
    Write-Host "Procesando..." -ForegroundColor Green

    try {
        $PowerCfg = (Get-ChildItem $script:PowerSettingsPath -Recurse).Name
        $contador = 0

        foreach ($item in $PowerCfg) {
            try {
                Set-ItemProperty -Path $item.Replace('HKEY_LOCAL_MACHINE','HKLM:') -Name 'Attributes' -Value 2 -Force -ErrorAction SilentlyContinue
                $contador++
            }
            catch {
                # Silenciar errores individuales
            }
        }

        Write-Host ""
        Write-Host "Completado: $contador opciones desbloqueadas" -ForegroundColor Green
        Write-Host "Se recomienda reiniciar el sistema para aplicar los cambios" -ForegroundColor Cyan
    }
    catch {
        Write-Host ""
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Reset-ToDefault {
    Show-Header
    Write-Host "RESTAURAR A DEFAULT" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta accion OCULTARA TODAS las opciones de energia." -ForegroundColor White
    Write-Host "Las opciones volveran al estado predeterminado de Windows." -ForegroundColor White
    Write-Host ""

    $confirm = Read-Host "Continuar? (S/N)"

    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Host ""
        Write-Host "Operacion cancelada." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    Write-Host ""
    Write-Host "Procesando..." -ForegroundColor Green

    try {
        $PowerCfg = (Get-ChildItem $script:PowerSettingsPath -Recurse).Name
        $contador = 0

        foreach ($item in $PowerCfg) {
            try {
                Set-ItemProperty -Path $item.Replace('HKEY_LOCAL_MACHINE','HKLM:') -Name 'Attributes' -Value 1 -Force -ErrorAction SilentlyContinue
                $contador++
            }
            catch {
                # Silenciar errores individuales
            }
        }

        Write-Host ""
        Write-Host "Completado: $contador opciones ocultadas" -ForegroundColor Green
        Write-Host "Se recomienda reiniciar el sistema para aplicar los cambios" -ForegroundColor Cyan
    }
    catch {
        Write-Host ""
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Select-Categories {
    do {
        Show-Header
        Write-Host "SELECCIONAR CATEGORIAS" -ForegroundColor Yellow
        Write-Host "===========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Selecciona una categoria para modificar:" -ForegroundColor White
        Write-Host ""

        $i = 1
        $categoriasList = @()
        foreach ($cat in $script:Categorias.Keys) {
            Write-Host "[$i] $cat" -ForegroundColor White
            $categoriasList += $cat
            $i++
        }

        Write-Host ""
        Write-Host "[0] Volver al menu principal" -ForegroundColor Gray
        Write-Host ""

        $seleccion = Read-Host "Categoria #"

        if ($seleccion -eq "0") {
            return
        }

        if ($seleccion -match '^\d+$' -and [int]$seleccion -ge 1 -and [int]$seleccion -le $categoriasList.Count) {
            $categoriaSeleccionada = $categoriasList[[int]$seleccion - 1]
            $guid = $script:Categorias[$categoriaSeleccionada]

            Show-Header
            Write-Host "CATEGORIA: $categoriaSeleccionada" -ForegroundColor Yellow
            Write-Host "===========================================" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Que hacer con esta categoria?" -ForegroundColor White
            Write-Host ""
            Write-Host "[1] MOSTRAR opciones (desbloquear)" -ForegroundColor Green
            Write-Host "[2] OCULTAR opciones (bloquear)" -ForegroundColor Red
            Write-Host "[0] Cancelar" -ForegroundColor Gray
            Write-Host ""

            $accion = Read-Host "Accion"

            if ($accion -eq "1" -or $accion -eq "2") {
                $attributeValue = if ($accion -eq "1") { 2 } else { 1 }
                $accionTexto = if ($accion -eq "1") { "MOSTRADAS" } else { "OCULTADAS" }

                Write-Host ""
                Write-Host "Procesando..." -ForegroundColor Cyan

                try {
                    $ruta = "$script:PowerSettingsPath\$guid"

                    if (Test-Path $ruta) {
                        $items = Get-ChildItem $ruta -Recurse
                        $contador = 0

                        foreach ($item in $items) {
                            try {
                                Set-ItemProperty -Path $item.PSPath -Name 'Attributes' -Value $attributeValue -Force -ErrorAction SilentlyContinue
                                $contador++
                            }
                            catch {
                                # Silenciar errores individuales
                            }
                        }

                        Write-Host ""
                        Write-Host "Completado: $contador opciones $accionTexto en '$categoriaSeleccionada'" -ForegroundColor Green
                    }
                    else {
                        Write-Host ""
                        Write-Host "Error: No se encontro la ruta de la categoria" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host ""
                    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                }

                Write-Host ""
                Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            elseif ($accion -ne "0") {
                Write-Host ""
                Write-Host "Opcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        else {
            Write-Host ""
            Write-Host "Seleccion invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }

    } while ($true)
}

function Show-MainMenu {
    Show-Header

    Write-Host "[1] Desbloquear TODAS las opciones" -ForegroundColor White
    Write-Host "[2] Restaurar a DEFAULT (ocultar todo)" -ForegroundColor White
    Write-Host "[3] Seleccionar categorias a mostrar/ocultar" -ForegroundColor White
    Write-Host ""
    Write-Host "[0] Salir" -ForegroundColor Gray
    Write-Host ""

    $opcion = Read-Host "Selecciona una opcion"
    return $opcion
}

# ========================================================================
# MAIN LOOP
# ========================================================================

# Verificar privilegios de administrador
if (-not (Test-AdminPrivileges)) {
    Clear-Host
    Write-Host ""
    Write-Host "ERROR: Este script requiere privilegios de Administrador" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, ejecuta PowerShell como Administrador y vuelve a intentar." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Loop principal del menu
do {
    $opcion = Show-MainMenu

    switch ($opcion) {
        "1" { Unlock-AllOptions }
        "2" { Reset-ToDefault }
        "3" { Select-Categories }
        "0" {
            Show-Header
            Write-Host "Saliendo..." -ForegroundColor Cyan
            Write-Host ""
            Start-Sleep -Seconds 1
            break
        }
        default {
            Write-Host ""
            Write-Host "Opcion invalida. Intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }

} while ($opcion -ne "0")

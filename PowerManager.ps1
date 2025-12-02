# ========================================================================
# POWER SETTINGS MANAGER - Gestor de Opciones de Energia
# ========================================================================
# Script todo-en-uno para gestionar opciones de energia en Windows
# Ejecutar como Administrador
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
# FUNCIONES AUXILIARES
# ========================================================================

function Show-Header {
    Clear-Host
    Write-Host "`n===========================================" -ForegroundColor Cyan
    Write-Host "  POWER SETTINGS MANAGER - Gestor Energia " -ForegroundColor Cyan
    Write-Host "===========================================`n" -ForegroundColor Cyan
}

function Wait-KeyPress {
    Write-Host "`nPresiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-Confirmation {
    param([string]$Message)
    $confirm = Read-Host $Message
    return ($confirm -eq 'S' -or $confirm -eq 's')
}

# ========================================================================
# FUNCIONES PRINCIPALES
# ========================================================================

function Set-PowerOptions {
    param(
        [string]$Path,
        [int]$AttributeValue,
        [string]$ActionText
    )

    Write-Host "`nProcesando..." -ForegroundColor Green

    try {
        $items = Get-ChildItem $Path -Recurse -ErrorAction Stop
        $contador = 0

        foreach ($item in $items) {
            try {
                $itemPath = $item.Name -replace 'HKEY_LOCAL_MACHINE','HKLM:'
                Set-ItemProperty -Path $itemPath -Name 'Attributes' -Value $AttributeValue -Force -ErrorAction SilentlyContinue
                $contador++
            }
            catch { }
        }

        Write-Host "`nCompletado: $contador opciones $ActionText" -ForegroundColor Green
        Write-Host "Se recomienda reiniciar el sistema para aplicar los cambios" -ForegroundColor Cyan
    }
    catch {
        Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Unlock-AllOptions {
    Show-Header
    Write-Host "DESBLOQUEAR TODAS LAS OPCIONES" -ForegroundColor Yellow
    Write-Host "===========================================`n" -ForegroundColor Yellow
    Write-Host "Esta accion revelara TODAS las opciones de energia ocultas.`n" -ForegroundColor White

    if (-not (Get-Confirmation "Continuar? (S/N)")) {
        Write-Host "`nOperacion cancelada." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    Set-PowerOptions -Path $script:PowerSettingsPath -AttributeValue 2 -ActionText "desbloqueadas"
    Wait-KeyPress
}

function Reset-ToDefault {
    Show-Header
    Write-Host "RESTAURAR A DEFAULT" -ForegroundColor Yellow
    Write-Host "===========================================`n" -ForegroundColor Yellow
    Write-Host "Esta accion OCULTARA TODAS las opciones de energia." -ForegroundColor White
    Write-Host "Las opciones volveran al estado predeterminado de Windows.`n" -ForegroundColor White

    if (-not (Get-Confirmation "Continuar? (S/N)")) {
        Write-Host "`nOperacion cancelada." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        return
    }

    Set-PowerOptions -Path $script:PowerSettingsPath -AttributeValue 1 -ActionText "ocultadas"
    Wait-KeyPress
}

function Select-Categories {
    do {
        Show-Header
        Write-Host "SELECCIONAR CATEGORIAS" -ForegroundColor Yellow
        Write-Host "===========================================`n" -ForegroundColor Yellow
        Write-Host "Selecciona una categoria para modificar:`n" -ForegroundColor White

        $categoriasList = $script:Categorias.Keys | Sort-Object
        $i = 1
        foreach ($cat in $categoriasList) {
            Write-Host "[$i] $cat" -ForegroundColor Cyan
            $i++
        }

        Write-Host "`n[0] Volver al menu principal`n" -ForegroundColor Gray

        $seleccion = Read-Host "Categoria #"

        if ($seleccion -eq "0") { return }

        $index = [int]$seleccion - 1
        if ($seleccion -match '^\d+$' -and $index -ge 0 -and $index -lt $categoriasList.Count) {
            $categoriaSeleccionada = $categoriasList[$index]
            $guid = $script:Categorias[$categoriaSeleccionada]

            Show-Header
            Write-Host "CATEGORIA: $categoriaSeleccionada" -ForegroundColor Yellow
            Write-Host "===========================================`n" -ForegroundColor Yellow
            Write-Host "Que hacer con esta categoria?`n" -ForegroundColor White
            Write-Host "[1] MOSTRAR opciones (desbloquear)" -ForegroundColor Green
            Write-Host "[2] OCULTAR opciones (bloquear)" -ForegroundColor Red
            Write-Host "[0] Cancelar`n" -ForegroundColor Gray

            $accion = Read-Host "Accion"

            if ($accion -eq "1" -or $accion -eq "2") {
                $attributeValue = if ($accion -eq "1") { 2 } else { 1 }
                $accionTexto = if ($accion -eq "1") { "MOSTRADAS" } else { "OCULTADAS" }

                $ruta = "$script:PowerSettingsPath\$guid"
                if (Test-Path $ruta) {
                    Set-PowerOptions -Path $ruta -AttributeValue $attributeValue -ActionText "$accionTexto en '$categoriaSeleccionada'"
                } else {
                    Write-Host "`nError: No se encontro la ruta de la categoria" -ForegroundColor Red
                }
                Wait-KeyPress
            }
            elseif ($accion -ne "0") {
                Write-Host "`nOpcion invalida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        else {
            Write-Host "`nSeleccion invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    } while ($true)
}

function Show-MainMenu {
    Show-Header
    Write-Host "[1] Desbloquear TODAS las opciones" -ForegroundColor Green
    Write-Host "[2] Restaurar a DEFAULT (ocultar todo)" -ForegroundColor Red
    Write-Host "[3] Seleccionar categorias a mostrar/ocultar" -ForegroundColor Yellow
    Write-Host "`n[0] Salir`n" -ForegroundColor Gray
    return Read-Host "Selecciona una opcion"
}

# ========================================================================
# MAIN LOOP
# ========================================================================

do {
    $opcion = Show-MainMenu

    switch ($opcion) {
        "1" { Unlock-AllOptions }
        "2" { Reset-ToDefault }
        "3" { Select-Categories }
        "0" {
            Show-Header
            Write-Host "Saliendo...`n" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            break
        }
        default {
            Write-Host "`nOpcion invalida. Intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($opcion -ne "0")

<#
    bq-diagnostico-python.ps1
    -------------------------------------------------------------------------
    RELEVAMIENTO SOLO LECTURA del aislamiento de entornos Python
    de las plataformas bajo C:\BeQuarks\plataformas\

    QUE HACE ESTE SCRIPT:
        - Lee carpetas, lee archivos, lee el registro de Windows,
          lista tareas programadas y lista carpetas *.dist-info.
        - Escribe UN solo archivo de reporte, en %TEMP%, fuera del proyecto.

    QUE NO HACE (por diseno):
        - NO crea entornos virtuales.
        - NO instala, actualiza ni desinstala paquetes.
        - NO edita ni borra nada dentro de C:\BeQuarks\.
        - NO ejecuta uv ni uvx (solo lee su ruta y los metadatos del .exe),
          para no disparar el bloqueo WDAC.
        - NO ejecuta python salvo que se pase -RunPipList explicitamente.
          Por defecto la lista de paquetes del Python global se obtiene
          LEYENDO las carpetas *.dist-info de site-packages: cero ejecucion.

    USO:
        powershell -ExecutionPolicy Bypass -File .\bq-diagnostico-python.ps1
    Parametros opcionales:
        -Base "C:\BeQuarks\plataformas"   ruta raiz a relevar
        -OutFile "C:\ruta\reporte.md"     destino del reporte
        -NoFile                           no escribir archivo, solo consola
        -RunPipList                       ademas ejecutar "python -m pip list"
#>

[CmdletBinding()]
param(
    [string] $Base    = 'C:\BeQuarks\plataformas',
    [string] $OutFile = (Join-Path $env:TEMP 'bq-diagnostico-python.md'),
    [switch] $NoFile,
    [switch] $RunPipList
)

$ErrorActionPreference = 'Continue'
$script:R = @()

function Add-Line {
    param([string] $t = '')
    $script:R += $t
    Write-Host $t
}

# --------------------------------------------------------------------------
# Catalogos
# --------------------------------------------------------------------------

$StdlibNames = @(
    '__future__','_thread','abc','argparse','array','ast','asyncio','base64','bdb','binascii',
    'bisect','builtins','bz2','calendar','cgi','chunk','cmath','cmd','code','codecs','codeop',
    'collections','colorsys','compileall','concurrent','configparser','contextlib','contextvars',
    'copy','copyreg','csv','ctypes','curses','dataclasses','datetime','dbm','decimal','difflib',
    'dis','doctest','email','encodings','ensurepip','enum','errno','faulthandler','fcntl',
    'filecmp','fileinput','fnmatch','fractions','ftplib','functools','gc','getopt','getpass',
    'gettext','glob','graphlib','grp','gzip','hashlib','heapq','hmac','html','http','imaplib',
    'imp','importlib','inspect','io','ipaddress','itertools','json','keyword','linecache',
    'locale','logging','lzma','mailbox','marshal','math','mimetypes','mmap','modulefinder',
    'msvcrt','multiprocessing','netrc','numbers','operator','optparse','os','pathlib','pdb',
    'pickle','pickletools','pkgutil','platform','plistlib','poplib','posixpath','pprint','profile',
    'pstats','pty','pwd','py_compile','pyclbr','pydoc','queue','quopri','random','re','reprlib',
    'resource','rlcompleter','runpy','sched','secrets','select','selectors','shelve','shlex',
    'shutil','signal','site','smtplib','sndhdr','socket','socketserver','sqlite3','ssl','stat',
    'statistics','string','stringprep','struct','subprocess','sunau','symtable','sys','sysconfig',
    'tabnanny','tarfile','telnetlib','tempfile','termios','textwrap','threading','time','timeit',
    'tkinter','token','tokenize','tomllib','trace','traceback','tracemalloc','tty','turtle',
    'types','typing','unicodedata','unittest','urllib','uuid','venv','warnings','wave','weakref',
    'webbrowser','winreg','winsound','wsgiref','xdrlib','xml','xmlrpc','zipapp','zipfile',
    'zipimport','zlib','zoneinfo'
)
$Stdlib = @{}
foreach ($m in $StdlibNames) { $Stdlib[$m] = $true }

# import -> nombre real del paquete en PyPI (cuando difieren)
$ImportToPkg = @{
    'bs4'='beautifulsoup4'; 'cv2'='opencv-python'; 'dateutil'='python-dateutil';
    'dotenv'='python-dotenv'; 'fitz'='pymupdf'; 'google'='google-api-python-client';
    'jwt'='pyjwt'; 'lxml'='lxml'; 'openpyxl'='openpyxl'; 'PIL'='pillow';
    'pptx'='python-pptx'; 'psycopg2'='psycopg2-binary'; 'pythoncom'='pywin32';
    'serial'='pyserial'; 'skimage'='scikit-image'; 'sklearn'='scikit-learn';
    'win32com'='pywin32'; 'win32api'='pywin32'; 'win32gui'='pywin32'; 'yaml'='pyyaml';
    'docx'='python-docx'; 'OpenSSL'='pyopenssl'; 'Crypto'='pycryptodome'
}

# paquetes "pesados o delicados" para aislar
$Heavy = @{
    'playwright'='navegador Chromium embebido (~450 MB) - CRITICO por WDAC';
    'selenium'='requiere driver + navegador externo';
    'undetected-chromedriver'='descarga y parchea chromedriver en runtime';
    'pyppeteer'='descarga Chromium propio';
    'scrapy'='arbol de dependencias grande (twisted, lxml)';
    'numpy'='binario compilado';
    'pandas'='binario compilado, arrastra numpy';
    'scipy'='binario compilado grande';
    'scikit-learn'='binario compilado, arrastra numpy/scipy';
    'matplotlib'='binario compilado + fuentes';
    'pillow'='binario compilado (imagenes)';
    'lxml'='binario compilado (libxml2)';
    'cryptography'='binario compilado (rust/openssl)';
    'pyodbc'='binario compilado + driver ODBC del sistema';
    'psycopg2'='binario compilado (libpq)';
    'psycopg2-binary'='wheel binario (libpq)';
    'mysqlclient'='requiere compilador C';
    'pyarrow'='binario compilado muy grande';
    'opencv-python'='binario compilado muy grande';
    'torch'='binario compilado enorme';
    'tensorflow'='binario compilado enorme';
    'pywin32'='hace post-install COM en el sistema';
    'comtypes'='COM de Windows';
    'weasyprint'='requiere GTK/cairo nativos';
    'pdfkit'='requiere wkhtmltopdf externo';
    'camelot-py'='requiere ghostscript externo';
    'tabula-py'='requiere Java';
    'pymupdf'='binario compilado';
    'reportlab'='binario compilado parcial'
}

$BrowserHints = @('playwright','chromium','chrome','selenium','webdriver','puppeteer','pyppeteer','undetected')

$TargetFolders  = @('pacifico-vehicular','pacifico-soat','pacifico-renovaciones','pacifico-rentas','protecta-rentas','_reportes')
$ControlFolders = @('mapfre-vehicular','pacifico-pbi')

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

function Normalize-PkgName {
    param([string] $n)
    if (-not $n) { return '' }
    $x = $n.ToLower()
    $x = $x.Replace('_','-')
    $x = $x.Replace('.','-')
    return $x
}

function Get-PythonExeVersion {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 'ruta inexistente' }
    try {
        $item = Get-Item -LiteralPath $Path -ErrorAction Stop
        $vi   = $item.VersionInfo
        if ($vi -and $vi.ProductVersion) { return [string]$vi.ProductVersion }
        if ($vi -and $vi.FileVersion)    { return [string]$vi.FileVersion }
        return 'sin metadatos de version'
    } catch {
        return 'no se pudo leer metadatos'
    }
}

function Get-SitePackages {
    param([string] $PythonExe)
    $out = @()
    if (-not $PythonExe) { return $out }
    $dir = Split-Path -Parent $PythonExe
    $candidates = @(
        (Join-Path $dir 'Lib\site-packages'),
        (Join-Path (Split-Path -Parent $dir) 'Lib\site-packages')
    )
    foreach ($sp in $candidates) {
        if (Test-Path -LiteralPath $sp) {
            $metas = Get-ChildItem -LiteralPath $sp -Directory -ErrorAction SilentlyContinue |
                     Where-Object { $_.Name -match '\.(dist|egg)-info$' }
            foreach ($m in $metas) {
                $bare = $m.Name -replace '\.(dist|egg)-info$',''
                $name = $bare
                $ver  = ''
                if ($bare -match '^(.+?)-([0-9][^-]*)$') { $name = $matches[1]; $ver = $matches[2] }
                $out += [pscustomobject]@{
                    Name    = (Normalize-PkgName $name)
                    Version = $ver
                    SitePackages = $sp
                }
            }
            break
        }
    }
    return ($out | Sort-Object Name -Unique)
}

function Parse-Requirement {
    param([string] $Line)
    $l = $Line.Trim()
    if ($l -eq '' -or $l.StartsWith('#') -or $l.StartsWith('-')) { return $null }
    if ($l -match '^([A-Za-z0-9._-]+)\s*(\[[^\]]*\])?\s*(.*)$') {
        $name = Normalize-PkgName $matches[1]
        $spec = $matches[3].Trim()
        if ($spec -match '^(.*?);') { $spec = $matches[1].Trim() }
        if ($spec -match '^(.*?)#') { $spec = $matches[1].Trim() }
        if ($spec -eq '') { $spec = '(sin pin)' }
        return [pscustomobject]@{ Name = $name; Spec = $spec }
    }
    return $null
}

# --------------------------------------------------------------------------
# Encabezado
# --------------------------------------------------------------------------

Add-Line "# Diagnostico de aislamiento Python - Be Quarks"
Add-Line ""
Add-Line ("Generado: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Add-Line ("Equipo:   " + $env:COMPUTERNAME + "   Usuario: " + $env:USERNAME)
Add-Line ("PowerShell: " + $PSVersionTable.PSVersion + "   LanguageMode: " + $ExecutionContext.SessionState.LanguageMode)
Add-Line ("Raiz relevada: " + $Base)
Add-Line ""
if (-not (Test-Path -LiteralPath $Base)) {
    Add-Line ("*** LA RUTA " + $Base + " NO EXISTE en este equipo. Relevamiento abortado. ***")
    if (-not $NoFile) { $script:R | Out-File -FilePath $OutFile -Encoding UTF8 }
    return
}
Add-Line "> Solo lectura. Este script no crea entornos, no instala nada y no edita archivos."
Add-Line ""

# --------------------------------------------------------------------------
# 7. Pythons instalados en el sistema
# --------------------------------------------------------------------------

Add-Line "## 7. Instalaciones de Python en el sistema"
Add-Line ""

$pythonInstalls = @()

foreach ($hive in @('HKLM:\SOFTWARE\Python\PythonCore',
                    'HKLM:\SOFTWARE\WOW6432Node\Python\PythonCore',
                    'HKCU:\SOFTWARE\Python\PythonCore')) {
    if (Test-Path -LiteralPath $hive) {
        foreach ($k in (Get-ChildItem -LiteralPath $hive -ErrorAction SilentlyContinue)) {
            $ipKey = Join-Path $k.PSPath 'InstallPath'
            if (Test-Path -LiteralPath $ipKey) {
                try {
                    $ip  = (Get-ItemProperty -LiteralPath $ipKey -ErrorAction Stop)
                    $dir = $ip.'(default)'
                    if (-not $dir) { $dir = $ip.ExecutablePath }
                    if ($dir) {
                        $exe = $dir
                        if (-not $exe.ToLower().EndsWith('python.exe')) { $exe = Join-Path $dir 'python.exe' }
                        $pythonInstalls += [pscustomobject]@{
                            Tag    = $k.PSChildName
                            Exe    = $exe
                            Origen = $hive
                            Existe = (Test-Path -LiteralPath $exe)
                        }
                    }
                } catch { }
            }
        }
    }
}

Add-Line "### Registrados en el registro de Windows"
if ($pythonInstalls.Count -eq 0) {
    Add-Line "No hay instalaciones de Python registradas en HKLM/HKCU\SOFTWARE\Python\PythonCore."
} else {
    foreach ($p in $pythonInstalls) {
        Add-Line ("- [" + $p.Tag + "] " + $p.Exe)
        Add-Line ("    existe: " + $p.Existe + "  |  version del .exe: " + (Get-PythonExeVersion $p.Exe))
        Add-Line ("    origen: " + $p.Origen)
    }
}
Add-Line ""

Add-Line "### Resueltos por PATH (where.exe python / py)"
$pathPythons = @()
foreach ($cmdName in @('python','python3','py','pythonw')) {
    $found = @()
    try { $found = (Get-Command $cmdName -All -ErrorAction SilentlyContinue) } catch { }
    if (-not $found -or $found.Count -eq 0) {
        Add-Line ("- '" + $cmdName + "' : NO se resuelve en el PATH.")
    } else {
        foreach ($f in $found) {
            $src = $f.Source
            if (-not $src) { $src = $f.Definition }
            $alias = ''
            if ($src -and $src -match 'WindowsApps') { $alias = '   <-- alias de Microsoft Store (stub, NO es un Python real)' }
            Add-Line ("- '" + $cmdName + "' -> " + $src + $alias)
            if ($src -and (Test-Path -LiteralPath $src)) {
                Add-Line ("    version del .exe: " + (Get-PythonExeVersion $src))
                if ($cmdName -eq 'python' -and $alias -eq '') { $pathPythons += $src }
            }
        }
    }
}
Add-Line ""

$GlobalPython = $null
if ($pathPythons.Count -gt 0) { $GlobalPython = $pathPythons[0] }
elseif ($pythonInstalls.Count -gt 0) {
    $real = $pythonInstalls | Where-Object { $_.Existe } | Select-Object -First 1
    if ($real) { $GlobalPython = $real.Exe }
}

if ($GlobalPython) {
    Add-Line ("**Python global efectivo (el que corre al escribir 'python'): " + $GlobalPython + "**")
    Add-Line ("Version del ejecutable: " + (Get-PythonExeVersion $GlobalPython))
} else {
    Add-Line "**No se pudo determinar un Python global: 'python' no resuelve a un ejecutable real.**"
}
Add-Line ""
Add-Line ("PATH del usuario (entradas con 'python' o 'Python'):")
$pathEntries = $env:PATH -split ';'
$pyPathEntries = $pathEntries | Where-Object { $_ -and ($_ -match 'python' -or $_ -match 'Python') }
if (-not $pyPathEntries -or $pyPathEntries.Count -eq 0) {
    Add-Line "  (ninguna entrada del PATH menciona python)"
} else {
    foreach ($e in $pyPathEntries) { Add-Line ("  " + $e) }
}
Add-Line ""

# --------------------------------------------------------------------------
# 8. uv / uvx  -- SIN EJECUTARLOS
# --------------------------------------------------------------------------

Add-Line "## 8. uv / uvx (consulta SEGURA: no se ejecutan)"
Add-Line ""
Add-Line "Metodo: se resuelve la ruta con Get-Command y se leen los metadatos del archivo."
Add-Line "En ningun momento se invoca 'uv --version' ni 'uvx', para no disparar el bloqueo WDAC."
Add-Line ""
foreach ($tool in @('uv','uvx')) {
    $c = $null
    try { $c = Get-Command $tool -ErrorAction SilentlyContinue } catch { }
    if (-not $c) {
        Add-Line ("- " + $tool + ": NO se encuentra en el PATH.")
        $guess = Join-Path $env:USERPROFILE (".local\bin\" + $tool + ".exe")
        if (Test-Path -LiteralPath $guess) {
            Add-Line ("    pero SI existe el archivo en: " + $guess)
            Add-Line ("    version segun metadatos del .exe: " + (Get-PythonExeVersion $guess))
        } else {
            Add-Line ("    tampoco existe en la ruta habitual " + $guess)
        }
    } else {
        $src = $c.Source
        if (-not $src) { $src = $c.Definition }
        Add-Line ("- " + $tool + ": " + $src)
        Add-Line ("    version segun metadatos del .exe: " + (Get-PythonExeVersion $src))
        try {
            $it = Get-Item -LiteralPath $src -ErrorAction Stop
            Add-Line ("    tamano: " + $it.Length + " bytes  |  modificado: " + $it.LastWriteTime)
        } catch { }
        Add-Line "    (version NO confirmada por ejecucion: los metadatos del .exe pueden diferir del build real)"
    }
}
Add-Line ""

# --------------------------------------------------------------------------
# 9. Paquetes instalados en el Python global
# --------------------------------------------------------------------------

Add-Line "## 9. Paquetes instalados en el Python global (la 'caja compartida')"
Add-Line ""
$globalPkgs = @()
if ($GlobalPython) {
    $globalPkgs = Get-SitePackages $GlobalPython
    if ($globalPkgs.Count -eq 0) {
        Add-Line "No se encontro site-packages legible para el Python global."
    } else {
        Add-Line ("Fuente: " + $globalPkgs[0].SitePackages + "   (leido de disco, sin ejecutar pip)")
        Add-Line ("Total: " + $globalPkgs.Count + " paquetes")
        Add-Line ""
        foreach ($p in $globalPkgs) { Add-Line ("  " + $p.Name + " == " + $p.Version) }
    }
} else {
    Add-Line "Sin Python global identificado, no hay site-packages que listar."
}
Add-Line ""
if ($RunPipList -and $GlobalPython) {
    Add-Line "### pip list (ejecucion explicita solicitada con -RunPipList)"
    try {
        $pip = & $GlobalPython -m pip list 2>&1
        foreach ($l in $pip) { Add-Line ("  " + $l) }
    } catch {
        Add-Line ("  Fallo la ejecucion de pip: " + $_.Exception.Message)
    }
    Add-Line ""
} else {
    Add-Line "_(pip list no se ejecuto. Pasar -RunPipList si se quiere ademas la salida de pip.)_"
    Add-Line ""
}

# --------------------------------------------------------------------------
# Tareas programadas (se consulta una sola vez)
# --------------------------------------------------------------------------

$allTasks = @()
try {
    $allTasks = Get-ScheduledTask -ErrorAction SilentlyContinue
} catch { }

# --------------------------------------------------------------------------
# Relevamiento por carpeta
# --------------------------------------------------------------------------

$Summary   = @()
$DeclDeps  = @()   # folder / pkg / spec / fuente
$ImpDeps   = @()   # folder / pkg

$allFolders = @()
foreach ($f in $TargetFolders)  { $allFolders += [pscustomobject]@{ Name=$f; Rol='DIAGNOSTICAR' } }
foreach ($f in $ControlFolders) { $allFolders += [pscustomobject]@{ Name=$f; Rol='CONTROL' } }

Add-Line "## Relevamiento por carpeta"
Add-Line ""

foreach ($entry in $allFolders) {

    $name = $entry.Name
    $path = Join-Path $Base $name

    Add-Line ("### " + $name + "   [" + $entry.Rol + "]")
    Add-Line ("Ruta: " + $path)
    Add-Line ""

    if (-not (Test-Path -LiteralPath $path)) {
        Add-Line "**La carpeta NO EXISTE en este equipo.**"
        Add-Line ""
        $Summary += [pscustomobject]@{
            Carpeta=$name; Rol=$entry.Rol; Venv='carpeta inexistente'; Interprete='-'
            NPaquetes='-'; Playwright='-'; Lanzador='-'
        }
        continue
    }

    # ---- 1. venv propio ----
    Add-Line "**1. Entorno virtual propio**"
    $venvPath = $null
    $venvPy   = $null
    foreach ($vn in @('.venv','venv','env','.env','virtualenv')) {
        $cand   = Join-Path $path $vn
        $candPy = Join-Path $cand 'Scripts\python.exe'
        if (Test-Path -LiteralPath $candPy) { $venvPath = $cand; $venvPy = $candPy; break }
    }
    if ($venvPy) {
        Add-Line ("  SI. Ruta: " + $venvPath)
        Add-Line ("  Interprete del venv: " + $venvPy)
        Add-Line ("  Version del .exe: " + (Get-PythonExeVersion $venvPy))
        $cfg = Join-Path $venvPath 'pyvenv.cfg'
        if (Test-Path -LiteralPath $cfg) {
            Add-Line ("  pyvenv.cfg (" + $cfg + "):")
            foreach ($l in (Get-Content -LiteralPath $cfg -ErrorAction SilentlyContinue)) { Add-Line ("      " + $l) }
        } else {
            Add-Line ("  No existe pyvenv.cfg en " + $venvPath)
        }
        $vpk = Get-SitePackages $venvPy
        Add-Line ("  Paquetes instalados dentro del venv: " + $vpk.Count)
        foreach ($p in $vpk) { Add-Line ("      " + $p.Name + " == " + $p.Version) }
    } else {
        Add-Line "  NO. No existe .venv, venv, env, .env ni virtualenv con Scripts\python.exe en esta carpeta."
    }
    Add-Line ""

    # ---- 2. archivos de dependencias ----
    Add-Line "**2. Archivos de dependencias**"
    $depFiles = @()
    foreach ($pattern in @('requirements*.txt','pyproject.toml','Pipfile','Pipfile.lock','setup.py','setup.cfg','environment.yml','poetry.lock','uv.lock','constraints.txt')) {
        $hits = Get-ChildItem -LiteralPath $path -Filter $pattern -File -ErrorAction SilentlyContinue
        foreach ($h in $hits) { $depFiles += $h }
    }
    if ($depFiles.Count -eq 0) {
        Add-Line "  NO EXISTE ningun archivo de dependencias en esta carpeta (ni requirements.txt, ni pyproject.toml, ni Pipfile)."
    } else {
        foreach ($df in $depFiles) {
            Add-Line ("  - " + $df.FullName + "   (" + $df.Length + " bytes, modificado " + $df.LastWriteTime + ")")
            if ($df.Name -like 'requirements*.txt' -or $df.Name -eq 'constraints.txt') {
                foreach ($line in (Get-Content -LiteralPath $df.FullName -ErrorAction SilentlyContinue)) {
                    $req = Parse-Requirement $line
                    if ($req) {
                        Add-Line ("        " + $req.Name + "  " + $req.Spec)
                        $DeclDeps += [pscustomobject]@{ Carpeta=$name; Pkg=$req.Name; Spec=$req.Spec; Fuente=$df.Name }
                    }
                }
            }
            elseif ($df.Name -eq 'pyproject.toml' -or $df.Name -eq 'Pipfile' -or $df.Name -eq 'setup.cfg' -or $df.Name -eq 'environment.yml') {
                Add-Line "        --- contenido completo ---"
                foreach ($line in (Get-Content -LiteralPath $df.FullName -ErrorAction SilentlyContinue)) {
                    Add-Line ("        " + $line)
                }
                Add-Line "        --- fin contenido ---"
                foreach ($line in (Get-Content -LiteralPath $df.FullName -ErrorAction SilentlyContinue)) {
                    if ($line -match '["'']([A-Za-z0-9._-]+)\s*([<>=!~][^"'']*)?["'']') {
                        $cand = Normalize-PkgName $matches[1]
                        $sp   = $matches[2]
                        if (-not $sp) { $sp = '(sin pin)' } else { $sp = $sp.Trim() }
                        if ($cand.Length -gt 1 -and -not $Stdlib[$cand]) {
                            $DeclDeps += [pscustomobject]@{ Carpeta=$name; Pkg=$cand; Spec=$sp; Fuente=$df.Name }
                        }
                    }
                }
            }
        }
    }
    Add-Line ""

    # ---- 3. interprete que correria hoy ----
    Add-Line "**3. Interprete que correria hoy un script lanzado desde esta carpeta**"
    if ($venvPy) {
        Add-Line ("  Local (si se activa el venv o se invoca su python): " + $venvPy)
        Add-Line ("  OJO: si el .bat/.ps1 llama a 'python' pelado SIN activar el venv, correria igual el global:")
        if ($GlobalPython) { Add-Line ("      " + $GlobalPython) } else { Add-Line "      (global no identificado)" }
    } else {
        if ($GlobalPython) {
            Add-Line ("  GLOBAL DEL SISTEMA: " + $GlobalPython)
            Add-Line ("  Version del .exe: " + (Get-PythonExeVersion $GlobalPython))
        } else {
            Add-Line "  No hay venv local y tampoco se pudo resolver un 'python' global."
        }
    }
    Add-Line ""

    # ---- 4. imports de terceros ----
    Add-Line "**4. Paquetes de terceros realmente importados en los .py**"
    $pyFiles = Get-ChildItem -LiteralPath $path -Filter *.py -File -Recurse -ErrorAction SilentlyContinue |
               Where-Object {
                   $fp = $_.FullName
                   -not ($fp -match '\\\.venv\\' -or $fp -match '\\venv\\' -or $fp -match '\\env\\' -or
                         $fp -match '\\site-packages\\' -or $fp -match '\\__pycache__\\' -or
                         $fp -match '\\node_modules\\' -or $fp -match '\\\.git\\')
               }
    Add-Line ("  Archivos .py analizados: " + $pyFiles.Count)

    # nombres locales (para no confundirlos con paquetes de terceros)
    $localNames = @{}
    foreach ($f in $pyFiles) { $localNames[$f.BaseName.ToLower()] = $true }
    foreach ($d in (Get-ChildItem -LiteralPath $path -Directory -ErrorAction SilentlyContinue)) {
        if (Test-Path -LiteralPath (Join-Path $d.FullName '__init__.py')) { $localNames[$d.Name.ToLower()] = $true }
    }

    $imports = @{}
    foreach ($f in $pyFiles) {
        foreach ($line in (Get-Content -LiteralPath $f.FullName -ErrorAction SilentlyContinue)) {
            $t = $line.Trim()
            if ($t -match '^from\s+([A-Za-z_][A-Za-z0-9_]*)') {
                $mod = $matches[1]
                if (-not $imports[$mod]) { $imports[$mod] = @() }
                if ($imports[$mod] -notcontains $f.Name) { $imports[$mod] += $f.Name }
            }
            elseif ($t -match '^import\s+(.+)$') {
                $rest = $matches[1]
                foreach ($piece in ($rest -split ',')) {
                    $p = $piece.Trim()
                    if ($p -match '^([A-Za-z_][A-Za-z0-9_]*)') {
                        $mod = $matches[1]
                        if (-not $imports[$mod]) { $imports[$mod] = @() }
                        if ($imports[$mod] -notcontains $f.Name) { $imports[$mod] += $f.Name }
                    }
                }
            }
        }
    }

    $thirdParty = @()
    foreach ($mod in ($imports.Keys | Sort-Object)) {
        $low = $mod.ToLower()
        if ($Stdlib[$low]) { continue }
        if ($Stdlib[$mod]) { continue }
        if ($localNames[$low]) { continue }
        $pkg = $mod
        if ($ImportToPkg[$mod]) { $pkg = $ImportToPkg[$mod] }
        elseif ($ImportToPkg[$low]) { $pkg = $ImportToPkg[$low] }
        $pkgN = Normalize-PkgName $pkg
        $thirdParty += [pscustomobject]@{ Import=$mod; Pkg=$pkgN; Archivos=($imports[$mod] -join ', ') }
        $ImpDeps += [pscustomobject]@{ Carpeta=$name; Pkg=$pkgN; Import=$mod }
    }

    if ($thirdParty.Count -eq 0) {
        Add-Line "  No se detecto ningun import de terceros (o no hay archivos .py en esta carpeta)."
    } else {
        Add-Line ("  Total de paquetes de terceros distintos: " + $thirdParty.Count)
        foreach ($tp in $thirdParty) {
            $heavyNote = ''
            if ($Heavy[$tp.Pkg]) { $heavyNote = '   [PESADO/DELICADO: ' + $Heavy[$tp.Pkg] + ']' }
            Add-Line ("      import " + $tp.Import + "   -> paquete '" + $tp.Pkg + "'" + $heavyNote)
            Add-Line ("          usado en: " + $tp.Archivos)
        }
    }
    Add-Line ""

    # ---- 5. Playwright / Chromium ----
    Add-Line "**5. Uso de Playwright / Chromium**"
    $browserHits = @()
    foreach ($f in $pyFiles) {
        $hit = Select-String -LiteralPath $f.FullName -Pattern 'playwright|chromium|webdriver|selenium|puppeteer|chrome\.exe' -ErrorAction SilentlyContinue
        foreach ($h in $hit) { $browserHits += ($f.Name + ':' + $h.LineNumber + '  ' + $h.Line.Trim()) }
    }
    $usesBrowser = $false
    if ($browserHits.Count -gt 0) {
        $usesBrowser = $true
        Add-Line ("  SI. " + $browserHits.Count + " referencias encontradas:")
        foreach ($h in ($browserHits | Select-Object -First 25)) { Add-Line ("      " + $h) }
        if ($browserHits.Count -gt 25) { Add-Line ("      ... y " + ($browserHits.Count - 25) + " mas") }
    } else {
        Add-Line "  NO. Ningun .py de esta carpeta menciona playwright, chromium, selenium ni webdriver."
    }
    $localBrowsers = Join-Path $path 'ms-playwright'
    if (Test-Path -LiteralPath $localBrowsers) {
        Add-Line ("  Cache de navegadores Playwright DENTRO de la carpeta: " + $localBrowsers)
    }
    Add-Line ""

    # ---- 6. lanzadores ----
    Add-Line "**6. Como se lanza hoy**"
    $launchers = Get-ChildItem -LiteralPath $path -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
                 Where-Object { @('.bat','.cmd','.ps1','.vbs') -contains $_.Extension.ToLower() } |
                 Where-Object { -not ($_.FullName -match '\\\.venv\\' -or $_.FullName -match '\\venv\\' -or $_.FullName -match '\\site-packages\\') }
    $launcherNames = @()
    if (-not $launchers -or $launchers.Count -eq 0) {
        Add-Line "  NO EXISTE ningun .bat, .cmd, .ps1 ni .vbs dentro de esta carpeta."
    } else {
        foreach ($lf in $launchers) {
            $launcherNames += $lf.Name
            Add-Line ("  - " + $lf.FullName)
            $content = Get-Content -LiteralPath $lf.FullName -ErrorAction SilentlyContinue
            $n = 0
            foreach ($line in $content) {
                $n = $n + 1
                if ($line -match 'python|\.venv|venv|activate|uv\s|uvx|py\s+-' ) {
                    Add-Line ("        L" + $n + ": " + $line.Trim())
                }
            }
            Add-Line "        --- contenido completo ---"
            $n = 0
            foreach ($line in $content) { $n = $n + 1; Add-Line ("        " + $n + " | " + $line) }
            Add-Line "        --- fin ---"
        }
    }

    # lanzadores en la raiz que mencionen esta carpeta
    $rootLaunchers = Get-ChildItem -LiteralPath $Base -File -ErrorAction SilentlyContinue |
                     Where-Object { @('.bat','.cmd','.ps1') -contains $_.Extension.ToLower() }
    foreach ($rl in $rootLaunchers) {
        $m = Select-String -LiteralPath $rl.FullName -Pattern $name -SimpleMatch -ErrorAction SilentlyContinue
        if ($m) {
            Add-Line ("  - Lanzador en la raiz que menciona esta carpeta: " + $rl.FullName)
            foreach ($mm in $m) { Add-Line ("        L" + $mm.LineNumber + ": " + $mm.Line.Trim()) }
            $launcherNames += ($rl.Name + ' (raiz)')
        }
    }

    # tareas programadas
    $taskHits = @()
    foreach ($t in $allTasks) {
        foreach ($a in $t.Actions) {
            $blob = ''
            try { $blob = [string]$a.Execute + ' ' + [string]$a.Arguments + ' ' + [string]$a.WorkingDirectory } catch { }
            if ($blob -and $blob.ToLower().Contains($name.ToLower())) {
                $taskHits += ($t.TaskPath + $t.TaskName + '  ->  ' + $blob.Trim())
            }
        }
    }
    if ($taskHits.Count -gt 0) {
        Add-Line "  Tareas programadas que invocan esta carpeta:"
        foreach ($th in ($taskHits | Sort-Object -Unique)) { Add-Line ("      " + $th); $launcherNames += 'tarea programada' }
    } else {
        Add-Line "  No hay tareas programadas de Windows que mencionen esta carpeta."
    }
    Add-Line ""

    $lanzResumen = 'ninguno'
    if ($launcherNames.Count -gt 0) { $lanzResumen = (($launcherNames | Sort-Object -Unique) -join '; ') }

    $Summary += [pscustomobject]@{
        Carpeta    = $name
        Rol        = $entry.Rol
        Venv       = $(if ($venvPy) { 'SI  ' + $venvPath } else { 'NO' })
        Interprete = $(if ($venvPy) { $venvPy } elseif ($GlobalPython) { $GlobalPython + ' (GLOBAL)' } else { 'indeterminado' })
        NPaquetes  = $thirdParty.Count
        Playwright = $(if ($usesBrowser) { 'SI' } else { 'no' })
        Lanzador   = $lanzResumen
    }

    Add-Line "---"
    Add-Line ""
}

# --------------------------------------------------------------------------
# 10. Conflictos entre carpetas
# --------------------------------------------------------------------------

Add-Line "## 10. Conflictos: mismo paquete con versiones distintas entre carpetas"
Add-Line ""

$onlyTargets = $TargetFolders
$declTargets = $DeclDeps | Where-Object { $onlyTargets -contains $_.Carpeta }

if ($declTargets.Count -eq 0) {
    Add-Line "Ninguna de las seis carpetas declara dependencias con version, asi que NO se puede detectar"
    Add-Line "un conflicto de versiones declaradas. El riesgo aqui es el contrario: nada esta fijado,"
    Add-Line "y todas dependen de lo que hoy tenga instalado el Python global."
} else {
    $grouped = $declTargets | Group-Object Pkg
    $conflicts = @()
    foreach ($g in $grouped) {
        $specs = ($g.Group | ForEach-Object { $_.Spec } | Sort-Object -Unique)
        if ($specs.Count -gt 1) { $conflicts += $g }
    }
    if ($conflicts.Count -eq 0) {
        Add-Line "No se detectaron dos carpetas que declaren versiones DISTINTAS del mismo paquete."
    } else {
        Add-Line ("Se detectaron " + $conflicts.Count + " paquetes con especificaciones divergentes:")
        Add-Line ""
        foreach ($c in $conflicts) {
            Add-Line ("- **" + $c.Name + "**")
            foreach ($d in ($c.Group | Sort-Object Carpeta)) {
                Add-Line ("      " + $d.Carpeta.PadRight(24) + " declara: " + $d.Spec + "   (" + $d.Fuente + ")")
            }
        }
    }
}
Add-Line ""

Add-Line "### Paquetes compartidos por 2 o mas de las seis carpetas (por import real)"
$impTargets = $ImpDeps | Where-Object { $onlyTargets -contains $_.Carpeta }
$sharedRows = @()
if ($impTargets.Count -gt 0) {
    foreach ($g in ($impTargets | Group-Object Pkg)) {
        $folders = ($g.Group | ForEach-Object { $_.Carpeta } | Sort-Object -Unique)
        if ($folders.Count -ge 2) {
            $inst = $globalPkgs | Where-Object { $_.Name -eq $g.Name } | Select-Object -First 1
            $instTxt = 'NO instalado en el global'
            if ($inst) { $instTxt = 'global tiene ' + $inst.Version }
            Add-Line ("- " + $g.Name.PadRight(24) + " usado por " + $folders.Count + ": " + ($folders -join ', ') + "   [" + $instTxt + "]")
            $sharedRows += $g.Name
        }
    }
    if ($sharedRows.Count -eq 0) { Add-Line "  Ningun paquete de terceros es compartido por dos o mas de las seis carpetas." }
} else {
    Add-Line "  No se detectaron imports de terceros en las seis carpetas."
}
Add-Line ""
Add-Line "> Nota: cuando dos carpetas comparten un paquete SIN pin, hoy conviven porque ambas usan"
Add-Line "> la misma version del global. El conflicto aparece el dia que una necesite actualizarlo."
Add-Line ""

# --------------------------------------------------------------------------
# 11. Peso de aislamiento
# --------------------------------------------------------------------------

Add-Line "## 11. Peso estimado para aislar cada carpeta"
Add-Line ""
foreach ($f in $TargetFolders) {
    $rows = $ImpDeps | Where-Object { $_.Carpeta -eq $f }
    $pkgs = ($rows | ForEach-Object { $_.Pkg } | Sort-Object -Unique)
    $heavyList = @()
    foreach ($p in $pkgs) { if ($Heavy[$p]) { $heavyList += ($p + ' (' + $Heavy[$p] + ')') } }
    Add-Line ("- **" + $f + "**: " + $pkgs.Count + " paquetes de terceros")
    if ($heavyList.Count -eq 0) {
        Add-Line "      Nada pesado ni delicado detectado."
    } else {
        foreach ($h in $heavyList) { Add-Line ("      PESADO: " + $h) }
    }
}
Add-Line ""

# --------------------------------------------------------------------------
# Tabla resumen
# --------------------------------------------------------------------------

Add-Line "## Tabla resumen"
Add-Line ""
Add-Line "| Carpeta | Rol | venv propio | Interprete actual | # paquetes | Playwright | Lanzador |"
Add-Line "|---|---|---|---|---|---|---|"
foreach ($s in $Summary) {
    Add-Line ("| " + $s.Carpeta + " | " + $s.Rol + " | " + $s.Venv + " | " + $s.Interprete + " | " + $s.NPaquetes + " | " + $s.Playwright + " | " + $s.Lanzador + " |")
}
Add-Line ""

# --------------------------------------------------------------------------
# Candidata mas simple
# --------------------------------------------------------------------------

Add-Line "## Candidata mas simple para aislar primero (dato, no recomendacion de accion)"
Add-Line ""
$rank = @()
foreach ($f in $TargetFolders) {
    $row = $Summary | Where-Object { $_.Carpeta -eq $f } | Select-Object -First 1
    if (-not $row) { continue }
    if ($row.NPaquetes -eq '-') { continue }
    $rows = $ImpDeps | Where-Object { $_.Carpeta -eq $f }
    $pkgs = ($rows | ForEach-Object { $_.Pkg } | Sort-Object -Unique)
    $nHeavy = 0
    foreach ($p in $pkgs) { if ($Heavy[$p]) { $nHeavy = $nHeavy + 1 } }
    $rank += [pscustomobject]@{ Carpeta=$f; N=[int]$pkgs.Count; Heavy=$nHeavy; Browser=$row.Playwright }
}
$ordered = $rank | Sort-Object Heavy, N
if ($ordered -and $ordered.Count -gt 0) {
    $best = $ordered[0]
    Add-Line ("Mas simple: **" + $best.Carpeta + "** - " + $best.N + " paquetes de terceros, " + $best.Heavy + " pesados, Playwright: " + $best.Browser + ".")
    Add-Line "Orden completo de menor a mayor complejidad:"
    foreach ($o in $ordered) {
        Add-Line ("  " + $o.Carpeta.PadRight(24) + " paquetes=" + $o.N + "  pesados=" + $o.Heavy + "  playwright=" + $o.Browser)
    }
} else {
    Add-Line "No hay datos suficientes para ordenar las carpetas."
}
Add-Line ""
Add-Line "FIN DEL RELEVAMIENTO. No se modifico nada."

# --------------------------------------------------------------------------
if (-not $NoFile) {
    $script:R | Out-File -FilePath $OutFile -Encoding UTF8
    Write-Host ""
    Write-Host ("Reporte guardado en: " + $OutFile) -ForegroundColor Green
}

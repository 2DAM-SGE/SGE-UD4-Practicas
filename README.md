# 🍺 UD04-Act01: Digitalizando la Taberna de Mou

**Lo que vamos a usar:** Odoo 18 (Docker) en Ubuntu 24.04 (AWS Academy)  
**Herramientas:** VS Code (Remote SSH), Git (con llaves SSH, nada de contraseñas)

---

### 📜 ¿De qué va esto?

¡**Moe Szyslak** se ha cansado de vivir en el pasado! Ha alquilado un servidor en la nube (AWS Academy) para que Barney deje de tropezarse con los cables cada vez que pide una cerveza. Todo el sistema va a correr sobre un contenedor **Odoo 18 con localización española**.

Pero antes de ponernos a picar código para controlar el bar, tenemos que dejar listo tu entorno de desarrollo (VS Code) y blindar la conexión con GitHub usando SSH. ¡No queremos que los espías de Shelbyville nos roben el código!

---

## 🛠️ Fase 0: Preparando el Chiringuito

Antes de nada, vamos a dejar listo el terreno en tu instancia de AWS.

### 1. Conéctate con VS Code (¡Adiós terminal sosa!)

Olvídate de programar en una terminal aburrida. Vamos a conectar tu VS Code local directo al servidor usando la extensión **"Remote - SSH"**.

**Cómo configurarlo:**

1. Pulsa `F1` y busca **Remote-SSH: Open SSH Configuration File**.
2. Pega esto por ahí (acuérdate de cambiar la ruta de tu clave):

```ssh
Host TabernaMoeAWS
    # ⚠️ ¡OJO! En AWS Academy la IP cambia cada vez que reinicias.
    # Acuérdate de actualizarla aquí antes de conectar.
    HostName IP_ACTUAL_DE_TU_INSTANCIA
    User ubuntu

    # --- TEMA CLAVES (Descomenta solo la tuya) ---

    # ¿Eres de WINDOWS? (Usa doble barra invertida \\)
    # IdentityFile "C:\\Users\\TuUsuario\\Downloads\\vockey.pem"

    # ¿LINUX o MAC? (Ruta normalita)
    # IdentityFile "~/Downloads/vockey.pem"
```

### 2. Configura GitHub con SSH (Seguridad a tope)

Moe no se fía ni un pelo, así que pasamos de contraseñas. Vamos a usar llaves SSH para hacer `git push` sin líos.

**A. Crea tus llaves:**
Abre la terminal de VS Code (ya conectado a AWS) y dale a esto:

```bash
ssh-keygen -t rsa -b 4096
# Cuando te pida nombre pon: /home/ubuntu/.ssh/github
# Passphrase: Dale al Enter dos veces (vacío)
```

**B. El archivo de configuración:**
Escribe `nano ~/.ssh/config` y pega esto dentro:

```ssh
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
```

**C. Súbela a GitHub:**
1. Muestra tu llave pública para copiarla:
   ```bash
   cat ~/.ssh/github.pub
   ```
2. Copia todo ese texto raro que empieza por `ssh-rsa...`.
3. Vete a [GitHub.com](https://github.com) > **Settings** > **SSH and GPG keys** > **New SSH key** y pégala ahí.

**D. Tráete el repositorio (Clonar):**
```bash
cd ~
# ¡Pon tu usuario y siglas de verdad!
git clone git@github.com:tu-usuario/SGE-Pract-tusSIGLAS.git
cd SGE-Pract-tusSIGLAS/UD4.Creación
```

---

## 🧱 Tarea 1: Poniendo la primera piedra

Vamos a crear un modulito muy básico solo para ver que Odoo se entera de que estamos ahí.

1. En tu repo, crea una carpeta que se llame `taberna_mou_inicio`.
2. Dentro, crea un archivo `__init__.py` (déjalo vacío, no pasa nada).
3. Crea otro archivo llamado `__manifest__.py` y ponle esto:

```python
{
    'name': 'Módulo 01 Taberna de Mou',
    'summary': 'Probando que esto conecta',
    'description': 'Módulo de prueba para ver que Barney no ha roto nada todavía.',
    'author': 'Tu Nombre',
    'category': 'Productivity',
    'version': '0.1',
    'depends': ['base'],
    'data': [],
}
```

✅ **¿Funciona?** Reinicia el contenedor de Odoo, actualiza la lista de apps e instala el módulo. Si sale como "Instalado", ¡triunfada!

---

## 📊 Tarea 2: Controlando la Barra

Ahora sí, vamos a lo serio: una app para gestionar los líos de los clientes.

### 1. Los Datos (`models.py`)
Define una clase `TabernaIncidencia` (con name = `'taberna.incidencia'`) y estos campos:

* `cliente` (Char): Quién es (ej: Homer).
* `descripcion` (Char): Qué está pasando.
* `nivel_alcohol` (Integer): Un número para saber cómo va.
* `expulsar` (Boolean): **Esto se calcula solo**.
* `pagado` (Boolean): ¿Ha soltado la pasta?

### 2. Las Reglas del Juego (`models.py`)
Haz la función *compute* para el campo `expulsar`. **La Ley Seca de Moe:**

```python
@api.depends('nivel_alcohol')
def _calcular_expulsion(self):
    for registro in self:
        # Si se pasa de 10 copas... ¡a la calle!
        if registro.nivel_alcohol > 10:
            registro.expulsar = True
        else:
            registro.expulsar = False
```

### 3. Lo que se ve (`views.xml`)
Crea la interfaz en XML:
* **Menú Principal:** Que se llame "Taberna de Mou".
* **La Lista:** Que se vean las columnas: Cliente, Nivel Alcohol, Expulsar (checkbox) y Pagado.

---

## ⚠️ ¡OJO! NO PIERDAS TU TRABAJO (BACKUP)

Antes de cerrar el chiringuito o apagar la instancia de AWS, **haz una copia de seguridad**.

1. Entra en `http://tu-ip:8069/web/database/manager`.
2. Elige tu base de datos y dale a **"Backup"**.
3. Bájate el `.zip`.

> *Si pasas de hacer esto, perderás todos los datos de prueba cuando reinicies. ¡Avisado quedas!*

---

## 📦 Checklist para entregar

Para que Moe no pierda dinero, asegúrate de que tu repo en GitHub tiene **EXACTAMENTE** esta pinta:

```text
Carpeta Raíz del Repositorio/UD4.Creación/
├── taberna_mou_inicio/      <-- Lo de la Tarea 1
│   ├── __init__.py
│   └── __manifest__.py
└── gestion_barra/           <-- Lo de la Tarea 2
    ├── __init__.py
    ├── __manifest__.py
    ├── models.py            (Con la lógica de echar gente)
    └── views.xml            (Los menús y listas)
```

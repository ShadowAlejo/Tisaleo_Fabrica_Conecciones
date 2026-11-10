# CodeIgniter 4 Framework

## What is CodeIgniter?

CodeIgniter is a PHP full-stack web framework that is light, fast, flexible and secure.
More information can be found at the [official site](https://codeigniter.com).

This repository holds the distributable version of the framework.
It has been built from the
[development repository](https://github.com/codeigniter4/CodeIgniter4).

More information about the plans for version 4 can be found in [CodeIgniter 4](https://forum.codeigniter.com/forumdisplay.php?fid=28) on the forums.

You can read the [user guide](https://codeigniter.com/user_guide/)
corresponding to the latest version of the framework.

## Important Change with index.php

`index.php` is no longer in the root of the project! It has been moved inside the *public* folder,
for better security and separation of components.

This means that you should configure your web server to "point" to your project's *public* folder, and
not to the project root. A better practice would be to configure a virtual host to point there. A poor practice would be to point your web server to the project root and expect to enter *public/...*, as the rest of your logic and the
framework are exposed.

**Please** read the user guide for a better explanation of how CI4 works!

## Repository Management

We use GitHub issues, in our main repository, to track **BUGS** and to track approved **DEVELOPMENT** work packages.
We use our [forum](http://forum.codeigniter.com) to provide SUPPORT and to discuss
FEATURE REQUESTS.

This repository is a "distribution" one, built by our release preparation script.
Problems with it can be raised on our forum, or as issues in the main repository.

## Contributing

We welcome contributions from the community.

Please read the [*Contributing to CodeIgniter*](https://github.com/codeigniter4/CodeIgniter4/blob/develop/CONTRIBUTING.md) section in the development repository.

## Server Requirements

PHP version 8.2 or higher is required, with the following extensions installed:

- [intl](http://php.net/manual/en/intl.requirements.php)
- [mbstring](http://php.net/manual/en/mbstring.installation.php)

> [!WARNING]
> - The end of life date for PHP 7.4 was November 28, 2022.
> - The end of life date for PHP 8.0 was November 26, 2023.
> - The end of life date for PHP 8.1 was December 31, 2025.
> - If you are still using below PHP 8.2, you should upgrade immediately.
> - The end of life date for PHP 8.2 will be December 31, 2026.

Additionally, make sure that the following extensions are enabled in your PHP:

- json (enabled by default - don't turn it off)
- [mysqlnd](http://php.net/manual/en/mysqlnd.install.php) if you plan to use MySQL
- [libcurl](http://php.net/manual/en/curl.requirements.php) if you plan to use the HTTP\CURLRequest library

## Acceso y bases por emprendimiento

La autenticación vive en la base central `usuarios_tisaleo`. Los 26 emprendimientos tienen cada uno una base operativa independiente en el mismo servidor MySQL; la columna `emprendimientos.database_key` identifica una base permitida. Las cuentas de la hoja de usuarios inician sesión con usuario y contraseña, tienen rol `propietario` y deben cambiar la contraseña al primer acceso.

### Instalación y conexión en el host

1. Crea la base central `usuarios_tisaleo` y, para una instalación nueva, importa [`database/usuarios_tisaleo.sql`](./database/usuarios_tisaleo.sql). Luego importa [`database/inserciones.sql`](./database/inserciones.sql) para registrar los roles y los 26 emprendimientos. No vuelvas a importar el esquema sobre una base que ya tenga datos: el script elimina y recrea tablas.
2. Solo para una instalación nueva, importa [`database/emprendimientos_tisal.sql`](./database/emprendimientos_tisal.sql) con una cuenta MySQL que pueda crear bases. El script crea las 26 bases `db_emp_*` y elimina/recrea las tablas si ya existen: **no lo ejecutes sobre bases con datos que quieras conservar**. Cada base debe tener el esquema de negocio esperado (productos, servicios, ventas, detalles, movimientos e imágenes).
3. En el host, copia `env` a `.env` y configura `database.default.hostname`, `database.default.database = usuarios_tisaleo`, `database.default.username`, `database.default.password` y `database.default.port` con la conexión central del proveedor.
4. En el `.env` privado del host define `TISALEO_DB_USER_<SUFIJO>` y `TISALEO_DB_PASSWORD_<SUFIJO>` para cada negocio, usando el usuario MySQL propio de cada base. Los sufijos y nombres de variable están listados en [`env`](./env). El host y puerto de conexión son compartidos desde `database.default`; `TISALEO_DB_ACCOUNT_HOST` indica el host de las cuentas MySQL y por defecto es `localhost`. La aplicación fija los nombres permitidos y no acepta nombres de base enviados desde formularios. No pongas estas claves en Git, tickets ni chats.
5. Si faltan bases operativas, ejecuta `php spark tenants:create-missing-schemas`. El comando crea las bases y tablas faltantes con `IF NOT EXISTS`; no elimina tablas ni datos. Luego ejecuta desde la carpeta del proyecto:

   ```sh
   php spark migrate
   php spark db:seed AdminSeeder
   php spark tenants:create-missing-schemas
   php spark tenants:provision-users
   php spark tenants:migrate
   ```

   `tenants:create-missing-schemas` y `tenants:provision-users` requieren que la cuenta central tenga permisos para crear bases/tablas y usuarios MySQL, respectivamente. El segundo crea usuarios faltantes y concede permisos de lectura, escritura y cambios de esquema solo sobre la base de cada negocio; no cambia la contraseña de un usuario MySQL que ya exista. Si un usuario existente tiene otra contraseña, sincronízala desde el panel MySQL con el valor privado de `.env`. Configura `TISALEO_OWNER_EMAIL` y `TISALEO_OWNER_PASSWORD` (8 a 10 caracteres) en el `.env` para crear al administrador global. El administrador guarda `usuario = Administrador`, nombre y apellido vacíos, y usa `TISALEO_OWNER_EMAIL` para iniciar sesión. Si ya existe, vuelve a ejecutar `php spark db:seed AdminSeeder` para sincronizar esos campos sin cambiar su contraseña. `tenants:migrate` actualiza de forma aditiva las bases operativas asignadas en la central, incluyendo la columna de categoría de productos si falta.

6. Prepara un CSV UTF-8 con las columnas `Nombre del Emprendimiento`, `Usuario`, `Contraseña` y `Correos`. `Usuario` se guarda en `usuarios.usuario`, `Correos` en `usuarios.correo`, y el campo `nombre` de usuario queda vacío. No incluyas `Usuario_bd` ni `Contrasenia_bd`. Sube el archivo temporal al host por un canal privado, fuera de `public/`, y ejecuta:

   ```sh
   php spark users:import-emprendimientos /ruta/privada/usuarios.csv
   ```

   El comando valida que cada emprendimiento y correo existan, guarda hashes de contraseña (nunca texto plano) y crea los propietarios de forma transaccional. Si se ejecuta otra vez, actualiza el correo y conserva las contraseñas de las cuentas existentes. El inicio de sesión usa el correo de `Correos` y la contraseña. Elimina el CSV temporal del host después de la importación. Las contraseñas iniciales se cambian al primer acceso.

Para desarrollo adicional, las consultas de productos, servicios y ventas deben usar `tenant_db()`; no la conexión central predeterminada. El rol `admin` puede acceder a todos los emprendimientos, `propietario` solo al suyo y `empleado` tiene acceso operativo limitado. Las nuevas claves de usuario aceptan entre 8 y 72 caracteres.

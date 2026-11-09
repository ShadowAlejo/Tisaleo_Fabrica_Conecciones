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

Separa la autenticación y los datos operativos:

- `sistema_emprendimientos_tisal`: base central con `roles`, `usuarios`, `emprendimientos` y sus permisos. Cada emprendimiento guarda su categoría directamente en `emprendimientos.categoria` (`VARCHAR(100)`); `database_key` identifica la conexión operativa.
- `tisaleo_don_goyo`: datos operativos de Turrones Don Goyo.
- `tisaleo_razu_corp`: datos operativos de RaZu.
- `tisaleo_dulce_mora`: datos operativos de Bodega G&A "Dulce Mora".

Preparación en Laragon/MySQL:

1. Para una instalación nueva, importa `database/sistema_emprendimientos_tisal.sql` en `sistema_emprendimientos_tisal`. Esa base es la única que usa el login para consultar usuarios y permisos. El SQL crea los tres emprendimientos, el administrador y las cuentas de propietario y empleado de cada uno. Si la base ya existía, importa solo `database/crear_administrador.sql` para crear el administrador sin modificar los demás datos. Para actualizar una base existente que todavía usa `categoria_id`, respalda la base e importa una vez `database/migrar_categoria_emprendimientos.sql` en phpMyAdmin; el script conserva los nombres actuales. En instalaciones antiguas importadas desde SQL, importa también una vez `database/agregar_descripcion_emprendimientos.sql`. En instalaciones administradas por migraciones, `php spark migrate` aplica los cambios.
2. Crea `tisaleo_don_goyo`, `tisaleo_razu_corp` y `tisaleo_dulce_mora`, con cotejamiento `utf8mb4_unicode_ci`.
3. Selecciona cada base operativa en phpMyAdmin e importa `database/tenant_schema.sql`. El archivo no cambia de base por sí solo: importa el mismo esquema, por separado, en cada base seleccionada. Los `usuario_id` apuntan a IDs de la base central y no usan claves foráneas entre bases.
4. Copia `env` como `.env`. Configura `database.default.hostname`, `database.default.database = sistema_emprendimientos_tisal`, `database.default.username`, `database.default.password` y `database.default.port`. Define también `TISALEO_DB_DON_GOYO=tisaleo_don_goyo`, `TISALEO_DB_RAZU=tisaleo_razu_corp` y `TISALEO_DB_DULCE_MORA=tisaleo_dulce_mora`. Los tres grupos operativos usan las mismas credenciales MySQL que la base central.
5. Define `TISALEO_OWNER_EMAIL` y `TISALEO_OWNER_PASSWORD` (de 8 a 10 caracteres) en `.env`; estas variables corresponden al administrador global. No compartas ni subas ese archivo.
6. Si la base central existente se administra con migraciones, ejecuta `php spark migrate`. Si la creaste importando el SQL anterior, no lo ejecutes sobre esa base. Ejecuta `php spark db:seed AdminSeeder` y `php spark db:seed PropietariosSeeder`; este último crea o vincula los tres emprendimientos y sus propietarios. Luego ejecuta `php spark tenants:migrate` y `php spark db:seed CuentasEmpleadosSeeder`. Las cuentas iniciales de propietario y empleado también deben cambiar su contraseña al primer acceso. En una base que ya tenía esas cuentas, vuelve a ejecutar ambos seeders: marcarán el cambio obligatorio solo si la contraseña todavía coincide con la configurada en `.env`.

`PropietariosSeeder` crea o vincula los tres emprendimientos y asigna cada cuenta propietaria únicamente a su negocio. El login valida la contraseña contra la base central, y el selector activa la conexión correspondiente a la base operativa. Para futuras consultas y escrituras de negocio, usa `tenant_db()`; no uses la conexión central predeterminada para productos, servicios o ventas. Los catálogos, el punto de venta, el perfil del negocio y el equipo usan conexiones y permisos del negocio activo. Las ventas descuentan inventario dentro de una transacción y guardan sus movimientos de inventario. `tenants:migrate` actualiza las tres bases operativas de forma aditiva.

El sistema usa tres roles: `admin` accede a todos los emprendimientos y al resumen/directorio administrativo; `propietario` solo al emprendimiento asignado y puede administrar su equipo; `empleado` solo a su emprendimiento y no puede acceder al apartado de empleados. El administrador puede cambiar entre emprendimientos desde el selector superior.

Para asociar una imagen WebP ya copiada en `public/uploads/productos/` a un producto existente, ejecuta `php spark tenant:image-product razu "Vino artesanal RAZU" uploads/productos/vino.webp`. El comando comprueba el tenant autorizado, el producto, la ruta pública y el tipo de archivo antes de guardar la asociación en `imagenes`.

Al crear empleados desde el panel, el sistema genera una contraseña temporal aleatoria y la muestra una sola vez; la cuenta debe cambiarla en el primer acceso. El alta de negocios desde administración solo está disponible mientras exista una base operativa preconfigurada y todavía no asignada.

Para cambiar posteriormente la clave del administrador, edita `TISALEO_OWNER_PASSWORD` en `.env` con una clave nueva (8 a 10 caracteres) y ejecuta `php spark db:seed ActualizarClaveAdminSeeder`. Este seeder cambia el hash de la cuenta activa indicada por `TISALEO_OWNER_EMAIL`; no crea usuarios. Mantén `.env` privado.

Para crear un propietario independiente por negocio, configura `TISALEO_OWNER_DON_GOYO_EMAIL`/`PASSWORD`, `TISALEO_OWNER_RAZU_EMAIL`/`PASSWORD` y `TISALEO_OWNER_DULCE_MORA_EMAIL`/`PASSWORD` en `.env` (contraseñas de 8 a 10 caracteres). Ejecuta `php spark db:seed PropietariosSeeder`. Cada propietario queda asociado únicamente a su emprendimiento; las cuentas ya existentes conservan su contraseña.

Para crear una cuenta de empleado distinta para cada negocio, configura `TISALEO_STAFF_DON_GOYO_PASSWORD`, `TISALEO_STAFF_RAZU_PASSWORD` y `TISALEO_STAFF_DULCE_MORA_PASSWORD` en `.env` (8 a 10 caracteres cada una). Los correos locales por defecto son `empleado.dongoyo@tisaleo.local`, `empleado.razu@tisaleo.local` y `empleado.dulcemora@tisaleo.local`; puedes sobreescribirlos con las variables `TISALEO_STAFF_*_EMAIL`. Ejecuta `php spark db:seed CuentasEmpleadosSeeder`. Cada cuenta queda asignada solo a su negocio y las cuentas ya existentes no cambian de contraseña. El empleado inicia en el mismo panel y ve los mismos módulos de su negocio que el propietario; su sesión solo contiene el negocio que tiene asignado.

Al añadir emprendimientos, agrega una clave fija en `App\Libraries\TenantDatabase`, una variable de entorno para su base y la asociación desde la base central. Nunca recibas nombres de bases de datos del formulario.

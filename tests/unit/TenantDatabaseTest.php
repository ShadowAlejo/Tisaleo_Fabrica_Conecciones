<?php

use App\Libraries\TenantDatabase;
use CodeIgniter\Database\BaseConnection;
use CodeIgniter\Test\CIUnitTestCase;
use Config\Database;

/**
 * @internal
 */
final class TenantDatabaseTest extends CIUnitTestCase
{
    private BaseConnection $centralDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->centralDatabase = Database::connect('tests', false);
        $this->centralDatabase->query(
            'CREATE TABLE emprendimientos ('
            . 'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            . 'database_key VARCHAR(64) NOT NULL, '
            . 'activo INTEGER NOT NULL, '
            . 'fec_eliminacion DATETIME NULL'
            . ')',
        );
        $this->centralDatabase->table('emprendimientos')->insert([
            'database_key' => 'db_emp_calzado_john',
            'activo' => 1,
            'fec_eliminacion' => null,
        ]);
    }

    protected function tearDown(): void
    {
        (new TenantDatabase($this->centralDatabase))->closeIdleConnections(time() + 601);
        $this->centralDatabase->close();

        parent::tearDown();
    }

    public function testConnectionForKeyRejectsMalformedDatabaseNames(): void
    {
        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('no es válido');

        (new TenantDatabase($this->centralDatabase))->connectionForKey('db_emp_valid; DROP DATABASE usuarios_tisaleo');
    }

    public function testConnectionForKeyRejectsUnregisteredDatabaseNames(): void
    {
        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('no está registrada ni autorizada');

        (new TenantDatabase($this->centralDatabase))->connectionForKey('db_emp_unregistered');
    }

    public function testConnectionForKeyReusesRegisteredTenantConnection(): void
    {
        $factory = new TenantDatabase($this->centralDatabase);

        $first = $factory->connectionForKey('db_emp_calzado_john');
        $second = $factory->connectionForKey('db_emp_calzado_john');

        $this->assertSame($first, $second);
        $this->assertSame('db_emp_calzado_john', $first->database);
        $this->assertSame(config(Database::class)->tests['username'], $first->username);

        $factory->closeIdleConnections(time() + 601);
        $afterIdleTimeout = $factory->connectionForKey('db_emp_calzado_john');

        $this->assertNotSame($first, $afterIdleTimeout);
    }
}

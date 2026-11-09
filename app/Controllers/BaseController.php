<?php

namespace App\Controllers;

use CodeIgniter\Controller;
use CodeIgniter\HTTP\CLIRequest;
use CodeIgniter\HTTP\IncomingRequest;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Psr\Log\LoggerInterface;

/**
 * BaseController provides a convenient place for loading components
 * and performing functions that are needed by all your controllers.
 *
 * Extend this class in any new controllers:
 * ```
 *     class Home extends BaseController
 * ```
 *
 * For security, be sure to declare any new methods as protected or private.
 */
abstract class BaseController extends Controller
{
    protected $helpers = ['form', 'tenant', 'url'];

    protected string $role = 'propietario';

    protected function renderPage(
        string $view,
        string $title,
        string $activeMenu,
        string $description = '',
        array $data = [],
    ): string {
        $authenticatedRole = session('auth_user')['role'] ?? null;
        $pageRole = $authenticatedRole === 'admin' || $this->role === 'admin'
            ? 'admin'
            : (in_array($authenticatedRole, ['propietario', 'empleado'], true) ? $authenticatedRole : $this->role);

        return view($view, array_merge([
            'role' => $pageRole,
            'pageTitle' => $title,
            'activeMenu' => $activeMenu,
            'pageDescription' => $description,
        ], $data));
    }

    protected function catalogEnabled(string $catalog): bool
    {
        $businessId = (int) session('current_business_id');
        foreach (session('auth_businesses') ?? [] as $business) {
            if ((int) ($business['id'] ?? 0) === $businessId) {
                return (bool) ($business['usa_' . $catalog] ?? false);
            }
        }

        return false;
    }

    /**
     * @param list<string> $fields
     */
    protected function validatePostScalars(array $fields): bool
    {
        foreach ($fields as $field) {
            $value = $this->request->getPost($field);
            if ($value !== null && ! is_string($value)) {
                $this->validator->setError($field, 'El valor indicado no es válido.');

                return false;
            }
        }

        return true;
    }

    /**
     * Be sure to declare properties for any property fetch you initialized.
     * The creation of dynamic property is deprecated in PHP 8.2.
     */

    // protected $session;

    /**
     * @param CLIRequest|IncomingRequest $request
     *
     * @return void
     */
    public function initController(RequestInterface $request, ResponseInterface $response, LoggerInterface $logger)
    {
        // Load here all helpers you want to be available in your controllers that extend BaseController.
        // Caution: Do not put the this below the parent::initController() call below.
        // $this->helpers = ['form', 'url'];

        // Caution: Do not edit this line.
        parent::initController($request, $response, $logger);

        // Preload any models, libraries, etc, here.
        // $this->session = service('session');
    }
}

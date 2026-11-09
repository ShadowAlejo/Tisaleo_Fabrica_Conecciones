<?= $this->extend('layouts/sistema') ?>
<?= $this->section('content') ?>
<?php if (($errors ?? []) !== []): ?><div class="alert alert-danger" role="alert"><?= esc(implode(' ', $errors)) ?></div><?php endif ?>
<form method="post" action="<?= site_url($routePrefix . '/ventas') ?>" id="sale-form">
    <?= csrf_field() ?>
    <div class="row g-3">
        <section class="card p-3 col-12 col-lg-7">
            <div class="panel-heading"><div><h2>Catálogo</h2><p>Productos y servicios disponibles en este negocio</p></div></div>
            <div class="row g-2 align-items-end mb-3">
                <div class="col"><label class="form-label" for="catalog-item">Artículo</label>
                    <select class="form-select" id="catalog-item"><option value="">Selecciona un artículo</option>
                        <?php foreach ($productos as $producto): ?>
                            <option value="producto:<?= (int) $producto['id'] ?>" data-name="<?= esc($producto['nombre'], 'attr') ?>" data-price="<?= esc($producto['precio'], 'attr') ?>" data-stock="<?= esc($producto['cantidad'], 'attr') ?>"><?= esc($producto['nombre']) ?> — $<?= number_format((float) $producto['precio'], 2, ',', '.') ?> (Stock: <?= number_format((float) $producto['cantidad'], 2, ',', '.') ?>)</option>
                        <?php endforeach ?>
                        <?php foreach ($servicios as $servicio): ?>
                            <option value="servicio:<?= (int) $servicio['id'] ?>" data-name="<?= esc($servicio['nombre'], 'attr') ?>" data-price="<?= esc($servicio['precio'], 'attr') ?>" data-stock=""><?= esc($servicio['nombre']) ?> — $<?= number_format((float) $servicio['precio'], 2, ',', '.') ?> (Servicio)</option>
                        <?php endforeach ?>
                    </select>
                </div>
                <div class="col-auto"><label class="form-label" for="item-quantity">Cantidad</label><input class="form-control" id="item-quantity" type="text" inputmode="decimal" min="0,01" max="999999" step="0,01" value="1,00"></div>
                <div class="col-auto"><button class="btn btn-outline-success" type="button" id="add-item">Agregar</button></div>
            </div>
            <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Artículo</th><th>Cantidad</th><th>Precio</th><th>Subtotal</th><th></th></tr></thead><tbody id="sale-items"><tr><td colspan="5" class="text-body-secondary">El ticket está vacío.</td></tr></tbody></table></div>
        </section>
        <section class="card p-3 col-12 col-lg-5">
            <div class="panel-heading"><div><h2>Ticket</h2><p id="item-count">0 artículos</p></div></div>
            <div class="d-grid gap-2"><label class="form-label" for="payment-method">Medio de cobro</label><select class="form-select" id="payment-method" name="metodo_pago" required><option value="">Seleccionar medio</option><option value="efectivo">Efectivo</option><option value="transferencia">Transferencia</option><option value="mixto">Mixto</option></select></div>
            <label class="form-label mt-3" for="sale-total">Total (calculado nuevamente al guardar)</label><input class="form-control" id="sale-total" value="$ 0,00" readonly>
            <button class="btn btn-success mt-3" type="submit" id="confirm-sale" disabled>Confirmar venta</button>
            <p class="form-hint mt-2">El precio y el stock se comprueban en el servidor antes de registrar cada venta.</p>
        </section>
    </div>
</form>
<script>
(() => {
    const select = document.getElementById('catalog-item');
    const quantity = document.getElementById('item-quantity');
    const body = document.getElementById('sale-items');
    const total = document.getElementById('sale-total');
    const confirmButton = document.getElementById('confirm-sale');
    const items = [];
    const decimalFormat = new Intl.NumberFormat('es-EC', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    const money = cents => '$ ' + decimalFormat.format(cents / 100);
    const render = () => {
        document.querySelectorAll('#sale-form input[name^="items["]').forEach(input => input.remove());
        body.replaceChildren();
        let sum = 0;
        if (items.length === 0) {
            const row = body.insertRow();
            const cell = row.insertCell();
            cell.colSpan = 5;
            cell.textContent = 'El ticket está vacío.';
        }
        items.forEach((item, index) => {
            const row = body.insertRow();
            const amountCents = Math.round(Math.round(item.quantity * 100) * Math.round(item.price * 100) / 100);
            sum += amountCents;
            row.insertCell().textContent = item.name;
            row.insertCell().textContent = decimalFormat.format(item.quantity);
            row.insertCell().textContent = money(Math.round(item.price * 100));
            row.insertCell().textContent = money(amountCents);
            const action = row.insertCell();
            const remove = document.createElement('button');
            remove.type = 'button';
            remove.className = 'btn btn-sm btn-outline-danger';
            remove.textContent = 'Quitar';
            remove.addEventListener('click', () => { items.splice(index, 1); render(); });
            action.append(remove);
            [['tipo', item.type], ['id', item.id], ['cantidad', item.quantity]].forEach(([key, value]) => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = `items[${index}][${key}]`;
                input.value = value;
                document.getElementById('sale-form').append(input);
            });
        });
        total.value = money(sum);
        document.getElementById('item-count').textContent = `${items.length} artículo(s)`;
        confirmButton.disabled = items.length === 0;
    };
    document.getElementById('add-item').addEventListener('click', () => {
        const option = select.selectedOptions[0];
        const [type, id] = select.value.split(':');
        const countText = quantity.value.trim().replace(',', '.');
        if (!/^\d+(?:\.\d{1,2})?$/.test(countText)) {
            window.alert('Ingresa una cantidad con hasta dos decimales, por ejemplo 1,50.');
            return;
        }
        const count = Math.round(Number(countText) * 100) / 100;
        if (!type || !id || !Number.isFinite(count) || count <= 0) return;
        if (type === 'producto' && count > Number(option.dataset.stock)) {
            window.alert('La cantidad supera las existencias disponibles.');
            return;
        }
        const existing = items.find(item => item.type === type && item.id === id);
        if (existing) {
            const combined = Math.round((existing.quantity + count) * 100) / 100;
            if (type === 'producto' && combined > Number(option.dataset.stock)) {
                window.alert('La cantidad supera las existencias disponibles.');
                return;
            }
            existing.quantity = combined;
        } else {
            items.push({type, id, name: option.dataset.name, price: Number(option.dataset.price), quantity: count});
        }
        render();
    });
})();
</script>
<?= $this->endSection() ?>

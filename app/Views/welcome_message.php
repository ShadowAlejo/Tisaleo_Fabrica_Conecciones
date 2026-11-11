<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Sistema Web de Gestión Comercial, Inventario y Analítica para los emprendimientos del Cantón Tisaleo.">
    <meta name="theme-color" content="#f6f8f2">
    <title>Tisaleo Emprende | Gestión que impulsa</title>
    <style>
        :root {
            color-scheme: light;
            font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            color: #172d25;
            background: #f6f8f2;
            font-synthesis: none;
            text-rendering: optimizeLegibility;
            -webkit-font-smoothing: antialiased;
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-width: 320px;
            min-height: 100vh;
            margin: 0;
        }

        a {
            color: inherit;
        }

        .page {
            width: min(1120px, calc(100% - 48px));
            margin: 0 auto;
        }

        header {
            display: flex;
            min-height: 88px;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #e5e9df;
        }

        .brand {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            font-size: 1rem;
            font-weight: 750;
            letter-spacing: -.03em;
            text-decoration: none;
        }

        .brand-mark {
            display: grid;
            width: 40px;
            height: 40px;
            place-items: center;
            border-radius: 13px;
            background: #1d5b41;
            color: #f7f6e8;
            font-size: .85rem;
            letter-spacing: -.04em;
        }

        .location {
            color: #68776d;
            font-size: .9rem;
        }

        .hero {
            display: grid;
            min-height: 570px;
            grid-template-columns: 1.15fr .85fr;
            align-items: center;
            gap: 52px;
            padding: 72px 0 64px;
        }

        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            margin: 0 0 24px;
            color: #397454;
            font-size: .77rem;
            font-weight: 750;
            letter-spacing: .13em;
            text-transform: uppercase;
        }

        .eyebrow::before {
            width: 22px;
            height: 1px;
            background: currentColor;
            content: "";
        }

        h1 {
            max-width: 660px;
            margin: 0;
            font-size: clamp(2.8rem, 6vw, 5rem);
            font-weight: 730;
            letter-spacing: -.075em;
            line-height: 1.02;
        }

        h1 span {
            color: #4a805e;
        }

        .intro {
            max-width: 560px;
            margin: 24px 0 32px;
            color: #617168;
            font-size: clamp(1.02rem, 1.6vw, 1.15rem);
            line-height: 1.75;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 18px;
        }

        .button {
            display: inline-flex;
            min-height: 52px;
            align-items: center;
            justify-content: center;
            gap: 12px;
            padding: 0 22px;
            border: 1px solid #1d5b41;
            border-radius: 10px;
            background: #1d5b41;
            color: #fff;
            font-size: .96rem;
            font-weight: 680;
            text-decoration: none;
            transition: background-color 160ms ease, transform 160ms ease;
        }

        .button:hover {
            transform: translateY(-2px);
            background: #174a35;
        }

        .button:focus-visible {
            outline: 3px solid #8fc4a2;
            outline-offset: 3px;
        }

        .button svg {
            width: 18px;
            height: 18px;
        }

        .hero-art {
            position: relative;
            display: grid;
            min-height: 370px;
            place-items: center;
        }

        .hero-art::before {
            position: absolute;
            width: min(100%, 390px);
            aspect-ratio: 1;
            border: 1px solid #dfe8d9;
            border-radius: 50%;
            content: "";
        }

        .hero-art::after {
            position: absolute;
            width: min(78%, 300px);
            aspect-ratio: 1;
            border-radius: 50%;
            background: #e7efdf;
            content: "";
        }

        .dashboard {
            z-index: 1;
            width: min(100%, 340px);
            padding: 22px;
            border: 1px solid rgb(255 255 255 / 80%);
            border-radius: 18px;
            background: rgb(255 255 255 / 94%);
            box-shadow: 0 24px 60px rgb(34 66 44 / 13%);
            transform: rotate(-3deg);
        }

        .dashboard-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 25px;
            color: #6b796e;
            font-size: .76rem;
        }

        .dashboard-top strong {
            color: #203d2e;
            font-size: .83rem;
        }

        .metric {
            margin-bottom: 19px;
        }

        .metric-label {
            display: block;
            margin-bottom: 7px;
            color: #79857b;
            font-size: .74rem;
        }

        .metric strong {
            color: #203d2e;
            font-size: 1.75rem;
            letter-spacing: -.05em;
        }

        .chart {
            display: flex;
            height: 94px;
            align-items: end;
            gap: 9px;
            padding: 0 4px;
            border-bottom: 1px solid #e9eee7;
        }

        .chart span {
            flex: 1;
            border-radius: 5px 5px 0 0;
            background: #b7d4b8;
        }

        .chart span:nth-child(1) { height: 34%; }
        .chart span:nth-child(2) { height: 51%; }
        .chart span:nth-child(3) { height: 43%; }
        .chart span:nth-child(4) { height: 68%; }
        .chart span:nth-child(5) { height: 58%; }
        .chart span:nth-child(6) { height: 82%; background: #548866; }
        .chart span:nth-child(7) { height: 72%; }

        .feature-strip {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1px;
            overflow: hidden;
            border: 1px solid #e4e9df;
            border-radius: 16px;
            background: #e4e9df;
        }

        .feature {
            min-height: 142px;
            padding: 25px 28px;
            background: #fbfcf9;
        }

        .feature-number {
            display: block;
            margin-bottom: 18px;
            color: #598166;
            font-size: .75rem;
            font-weight: 700;
            letter-spacing: .1em;
        }

        .feature h2 {
            margin: 0 0 7px;
            font-size: 1rem;
            letter-spacing: -.02em;
        }

        .feature p {
            margin: 0;
            color: #748077;
            font-size: .86rem;
            line-height: 1.55;
        }

        footer {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            padding: 28px 0;
            color: #7a857c;
            font-size: .8rem;
        }

        @media (max-width: 760px) {
            .page {
                width: min(100% - 36px, 560px);
            }

            header {
                min-height: 72px;
            }

            .location {
                font-size: .78rem;
            }

            .hero {
                min-height: auto;
                grid-template-columns: 1fr;
                gap: 20px;
                padding: 64px 0 42px;
            }

            .hero-art {
                min-height: 320px;
            }

            .feature-strip {
                grid-template-columns: 1fr;
            }

            .feature {
                min-height: 0;
                padding: 20px 24px;
            }

            .feature-number {
                margin-bottom: 10px;
            }
        }

        @media (max-width: 420px) {
            .brand {
                gap: 9px;
                font-size: .9rem;
            }

            .brand-mark {
                width: 36px;
                height: 36px;
            }

            .location {
                max-width: 105px;
                text-align: right;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: .01ms !important;
            }
        }
    </style>
</head>
<body>
    <div class="page">
        <header>
            <a class="brand" href="<?= site_url('/') ?>" aria-label="Tisaleo Emprende, inicio">
                <span class="brand-mark" aria-hidden="true">TE</span>
                <span>Tisaleo Emprende</span>
            </a>
            <span class="location">Cantón Tisaleo · Ecuador</span>
        </header>

        <main>
            <section class="hero" aria-labelledby="welcome-title">
                <div>
                    <p class="eyebrow">Una nueva forma de crecer</p>
                    <h1 id="welcome-title">Gestión clara.<br><span>Negocios que crecen.</span></h1>
                    <p class="intro">
                        Sistema Web de Gestión Comercial, Inventario y Analítica
                        para acompañar e impulsar a los emprendimientos del
                        Cantón Tisaleo.
                    </p>
                    <div class="actions">
                        <a class="button" href="<?= site_url('login') ?>">
                            Ingresar al sistema
                            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                <path d="M5 12h14m-6-6 6 6-6 6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </a>
                    </div>
                </div>

                <div class="hero-art" aria-hidden="true">
                    <div class="dashboard">
                        <div class="dashboard-top">
                            <strong>Resumen del negocio</strong>
                            <span>Este mes</span>
                        </div>
                        <div class="metric">
                            <span class="metric-label">Control en un solo lugar</span>
                            <strong>Tu negocio, en orden</strong>
                        </div>
                        <div class="chart">
                            <span></span><span></span><span></span><span></span>
                            <span></span><span></span><span></span>
                        </div>
                    </div>
                </div>
            </section>

            <section class="feature-strip" aria-label="Herramientas de gestión">
                <article class="feature">
                    <span class="feature-number">01 / VENTAS</span>
                    <h2>Gestión comercial</h2>
                    <p>Organiza las operaciones y acompaña el día a día de tu negocio.</p>
                </article>
                <article class="feature">
                    <span class="feature-number">02 / INVENTARIO</span>
                    <h2>Control de inventario</h2>
                    <p>Mantén productos y existencias bajo control en un mismo lugar.</p>
                </article>
                <article class="feature">
                    <span class="feature-number">03 / ANALÍTICA</span>
                    <h2>Información para crecer</h2>
                    <p>Consulta información útil para tomar mejores decisiones.</p>
                </article>
            </section>
        </main>

        <footer>
            <span>Tecnología al servicio del emprendimiento local.</span>
            <span>Tisaleo, Ecuador</span>
        </footer>
    </div>
</body>
</html>

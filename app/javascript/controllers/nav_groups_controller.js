import { Controller } from '@hotwired/stimulus';

// Los grupos desplegables del menú lateral (y del cajón del teléfono). Los que cada quien cierra se guardan
// en una cookie y no en localStorage: así el servidor ya dibuja el menú como se dejó (NavigationHelper#
// nav_group_open?) y no se ve abrirse y cerrarse en cada cambio de página. El grupo de la página abierta
// siempre llega abierto.
const COOKIE = 'fsy_nav_closed';

export default class extends Controller {
  toggle(event) {
    const group = event.currentTarget.closest('[data-nav-group]');
    const open = group.dataset.open !== 'true';
    group.dataset.open = String(open);
    event.currentTarget.setAttribute('aria-expanded', String(open));

    const closed = new Set(this.closed());
    open ? closed.delete(group.dataset.navGroup) : closed.add(group.dataset.navGroup);
    document.cookie = `${COOKIE}=${[ ...closed ].join('.')}; path=/; max-age=31536000; samesite=lax`;
  }

  closed() {
    const match = document.cookie.match(new RegExp(`(?:^|; )${COOKIE}=([^;]*)`));
    return match && match[1] ? match[1].split('.') : [];
  }
}

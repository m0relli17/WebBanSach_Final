// Auth State Manager - WebBanSach Style
const auth = {
    user: null,
    init: async function() {
        try {
            const data = await api.getMe();
            auth.user = data.isLoggedIn ? data.user : null;
            auth.renderNavbar();
            auth.updateCartBadge();
            if (typeof updateCheckoutAuthPrompt === 'function') {
                updateCheckoutAuthPrompt();
            }
        } catch (e) {
            console.error("Auth init error:", e);
        }
    },

    isLoggedIn: function() {
        return !!auth.user;
    },

    requireLogin: async function(redirectTarget = 'checkout.html') {
        if (!auth.user) {
            try {
                const data = await api.getMe();
                auth.user = data.isLoggedIn ? data.user : null;
            } catch (e) {
                auth.user = null;
            }
        }
        if (!auth.user) {
            showToast("Vui lòng đăng nhập để tiến hành mua hàng.", "warning");
            setTimeout(() => {
                window.location.href = `login.html?redirect=${encodeURIComponent(redirectTarget)}`;
            }, 350);
            return false;
        }
        return true;
    },

    renderNavbar: function() {
        const container = document.getElementById('navbar-auth-links');
        if (!container) return;

        if (auth.user) {
            const displayName = auth.user.name || auth.user.username;
            const isAdmin = auth.user.role === 'Admin' || auth.user.role === 'admin';
            container.innerHTML = `
                <div class="dropdown">
                    <a class="wbs-header-action dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa fa-user-circle fs-5 text-primary"></i>
                        <span class="text-truncate d-none d-sm-inline" style="max-width: 120px;">${displayName}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="userDropdown">
                        <li class="px-3 py-2 border-bottom bg-light">
                            <div class="small text-muted" style="font-size: 11px;">Tài khoản của</div>
                            <strong class="text-dark small">${displayName}</strong>
                        </li>
                        <li><a class="dropdown-item py-2" href="tracking.html"><i class="fa fa-list-alt text-primary me-2"></i> Đơn hàng của tôi</a></li>
                        ${isAdmin ? '<li><a class="dropdown-item py-2" href="admin.html"><i class="fa fa-tachometer text-success me-2"></i> Quản trị Admin</a></li>' : ''}
                        <li><hr class="dropdown-divider my-1"></li>
                        <li><a class="dropdown-item py-2 text-danger" href="#" onclick="auth.handleLogout(event)"><i class="fa fa-sign-out text-danger me-2"></i> Đăng xuất</a></li>
                    </ul>
                </div>
            `;
        } else {
            const currentPath = window.location.pathname.split('/').pop() || 'index.html';
            const search = window.location.search;
            const fullTarget = currentPath + search;
            const isAuthPage = currentPath === 'login.html' || currentPath === 'register.html' || currentPath === 'verify-email.html';
            const redirectParam = isAuthPage ? '' : `?redirect=${encodeURIComponent(fullTarget)}`;

            container.innerHTML = `
                <div class="d-flex align-items-center gap-1 flex-shrink-0">
                    <a href="login.html${redirectParam}" class="wbs-header-action" id="headerLoginBtn">
                        <i class="fa fa-user-circle-o fs-5 text-primary"></i>
                        <span>Đăng nhập</span>
                    </a>
                    <span class="text-muted opacity-50 small">/</span>
                    <a href="register.html${redirectParam}" class="wbs-header-action ps-1" id="headerRegisterBtn">
                        <span>Đăng ký</span>
                    </a>
                </div>
            `;
        }
    },

    updateCartBadge: async function() {
        try {
            const cartData = await api.getCart();
            const badge = document.getElementById('cart-badge');
            if (badge) {
                badge.textContent = cartData.totalQuantity || 0;
            }
        } catch (e) { }
    },

    handleLogout: async function(e) {
        if (e) e.preventDefault();
        await api.logout();
        auth.user = null;
        showToast("Đã đăng xuất thành công");
        setTimeout(() => {
            window.location.href = "index.html";
        }, 600);
    }
};

document.addEventListener("DOMContentLoaded", () => {
    auth.init();
});

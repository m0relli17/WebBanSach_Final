// Auth State Manager
const auth = {
    user: null,
    init: async function() {
        try {
            const data = await api.getMe();
            auth.user = data.isLoggedIn ? data.user : null;
            auth.renderNavbar();
            auth.updateCartBadge();
        } catch (e) {
            console.error("Auth init error:", e);
        }
    },

    renderNavbar: function() {
        const container = document.getElementById('navbar-auth-links');
        if (!container) return;

        if (auth.user) {
            container.innerHTML = `
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-dark fw-bold" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa fa-user-circle text-primary"></i> ${auth.user.name || auth.user.username}
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="userDropdown">
                        <li><a class="dropdown-item" href="tracking.html"><i class="fa fa-list-alt text-muted me-2"></i> Đơn hàng của tôi</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="#" onclick="auth.handleLogout(event)"><i class="fa fa-sign-out text-danger me-2"></i> Đăng xuất</a></li>
                    </ul>
                </li>
            `;
        } else {
            container.innerHTML = `
                <li class="nav-item">
                    <a class="nav-link text-dark" href="login.html"><i class="fa fa-sign-in me-1"></i> Đăng nhập</a>
                </li>
                <li class="nav-item">
                    <a class="btn btn-outline-danger btn-sm ms-2" href="register.html">Đăng ký</a>
                </li>
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

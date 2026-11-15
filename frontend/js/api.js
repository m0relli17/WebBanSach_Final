// API Configuration
const API_BASE = '/api';

const api = {
    // Books & Categories
    getBooks: async function(params = {}) {
        const query = new URLSearchParams(params).toString();
        const res = await fetch(`${API_BASE}/Books?${query}&_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
    },

    getBookDetails: async function(id) {
        const res = await fetch(`${API_BASE}/BookDetails?id=${id}&_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
    },

    getBookReviews: async function(id) {
        const res = await fetch(`${API_BASE}/BookReviews?id=${id}`, { credentials: 'include' });
        return await res.json();
    },

    submitBookReview: async function(bookId, rating, comment) {
        const res = await fetch(`${API_BASE}/SubmitBookReview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({ bookId, rating, comment }).toString(),
            credentials: 'include'
        });
        return await res.json();
    },

    getCategories: async function(forceRefresh = false) {
        if (!forceRefresh) {
            try {
                const cached = sessionStorage.getItem('webbansach_categories_cache_v2');
                if (cached) {
                    const parsed = JSON.parse(cached);
                    // 5-minute cache TTL for lightning-fast loads
                    if (Date.now() - parsed.timestamp < 5 * 60 * 1000 && parsed.data) {
                        return parsed.data;
                    }
                }
            } catch (e) {}
        }
        const res = await fetch(`${API_BASE}/Categories?_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        const data = await res.json();
        if (data && data.status) {
            try {
                sessionStorage.setItem('webbansach_categories_cache_v2', JSON.stringify({ data: data, timestamp: Date.now() }));
            } catch (e) {}
        }
        return data;
    },

    // Cart
    getCart: async function() {
        const res = await fetch(`${API_BASE}/Cart`, { credentials: 'include' });
        return await res.json();
    },

    addToCart: async function(id, quantity = 1) {
        const res = await fetch(`${API_BASE}/AddToCart`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `id=${id}&quantity=${quantity}`,
            credentials: 'include'
        });
        return await res.json();
    },

    updateCart: async function(cartList) {
        const res = await fetch(`${API_BASE}/UpdateCart`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `cartModel=${encodeURIComponent(JSON.stringify(cartList))}`,
            credentials: 'include'
        });
        return await res.json();
    },

    deleteCartItem: async function(id) {
        const res = await fetch(`${API_BASE}/DeleteCartItem`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `id=${id}`,
            credentials: 'include'
        });
        return await res.json();
    },

    clearCart: async function() {
        const res = await fetch(`${API_BASE}/ClearCart`, {
            method: 'POST',
            credentials: 'include'
        });
        return await res.json();
    },

    // Auth
    login: async function(username, password) {
        const res = await fetch(`${API_BASE}/Login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`,
            credentials: 'include'
        });
        return await res.json();
    },

    register: async function(formData) {
        const body = new URLSearchParams(formData).toString();
        const res = await fetch(`${API_BASE}/Register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body,
            credentials: 'include'
        });
        return await res.json();
    },

    logout: async function() {
        const res = await fetch(`${API_BASE}/Logout`, {
            method: 'POST',
            credentials: 'include'
        });
        return await res.json();
    },

    getMe: async function() {
        try {
            const res = await fetch(`${API_BASE}/Me`, { credentials: 'include' });
            return await res.json();
        } catch (e) {
            return { isLoggedIn: false };
        }
    },

    sendOtp: async function() {
        const res = await fetch(`${API_BASE}/SendOtp`, {
            method: 'POST',
            credentials: 'include'
        });
        return await res.json();
    },

    verifyOtp: async function(code) {
        const res = await fetch(`${API_BASE}/VerifyOtp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `code=${encodeURIComponent(code)}`,
            credentials: 'include'
        });
        return await res.json();
    },

    // Orders & Checkout
    checkout: async function(receiverName, receiverPhone, receiverAddress, note = '', paymentMethod = 'cod', cardData = {}) {
        const params = new URLSearchParams({
            receiverName: receiverName,
            receiverPhone: receiverPhone,
            receiverAddress: receiverAddress,
            note: note,
            paymentMethod: paymentMethod,
            cardNumber: cardData.cardNumber || '',
            cardHolder: cardData.cardHolder || '',
            cardExpiry: cardData.cardExpiry || '',
            cardCvv: cardData.cardCvv || ''
        });

        const res = await fetch(`${API_BASE}/Checkout`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString(),
            credentials: 'include'
        });
        return await res.json();
    },

    getMyOrders: async function() {
        const res = await fetch(`${API_BASE}/MyOrders?_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
    },

    cancelOrder: async function(id) {
        const res = await fetch(`${API_BASE}/CancelOrder`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `id=${id}`,
            credentials: 'include'
        });
        return await res.json();
    },

    // Admin
    adminLogin: async function(username, password) {
        const res = await fetch(`${API_BASE}/AdminLogin`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`,
            credentials: 'include'
        });
        return await res.json();
    },

    adminLogout: async function() {
        const res = await fetch(`${API_BASE}/AdminLogout`, {
            method: 'POST',
            credentials: 'include'
        });
        return await res.json();
    },

    getAdminOrders: async function() {
        const res = await fetch(`${API_BASE}/AdminOrders?_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
    },

    getAdminCatalog: async function() {
        const res = await fetch(`${API_BASE}/AdminCatalog`, { credentials: 'include' });
        return await res.json();
    },

    addAdminBook: async function(formData) {
        const res = await fetch(`${API_BASE}/AdminCreateBook`, {
            method: 'POST',
            body: formData,
            credentials: 'include'
        });
        return await res.json();
    },

    updateOrderStatus: async function(id, status, reason = '') {
        const res = await fetch(`${API_BASE}/AdminUpdateOrderStatus`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({ id, status, reason }).toString(),
            credentials: 'include'
        });
        return await res.json();
    }
};

// Formatting utilities
function formatVND(amount) {
    return Number(amount || 0).toLocaleString('vi-VN') + ' VND';
}

function showToast(msg, type = 'success', duration = 3200) {
    let container = document.getElementById('wbsToastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'wbsToastContainer';
        container.className = 'wbs-toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    const toastType = type === 'error' ? 'danger' : type;
    toast.className = `wbs-toast wbs-toast-${toastType}`;
    
    let iconClass = 'fa-check-circle';
    if (type === 'error') iconClass = 'fa-exclamation-circle';
    else if (type === 'warning') iconClass = 'fa-exclamation-triangle';
    else if (type === 'info') iconClass = 'fa-info-circle';

    toast.innerHTML = `
        <div class="wbs-toast-icon"><i class="fa ${iconClass}"></i></div>
        <div class="wbs-toast-msg">${msg}</div>
        <button type="button" class="wbs-toast-close" title="Đóng">&times;</button>
    `;

    container.appendChild(toast);

    // Trigger smooth slide-in
    requestAnimationFrame(() => {
        toast.classList.add('show');
    });

    const closeBtn = toast.querySelector('.wbs-toast-close');
    let timer = null;

    const dismiss = () => {
        if (timer) clearTimeout(timer);
        toast.classList.remove('show');
        toast.classList.add('hide');
        setTimeout(() => toast.remove(), 260);
    };

    closeBtn.addEventListener('click', dismiss);
    timer = setTimeout(dismiss, duration);
}

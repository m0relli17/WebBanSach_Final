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

    getCategories: async function() {
        const res = await fetch(`${API_BASE}/Categories?_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
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

    getAdminOrders: async function() {
        const res = await fetch(`${API_BASE}/AdminOrders?_t=${Date.now()}`, { credentials: 'include', cache: 'no-store' });
        return await res.json();
    },

    updateOrderStatus: async function(id, status) {
        const res = await fetch(`${API_BASE}/AdminUpdateOrderStatus`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `id=${id}&status=${status}`,
            credentials: 'include'
        });
        return await res.json();
    }
};

// Formatting utilities
function formatVND(amount) {
    return Number(amount || 0).toLocaleString('vi-VN') + ' VND';
}

function showToast(msg, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `alert alert-${type === 'error' ? 'danger' : type} position-fixed`;
    toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border-radius: 8px;';
    toast.innerHTML = `<i class="fa fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i> ${msg}`;
    document.body.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.3s';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

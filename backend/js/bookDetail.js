const catalogPage = document.getElementById('catalogPage');
const bookHeading = document.getElementById('bookHeading');
const bookBody = document.getElementById('bookBody');
const bookNotice = document.getElementById('bookNotice');
const bookCover = document.getElementById('bookCover');
const bookFields = document.getElementById('bookFields');
const catalogForm = document.getElementById('catalogForm');
const catalogSearch = document.getElementById('catalogSearch');
const panel = document.getElementById('catalogPanel');
const dialog = document.getElementById('bookDialog');
const rows = document.getElementById('catalogRows');
const previous = document.getElementById('catalogPrev');
const next = document.getElementById('catalogNext');
let currentPage = 1;
let search = '';
let listRequest = 0;
let detailRequest = 0;

async function loadCatalog(page) {
    const request = ++listRequest;
    previous.disabled = next.disabled = true;
    rows.textContent = 'Đang tải sách…';
    catalogPage.textContent = '';
    try {
        const result = await api.getBooks({ search, page, pageSize: 10 });
        if (request !== listRequest) return;
        if (!result.status) throw new Error();
        currentPage = page;
        rows.replaceChildren();
        for (const book of result.data) {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'list-group-item list-group-item-action';
            button.textContent = '#' + book.id + ' · ' + book.title;
            button.onclick = () => showBook(book.id);
            rows.append(button);
        }
        if (!result.data.length) rows.textContent = 'Không tìm thấy sản phẩm.';
        catalogPage.textContent = result.totalPages ? page + ' / ' + result.totalPages : '';
        previous.disabled = page <= 1;
        next.disabled = page >= result.totalPages;
    } catch {
        if (request === listRequest) rows.textContent = 'Không tải được danh sách. Bấm Tìm để thử lại.';
    }
}

async function showBook(id) {
    const request = ++detailRequest;
    bookHeading.textContent = 'Chi tiết sản phẩm';
    bookBody.hidden = true;
    bookNotice.textContent = 'Đang tải chi tiết…';
    dialog.showModal();
    try {
        const result = await api.getBookDetails(id);
        if (request !== detailRequest || !dialog.open) return;
        if (!result.status) {
            bookNotice.textContent = 'Không thể xem thông tin sách này.';
            return;
        }
        const book = result.data;
        bookHeading.textContent = book.title;
        bookNotice.textContent = 'Mã sách #' + book.id;
        bookCover.onerror = () => { bookCover.onerror = null; bookCover.src = 'images/topSach.png'; };
        bookCover.src = 'images/' + encodeURIComponent(book.image || 'topSach.png');
        bookFields.replaceChildren();
        for (const [label, value] of Object.entries({
            'Giá bán': book.priceFormatted, 'Số lượng tồn': book.stock,
            'Thể loại': book.categoryName, 'Tác giả': book.author,
            'Nhà xuất bản': book.publisher, 'Ngày cập nhật': book.updatedDate, 'Mô tả': book.description
        })) {
            const term = document.createElement('dt');
            const description = document.createElement('dd');
            term.textContent = label;
            description.textContent = value ?? '—';
            if (value === '') description.textContent = '—';
            bookFields.append(term, description);
        }
        bookBody.hidden = false;
    } catch {
        if (request === detailRequest && dialog.open) bookNotice.textContent = 'Không tải được chi tiết sản phẩm.';
    }
}
panel.addEventListener('toggle', () => {
    if (panel.open) loadCatalog(1);
});
catalogForm.onsubmit = event => {
    event.preventDefault();
    search = catalogSearch.value.trim();
    loadCatalog(1);
};
previous.onclick = () => loadCatalog(currentPage - 1);
next.onclick = () => loadCatalog(currentPage + 1);
